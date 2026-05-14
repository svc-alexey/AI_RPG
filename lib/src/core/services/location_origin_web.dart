import 'dart:js_interop';

@JS('self.location.origin')
external String get _locationOrigin;

String getLocationOrigin() => _locationOrigin;
