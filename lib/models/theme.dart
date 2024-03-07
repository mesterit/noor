import 'package:flutter/material.dart';
import 'package:Janaty/exports/constants.dart' show Images;
import 'package:Janaty/exports/services.dart' show SharedPrefsService;

import '../constants/colors.dart';

class ThemeModel with ChangeNotifier {
  String _userTheme = SharedPrefsService.getString('theme');

  String get userTheme => _userTheme;
  get brightness => MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
      .platformBrightness;

  set userTheme(String value) {
    _userTheme = value;
    notifyListeners();
  }

  ThemeMode get theme {
    switch (userTheme) {
      case 'dark_theme':
        return ThemeMode.dark;
      case 'light_theme':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Images get images {
    switch (userTheme) {
      case 'dark_theme':
        return Images.dark;
      case 'light_theme':
        return Images.light;
      default:
        {
          switch (brightness) {
            case Brightness.dark:
              return Images.dark;
            default:
              return Images.light;
          }
        }
    }
  }

  AlmuslimColors get colors {
    switch (userTheme) {
      case 'dark_theme':
        return AlmuslimColors.dark;
      case 'light_theme':
        return AlmuslimColors.light;
      default:
        {
          switch (brightness) {
            case Brightness.dark:
              return AlmuslimColors.dark;
            default:
              return AlmuslimColors.light;
          }
        }
    }
  }
}
