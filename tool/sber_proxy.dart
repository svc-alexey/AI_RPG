import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _defaultHost = '127.0.0.1';
const int _defaultPort = 8787;
const String _defaultModel = 'GigaChat-2';
const String _defaultImageModel = 'GigaChat-2-Pro';
const String _oauthUrl = 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth';
const String _apiBaseUrl = 'https://gigachat.devices.sberbank.ru/api/v1';
const Set<String> _sberHosts = <String>{
  'ngw.devices.sberbank.ru',
  'gigachat.devices.sberbank.ru',
};

Future<void> main() async {
  final ProxyConfig config = ProxyConfig.load();
  final SberTokenProvider tokenProvider = SberTokenProvider(config);
  final HttpServer server = await HttpServer.bind(config.host, config.port);

  stdout.writeln(
    'Sber proxy listening on http://${config.host}:${config.port}/v1',
  );

  await for (final HttpRequest request in server) {
    unawaited(_handleRequest(request, config, tokenProvider));
  }
}

Future<void> _handleRequest(
  final HttpRequest request,
  final ProxyConfig config,
  final SberTokenProvider tokenProvider,
) async {
  try {
    _writeCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    if (request.uri.path == '/health') {
      await _writeJson(request.response, HttpStatus.ok, <String, Object?>{
        'status': 'ok',
        'model': config.model,
        'imageModel': config.imageModel,
      });
      return;
    }

    if (request.uri.path == '/v1/models' && request.method == 'GET') {
      await _writeJson(request.response, HttpStatus.ok, <String, Object?>{
        'object': 'list',
        'data': <Map<String, Object?>>[
          <String, Object?>{
            'id': config.model,
            'object': 'model',
            'owned_by': 'sber',
          },
        ],
      });
      return;
    }

    if (request.uri.path == '/v1/chat/completions' &&
        request.method == 'POST') {
      await _handleChatCompletions(
        request: request,
        config: config,
        tokenProvider: tokenProvider,
      );
      return;
    }

    if (request.uri.path == '/v1/images/generations' &&
        request.method == 'POST') {
      await _handleImageGenerations(
        request: request,
        config: config,
        tokenProvider: tokenProvider,
      );
      return;
    }

    await _writeJson(request.response, HttpStatus.notFound, <String, Object?>{
      'error': <String, Object?>{'message': 'Not found'},
    });
  } catch (error, stackTrace) {
    stderr
      ..writeln('Proxy request failed: $error')
      ..writeln(stackTrace);
    await _writeJson(
      request.response,
      HttpStatus.internalServerError,
      <String, Object?>{
        'error': <String, Object?>{'message': 'Proxy failure: $error'},
      },
    );
  }
}

Future<void> _handleImageGenerations({
  required final HttpRequest request,
  required final ProxyConfig config,
  required final SberTokenProvider tokenProvider,
}) async {
  final String rawBody = await utf8.decoder.bind(request).join();
  final Object? decoded = jsonDecode(rawBody);
  if (decoded is! Map) {
    await _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
      'error': <String, Object?>{'message': 'Expected a JSON object body.'},
    });
    return;
  }

  final Map<String, Object?> body = _normalizeJsonMap(decoded);
  final String prompt = (body['prompt'] as String? ?? '').trim();
  if (prompt.isEmpty) {
    await _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
      'error': <String, Object?>{'message': 'Prompt is required.'},
    });
    return;
  }

  final String accessToken = await tokenProvider.getAccessToken();
  final HttpClient client = _createSberHttpClient();
  try {
    final Map<String, Object?> imageRequest = <String, Object?>{
      'model': config.imageModel,
      'messages': <Map<String, Object?>>[
        <String, Object?>{
          'role': 'system',
          'content':
              'Ты художник-иллюстратор персонажей. Сгенерируй одно качественное изображение по описанию пользователя. Верни результат генерации изображения.',
        },
        <String, Object?>{'role': 'user', 'content': prompt},
      ],
      'function_call': 'auto',
      'stream': false,
    };

    final HttpClientResponse chatResponse = await _postJson(
      client: client,
      uri: Uri.parse('$_apiBaseUrl/chat/completions'),
      accessToken: accessToken,
      body: imageRequest,
    );
    final String chatBody = await utf8.decoder.bind(chatResponse).join();
    if (chatResponse.statusCode < 200 || chatResponse.statusCode >= 300) {
      request.response.statusCode = chatResponse.statusCode;
      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      request.response.write(chatBody);
      await request.response.close();
      return;
    }

    final Object? responseDecoded = jsonDecode(chatBody);
    if (responseDecoded is! Map) {
      throw const FormatException('Unexpected chat image response format.');
    }
    final Map<String, Object?> json = _normalizeJsonMap(responseDecoded);
    final String fileId = _extractImageFileId(json);
    if (fileId.isEmpty) {
      throw StateError('Sber image generation did not return a file id.');
    }

    final HttpClientRequest fileRequest = await client.getUrl(
      Uri.parse('$_apiBaseUrl/files/$fileId/content'),
    );
    fileRequest.headers.set(
      HttpHeaders.acceptHeader,
      'application/octet-stream',
    );
    fileRequest.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer $accessToken',
    );
    final HttpClientResponse fileResponse = await fileRequest.close();
    final List<int> imageBytes = await fileResponse.fold<List<int>>(
      <int>[],
      (final acc, final chunk) => acc..addAll(chunk),
    );

    if (fileResponse.statusCode < 200 || fileResponse.statusCode >= 300) {
      request.response.statusCode = fileResponse.statusCode;
      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      request.response.write(
        jsonEncode(<String, Object?>{
          'error': <String, Object?>{
            'message': 'Failed to download generated image file.',
            'fileId': fileId,
          },
        }),
      );
      await request.response.close();
      return;
    }

    final String mimeType =
        fileResponse.headers.contentType?.mimeType ?? 'image/png';
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json; charset=utf-8',
    );
    request.response.write(
      jsonEncode(<String, Object?>{
        'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'data': <Map<String, Object?>>[
          <String, Object?>{
            'b64_json': base64Encode(imageBytes),
            'mime_type': mimeType,
            'file_id': fileId,
          },
        ],
      }),
    );
    await request.response.close();
  } finally {
    client.close();
  }
}

