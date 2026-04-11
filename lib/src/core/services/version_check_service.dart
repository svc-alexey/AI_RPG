import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/update_repository.dart';
import 'package:flutter/foundation.dart';

class VersionCheckService {
  const VersionCheckService({UpdateRepository? updateRepository})
    : _updateRepository = updateRepository;

  final UpdateRepository? _updateRepository;

  Future<SymmetryVersionPlatformInfo> checkCurrentPlatform() async {
    final SymmetryVersionInfo info = await _updateRepository!
        .fetchVersionInfo();
    return kIsWeb ? info.platforms.web : info.platforms.desktop;
  }
}
