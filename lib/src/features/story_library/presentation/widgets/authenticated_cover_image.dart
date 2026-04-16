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
  Future<Uint8List>? _bytesFuture;

  static bool _needsFetch(final Map<String, String>? headers) =>
      headers != null && headers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_needsFetch(widget.requestHeaders)) {
      _bytesFuture = _fetchBytes();
    }
  }

  @override
  void didUpdateWidget(covariant AuthenticatedCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        !_headersEqual(oldWidget.requestHeaders, widget.requestHeaders)) {
      _bytesFuture =
          _needsFetch(widget.requestHeaders) ? _fetchBytes() : null;
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

  @override
  Widget build(final BuildContext context) {
    final Map<String, String>? headers = widget.requestHeaders;
    if (headers == null || headers.isEmpty) {
      return Image.network(
        widget.imageUrl,
        fit: widget.fit,
        errorBuilder: widget.errorBuilder,
      );
    }
    return FutureBuilder<Uint8List>(
      future: _bytesFuture!,
      builder: (final BuildContext context, final AsyncSnapshot<Uint8List> s) {
        if (s.connectionState != ConnectionState.done) {
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
        return Image.memory(
          s.data!,
          fit: widget.fit,
        );
      },
    );
  }
}
