/*
 * landing.dart
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
import 'package:davapp/backend/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingView extends StatefulWidget {
  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    super.initState();
    //ensureLoggedIn();
  }

  ensureLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool logged = (prefs.getBool('logged') ?? false);
    if (!logged) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } else {
      try {
        var username = prefs.getString('username');
        var password = prefs.getString('password');
        var url = (prefs.getString('url') ?? 'https://sso.davinci.edu.it');
        APIAuth(url, username, password).login();
      } catch (e) {
        print(e);
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
      }
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: (MediaQuery.of(context).size.width <
                        MediaQuery.of(context).size.height)
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.height * 0.7,
                height: (MediaQuery.of(context).size.width <
                        MediaQuery.of(context).size.height)
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.height * 0.7,
                child: Placeholder(), // will be logo
              ),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                ),
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
