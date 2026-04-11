import 'package:ai_prg/src/core/config/app_release_env.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:flutter/foundation.dart';

class UpdateRepository {
  UpdateRepository({required SymmetryAuthRepository authRepository})
    : _authRepository = authRepository;

  final SymmetryAuthRepository _authRepository;

  Future<SymmetryVersionInfo> fetchVersionInfo() async {
    final SymmetrySession? session = await _authRepository.loadSession();
    final String baseUrl =
        session?.baseUrl ?? await _authRepository.loadBaseUrl();
    return SymmetryApiClient(baseUrl: baseUrl).getVersionInfo(
      currentVersion: AppReleaseEnv.appVersion,
      currentAssetVersion: kIsWeb ? AppReleaseEnv.assetVersion : null,
    );
  }
}
