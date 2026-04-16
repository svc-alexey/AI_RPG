import 'package:flutter/material.dart';

/// Observes [RouteAware] widgets (e.g. refresh library when a pushed route pops).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
