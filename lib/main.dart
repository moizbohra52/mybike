import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/routes/app_router.dart';

/// MYBIKE Application Entry Point
///
/// Initializes:
/// - Theme management (BLoC)
/// - GoRouter navigation
/// - Material 3 with Inter font
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyBikeApp());
}

class MyBikeApp extends StatelessWidget {
  const MyBikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit()..loadTheme(),
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
