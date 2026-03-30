import 'package:ai_prg/src/core/data/isar/storage_backend.dart';

class AppDatabase {
  AppDatabase({
    final String? directoryPath,
    final String name = 'ai_prg_storage',
  });

  static final AppDatabase instance = AppDatabase();

  StorageBackend get backend => StorageBackend.sharedPreferences;

  Future<void> ensureReady() async {}

  Future<Object> get isar async =>
      throw UnsupportedError('Isar storage is not available on web.');

  Future<Object?> get maybeIsar async => null;

  Future<void> close({final bool deleteFromDisk = false}) async {}
}
