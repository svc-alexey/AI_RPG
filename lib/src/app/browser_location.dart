import 'package:ai_prg/src/app/browser_location_stub.dart'
    if (dart.library.html) 'package:ai_prg/src/app/browser_location_web_impl.dart'
    as browser_location;

void replaceBrowserUrl(final String url) =>
    browser_location.replaceBrowserUrl(url);

void navigateBrowserUrl(final String url) =>
    browser_location.navigateBrowserUrl(url);
