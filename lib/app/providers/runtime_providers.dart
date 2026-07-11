import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/gameplay/gameplay_runtime.dart';
import '../../data/repositories/asset_content_repository.dart';
import '../../data/repositories/shared_preferences_progress_repository.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/progress_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return AssetContentRepository();
});

final progressRepositoryProvider = FutureProvider<ProgressRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesProgressRepository(prefs);
});

final gameplayRuntimeProvider = FutureProvider<GameplayRuntime>((ref) async {
  final progressRepository = await ref.watch(progressRepositoryProvider.future);
  return GameplayRuntime(progressRepository);
});
