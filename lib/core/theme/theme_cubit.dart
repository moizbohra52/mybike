import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Theme state
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  @override
  List<Object> get props => [themeMode];
}

/// Theme Cubit — manages light/dark/system theme persistence
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Load persisted theme preference
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(StorageConstants.themeMode);
    if (themeIndex != null && themeIndex < ThemeMode.values.length) {
      emit(ThemeState(themeMode: ThemeMode.values[themeIndex]));
    }
  }

  /// Change and persist theme
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageConstants.themeMode, mode.index);
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
