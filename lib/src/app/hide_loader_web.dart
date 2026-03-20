import 'package:ai_prg/src/app/hide_loader_stub.dart'
    if (dart.library.html) 'package:ai_prg/src/app/hide_loader_web_impl.dart'
        as loader;

/// Скрывает HTML-лоадер из index.html (только на web).
void hideHtmlLoader() => loader.hideHtmlLoader();
