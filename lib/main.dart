/*
 * main.dart
 *
 * This file is part of davapp.
 *
 * davapp is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * davapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with davapp.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:davapp/ui/main_view.dart';
import 'package:davapp/ui/landing_view.dart';
import 'package:davapp/ui/login_view.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(DavApp());
}

class DavApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        primarySwatch: Colors.red,
        primaryColorLight: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      dark: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        accentColor: Colors.red,
        accentColorBrightness: Brightness.light,
        primaryColorLight: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'davapp',
        routes: {
          '/': (context) => LandingView(),
          '/login': (context) => LoginView(),
          '/home': (context) => MainView(),
        },
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
