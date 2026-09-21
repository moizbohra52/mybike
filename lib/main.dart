import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/utils/performance_optimizer.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

/// MYBIKE Application Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize performance optimizations & ImageCache memory bounds
  await PerformanceOptimizer.initialize();

  // Initialize Supabase (with fallback for dev/offline mode)
  await SupabaseConfig.initialize();

  runApp(const MyBikeApp());
}

class MyBikeApp extends StatelessWidget {
  const MyBikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()..loadTheme(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'MYBIKE',
            debugShowCheckedModeBanner: false,

            // ─── Theme ───
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,

            // ─── Routing ───
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
