/// Builds a canonical URL for a legal document page.
///
/// All legal documents are served as static HTML at the root of the domain.
/// This helper ensures consistent URL construction across the app.
///
/// Example:
/// ```dart
/// buildLegalUrl('offer')       // '/offer.html'
/// buildLegalUrl('privacy')     // '/privacy.html'
/// buildLegalUrl('offer', lang: 'en') // '/offer.html?lang=en'
/// ```
String buildLegalUrl(String page, {String? lang}) {
  final validPages = {'offer', 'privacy', 'consent', 'refunds', 'contacts', 'pricing'};
  assert(validPages.contains(page), 'Invalid legal page: $page');
  final url = '/$page.html';
  if (lang != null && lang.isNotEmpty) {
    return '$url?lang=$lang';
  }
  return url;
}

/// All valid legal page identifiers.
const legalPages = ['offer', 'privacy', 'consent', 'refunds', 'contacts', 'pricing'];
