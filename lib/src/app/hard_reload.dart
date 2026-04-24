import 'package:ai_prg/src/app/hard_reload_stub.dart'
    if (dart.library.html) 'package:ai_prg/src/app/hard_reload_web_impl.dart'
    as hard_reload;

Future<void> triggerHardReload({final String? cacheBustToken}) =>
    hard_reload.triggerHardReload(cacheBustToken: cacheBustToken);
