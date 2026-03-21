import 'package:ai_prg/src/app/hide_loader_stub.dart'
    if (dart.library.html) 'package:ai_prg/src/app/hide_loader_web_impl.dart'
    as loader;

/// Removes the HTML loader immediately.
void hideHtmlLoader() => loader.hideHtmlLoader();

/// Notifies the landing page that Flutter rendered its first visible frame.
void notifyHtmlLoaderFirstFrame() => loader.notifyHtmlLoaderFirstFrame();

/// Asks the landing screen to finish its loading transition gracefully.
void completeHtmlLoaderTransition() => loader.completeHtmlLoaderTransition();
