import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/bootstrap/runtime_bootstrap.dart';
import '../../application/gameplay/gameplay_runtime.dart';
import '../../domain/repositories/progress_repository.dart';

final runtimeDependenciesProvider = FutureProvider<RuntimeDependencies>(
  (ref) async {
    final dependencies = await RuntimeBootstrap.create();
    ref.onDispose(() => unawaited(dependencies.dispose()));
    return dependencies;
  },
);

final progressRepositoryProvider = FutureProvider<ProgressRepository>(
  (ref) async {
    final dependencies = await ref.watch(runtimeDependenciesProvider.future);
    return dependencies.progressRepository;
  },
);

final gameplayRuntimeProvider = FutureProvider<GameplayRuntime>(
  (ref) async {
    final dependencies = await ref.watch(runtimeDependenciesProvider.future);
    return dependencies.gameplayRuntime;
  },
);
