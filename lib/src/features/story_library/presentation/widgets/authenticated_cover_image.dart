import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Symmetry cover URLs require `Authorization`. On Flutter Web, [Image.network]
/// cannot send custom headers (browser \<img\> has no header API), so we fetch
/// with [http] and render [Image.memory]. Without headers, uses [Image.network].
class AuthenticatedCoverImage extends StatefulWidget {
  const AuthenticatedCoverImage({
    required this.imageUrl,
    this.requestHeaders,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    super.key,
  });

  final String imageUrl;
  final Map<String, String>? requestHeaders;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  State<AuthenticatedCoverImage> createState() =>
      _AuthenticatedCoverImageState();
}

class _AuthenticatedCoverImageState extends State<AuthenticatedCoverImage> {
  static const int _maxCacheEntries = 48;
  static const int _maxCacheBytes = 24 * 1024 * 1024;
  static final LinkedHashMap<String, Uint8List> _memoryCache =
      LinkedHashMap<String, Uint8List>();
  static final Map<String, Future<Uint8List>> _inFlightRequests =
      <String, Future<Uint8List>>{};
  static int _memoryCacheBytes = 0;

  Future<Uint8List>? _bytesFuture;
  Uint8List? _lastResolvedBytes;

  static bool _needsFetch(final Map<String, String>? headers) =>
      headers != null && headers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _configureImageFuture();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        !_headersEqual(oldWidget.requestHeaders, widget.requestHeaders)) {
      _configureImageFuture();
    }
  }

  void _configureImageFuture() {
    if (!_needsFetch(widget.requestHeaders)) {
      _bytesFuture = null;
      _lastResolvedBytes = null;
      return;
    }
    final String cacheKey = _buildCacheKey(
      imageUrl: widget.imageUrl,
      headers: widget.requestHeaders!,
    );
    final Uint8List? cached = _takeCachedBytes(cacheKey);
    if (cached != null) {
      _lastResolvedBytes = cached;
      _bytesFuture = Future<Uint8List>.value(cached);
      return;
    }
    _lastResolvedBytes = null;
    _bytesFuture = _inFlightRequests[cacheKey] ??= _fetchBytes()
        .then((final bytes) {
          _storeCachedBytes(cacheKey, bytes);
          return bytes;
        })
        .whenComplete(() {
          _inFlightRequests.remove(cacheKey);
        });
  }

  static String _buildCacheKey({
    required final String imageUrl,
    required final Map<String, String> headers,
  }) {
    final List<String> pairs =
        headers.entries
            .map((final entry) => '${entry.key}:${entry.value}')
            .toList()
          ..sort();
    return '$imageUrl|${pairs.join('|')}';
  }

  static Uint8List? _takeCachedBytes(final String cacheKey) {
    final Uint8List? cached = _memoryCache.remove(cacheKey);
    if (cached == null) {
      return null;
    }
    _memoryCache[cacheKey] = cached;
    return cached;
  }

  static void _storeCachedBytes(final String cacheKey, final Uint8List bytes) {
    final Uint8List? replaced = _memoryCache.remove(cacheKey);
    if (replaced != null) {
      _memoryCacheBytes -= replaced.lengthInBytes;
    }
    _memoryCache[cacheKey] = bytes;
    _memoryCacheBytes += bytes.lengthInBytes;
    while (_memoryCache.length > _maxCacheEntries ||
        _memoryCacheBytes > _maxCacheBytes) {
      final MapEntry<String, Uint8List> oldest = _memoryCache.entries.first;
      _memoryCache.remove(oldest.key);
      _memoryCacheBytes -= oldest.value.lengthInBytes;
    }
  }

  bool _headersEqual(
    final Map<String, String>? a,
    final Map<String, String>? b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == null && b == null;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final MapEntry<String, String> e in a.entries) {
      if (b[e.key] != e.value) {
        return false;
      }
    }
    return true;
  }

  Future<Uint8List> _fetchBytes() async {
    final http.Response response = await http.get(
      Uri.parse(widget.imageUrl),
      headers: widget.requestHeaders!,
    );
    if (response.statusCode != 200) {
      throw StateError('cover_http_${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Widget _buildResolvedImage(final Uint8List bytes) =>
      Image.memory(bytes, fit: widget.fit, gaplessPlayback: true);

  @override
  Widget build(final BuildContext context) {
    final Map<String, String>? headers = widget.requestHeaders;
    if (headers == null || headers.isEmpty) {
      return Image.network(
        widget.imageUrl,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: widget.errorBuilder,
      );
    }
    return FutureBuilder<Uint8List>(
      future: _bytesFuture!,
      builder: (context, s) {
        if (s.hasData) {
          _lastResolvedBytes = s.data;
        }
        if (s.connectionState != ConnectionState.done) {
          if (_lastResolvedBytes != null) {
            return _buildResolvedImage(_lastResolvedBytes!);
          }
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (s.hasError || !s.hasData) {
          final Object err = s.hasError ? s.error! : StateError('cover_empty');
          final StackTrace stack = s.stackTrace ?? StackTrace.empty;
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, err, stack);
          }
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        }
        return _buildResolvedImage(s.data!);
      },
    );
  }
}
