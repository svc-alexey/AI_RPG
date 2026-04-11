import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> triggerClientUpdate({
  required final bool reloadOnly,
  final String? updateUrl,
}) async {
  if (reloadOnly) {
    final Uri reloadUri = Uri.base.replace(
      queryParameters: <String, String>{
        ...Uri.base.queryParameters,
        'v': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    await launchUrl(reloadUri, webOnlyWindowName: '_self');
    return;
  }
  if (updateUrl != null && updateUrl.trim().isNotEmpty) {
    await launchUrlString(
      updateUrl,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }
}
