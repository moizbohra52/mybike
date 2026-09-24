import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Centralized Bloc & Cubit Observer for MYBIKE ERP
/// Logs controller instantiation and lifecycle events to the console.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('🎮 [CONTROLLER / CUBIT INITIALIZED] ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('❌ [CONTROLLER ERROR] ${bloc.runtimeType} -> $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    debugPrint('🛑 [CONTROLLER DISPOSED] ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
