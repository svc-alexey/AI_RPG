import 'package:ai_prg/src/app/hard_reload.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> triggerClientUpdate({
  required final bool reloadOnly,
  final String? updateUrl,
}) async {
  if (reloadOnly) {
    await triggerHardReload();
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
