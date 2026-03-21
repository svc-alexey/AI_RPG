import 'package:ai_prg/src/app/hide_loader_stub.dart'
    if (dart.library.html) 'package:ai_prg/src/app/hide_loader_web_impl.dart'
    as loader;

/// Removes the HTML loader immediately.
void hideHtmlLoader() => loader.hideHtmlLoader();

/// Asks the landing screen to finish its loading transition gracefully.
void completeHtmlLoaderTransition() => loader.completeHtmlLoaderTransition();
