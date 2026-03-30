import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PortraitStorage {
  const PortraitStorage();

  Future<String?> savePortrait({
    required final String campaignId,
    required final String mimeType,
    required final String bytesBase64,
  }) async {
    final List<int> bytes = base64Decode(bytesBase64);
    final Directory root = await getApplicationSupportDirectory();
    final Directory portraitsDir = Directory(
      '${root.path}${Platform.pathSeparator}portraits',
    );
    if (!portraitsDir.existsSync()) {
      portraitsDir.createSync(recursive: true);
    }

    final String extension = switch (mimeType.toLowerCase()) {
      'image/jpeg' || 'image/jpg' => 'jpg',
      'image/webp' => 'webp',
      _ => 'png',
    };
    final File file = File(
      '${portraitsDir.path}${Platform.pathSeparator}$campaignId.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