Future<HttpClientResponse> _postJson({
  required final HttpClient client,
  required final Uri uri,
  required final String accessToken,
  required final Map<String, Object?> body,
}) async {
  final HttpClientRequest upstreamRequest = await client.postUrl(uri);
  upstreamRequest.headers.set(
    HttpHeaders.contentTypeHeader,
    'application/json',
  );
  upstreamRequest.headers.set(HttpHeaders.acceptHeader, 'application/json');
  upstreamRequest.headers.set(
    HttpHeaders.authorizationHeader,
    'Bearer $accessToken',
  );
  final List<int> encodedRequestBody = utf8.encode(jsonEncode(body));
  upstreamRequest.headers.set(
    HttpHeaders.contentLengthHeader,
    encodedRequestBody.length,
  );
  upstreamRequest.add(encodedRequestBody);
  return upstreamRequest.close();
}

String _extractImageFileId(final Map<String, Object?> responseMap) {
  final List<Object?> choices = responseMap['choices'] is List
      ? List<Object?>.from(responseMap['choices'] as List)
      : const <Object?>[];
  if (choices.isEmpty) {
    return '';
  }
  final Map<String, Object?> choice = _normalizeJsonMap(choices.first);
  final Map<String, Object?> message = _normalizeJsonMap(choice['message']);
  final String content = (message['content'] as String? ?? '').trim();
  final RegExp imgTag = RegExp(r'<img\s+src="([^"]+)"', caseSensitive: false);
  final Match? match = imgTag.firstMatch(content);
  return match?.group(1)?.trim() ?? '';
}

Future<void> _handleChatCompletions({
  required final HttpRequest request,
  required final ProxyConfig config,
  required final SberTokenProvider tokenProvider,
}) async {
  final String rawBody = await utf8.decoder.bind(request).join();
  final Object? decoded = jsonDecode(rawBody);
  if (decoded is! Map) {
    await _writeJson(request.response, HttpStatus.badRequest, <String, Object?>{
      'error': <String, Object?>{'message': 'Expected a JSON object body.'},
    });
    return;
  }

  final Map<String, Object?> body = _normalizeJsonMap(decoded);
  body['model'] = config.model;
  final bool stream = body['stream'] == true;

  final String accessToken = await tokenProvider.getAccessToken();
  final HttpClient client = _createSberHttpClient();
  final HttpClientRequest upstreamRequest = await client.postUrl(
    Uri.parse('$_apiBaseUrl/chat/completions'),
  );
  upstreamRequest.headers.set(
    HttpHeaders.contentTypeHeader,
    'application/json',
  );
  upstreamRequest.headers.set(HttpHeaders.acceptHeader, 'application/json');
  upstreamRequest.headers.set(
    HttpHeaders.authorizationHeader,
    'Bearer $accessToken',
  );
  if (stream) {
    upstreamRequest.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
  }
  final List<int> encodedRequestBody = utf8.encode(jsonEncode(body));
  upstreamRequest.headers.set(
    HttpHeaders.contentLengthHeader,
    encodedRequestBody.length,
  );
  upstreamRequest.add(encodedRequestBody);

  final HttpClientResponse upstreamResponse = await upstreamRequest.close();

  if (stream) {
    request.response.statusCode = upstreamResponse.statusCode;
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'text/event-stream; charset=utf-8',
    );
    request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    request.response.headers.set('X-Accel-Buffering', 'no');
    await upstreamResponse.pipe(request.response);
    client.close();
    return;
  }

  final String responseBody = await utf8.decoder.bind(upstreamResponse).join();
  request.response.statusCode = upstreamResponse.statusCode;
  request.response.headers.set(
    HttpHeaders.contentTypeHeader,
    'application/json; charset=utf-8',
  );
  request.response.write(responseBody);
  await request.response.close();
  client.close();
}

Future<void> _writeJson(
  final HttpResponse response,
  final int statusCode,
  final Object body,
) async {
  response.statusCode = statusCode;
  response.headers.set(
    HttpHeaders.contentTypeHeader,
    'application/json; charset=utf-8',
  );
  response.write(jsonEncode(body));
  await response.close();
}

