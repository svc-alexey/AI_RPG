enum LandingLegalTab { offer, privacy, refunds, contacts }

String normalizeLandingLanguage(final String? value) {
  final String normalized = (value ?? '').trim().toLowerCase();
  return normalized == 'en' ? 'en' : 'ru';
}

Uri buildLandingLegalUri({
  required final LandingLegalTab tab,
  required final String language,
}) {
  final Uri legalUri = Uri(
    path: '/',
    queryParameters: <String, String>{
      'view': 'legal',
      'tab': tab.name,
      'lang': normalizeLandingLanguage(language),
    },
  );
  return Uri.base.resolveUri(legalUri);
}