void _writeCorsHeaders(final HttpResponse response) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(
      HttpHeaders.accessControlAllowHeadersHeader,
      'Content-Type, Authorization',
    )
    ..set(HttpHeaders.accessControlAllowMethodsHeader, 'GET, POST, OPTIONS');
}

Map<String, Object?> _normalizeJsonMap(final Object? value) {
  if (value is Map) {
    return value.map((final key, final item) => MapEntry(key.toString(), item));
  }
  return <String, Object?>{};
}

class ProxyConfig {
  ProxyConfig({
    required this.host,
    required this.port,
    required this.authKey,
    required this.clientId,
    required this.clientSecret,
    required this.model,
    required this.imageModel,
    required this.scope,
  });

  factory ProxyConfig.load() {
    final Map<String, String> env = _loadEnvFile('.env');
    String requireValue(final String key) {
      final String? value = env[key];
      if (value == null || value.trim().isEmpty) {
        throw StateError('Missing required env key: $key');
      }
      return value.trim();
    }

    return ProxyConfig(
      host: env['SBER_PROXY_HOST']?.trim().isNotEmpty == true
          ? env['SBER_PROXY_HOST']!.trim()
          : _defaultHost,
      port: int.tryParse(env['SBER_PROXY_PORT'] ?? '') ?? _defaultPort,
      authKey: requireValue('SBER_AUTH_KEY'),
      clientId: requireValue('SBER_CLIENT_ID'),
      clientSecret: requireValue('SBER_CLIENT_SECRET'),
      model: env['SBER_MODEL']?.trim().isNotEmpty == true
          ? env['SBER_MODEL']!.trim()
          : _defaultModel,
      imageModel: env['SBER_IMAGE_MODEL']?.trim().isNotEmpty == true
          ? env['SBER_IMAGE_MODEL']!.trim()
          : _defaultImageModel,
      scope: env['SBER_SCOPE']?.trim().isNotEmpty == true
          ? env['SBER_SCOPE']!.trim()
          : 'GIGACHAT_API_PERS',
    );
  }

  final String host;
  final int port;
  final String authKey;
  final String clientId;
  final String clientSecret;
  final String model;
  final String imageModel;
  final String scope;
}

class SberTokenProvider {
  SberTokenProvider(this._config);

  final ProxyConfig _config;
  String? _cachedToken;
  DateTime? _expiresAt;
  Future<String>? _inFlight;

  Future<String> getAccessToken() async {
    if (_cachedToken != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(_expiresAt!)) {
      return _cachedToken!;
    }
    if (_inFlight != null) {
      return _inFlight!;
    }
    final Future<String> future = _refreshToken();
    _inFlight = future;
    try {
      return await future;
    } finally {
      _inFlight = null;
    }
  }

  Future<String> _refreshToken() async {
    final HttpClient client = _createSberHttpClient();
    final HttpClientRequest request = await client.postUrl(
      Uri.parse(_oauthUrl),
    );
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/x-www-form-urlencoded',
    );
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set('RqUID', _uuidV4());
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Basic ${_config.authKey}',
    );
    final List<int> encodedBody = utf8.encode(
      'scope=${Uri.encodeQueryComponent(_config.scope)}',
    );
    request.headers.set(HttpHeaders.contentLengthHeader, encodedBody.length);
    request.add(encodedBody);

    final HttpClientResponse response = await request.close();
    final String body = await utf8.decoder.bind(response).join();
    client.close();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Failed to fetch Sber OAuth token (${response.statusCode}): $body',
      );
    }

    final Object? decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const FormatException('Unexpected OAuth response format.');
    }
    final Map<String, Object?> json = _normalizeJsonMap(decoded);
    final String token = (json['access_token'] as String? ?? '').trim();
    final int expiresAtSeconds =
        (json['expires_at'] as num?)?.toInt() ??
        DateTime.now()
                .add(const Duration(minutes: 25))
                .millisecondsSinceEpoch ~/
            1000;
    if (token.isEmpty) {
      throw const FormatException(
        'OAuth response did not contain access_token.',
      );
    }

    _cachedToken = token;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expiresAtSeconds * 1000,
    ).subtract(const Duration(seconds: 30));
    return token;
  }
}

Map<String, String> _loadEnvFile(final String path) {
  final File file = File(path);
  if (!file.existsSync()) {
    throw StateError(
      'Env file not found at $path. Create it from .env.example before starting the proxy.',
    );
  }

  final Map<String, String> result = <String, String>{};
  for (final String rawLine in file.readAsLinesSync()) {
    final String line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final int separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }
    final String key = line.substring(0, separatorIndex).trim();
    String value = line.substring(separatorIndex + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    result[key] = value;
  }
  return result;
}

String _uuidV4() {
  final Random random = Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < bytes.length; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      buffer.write('-');
    }
    buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

HttpClient _createSberHttpClient() {
  final HttpClient client = HttpClient()
    ..badCertificateCallback = (_, host, _) => _sberHosts.contains(host);
  return client;
}
