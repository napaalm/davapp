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

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:davapp/backend/api.dart';
import 'package:davapp/backend/storage/comunicati.dart';
import 'package:davapp/ui/pages/about_page.dart' as about_page;
import 'package:davapp/ui/pages/settings_page.dart' as settings_page;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingView extends StatefulWidget {
  static bool alreadyInitialized = false;

  LandingView({Key key}) : super(key: key);

  @override
  _LandingViewState createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool firstLaunch = false;
  APIDav apiDav;
  APIAuth apiAuth;
  SharedPreferences prefs;
  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  initializeApp() async {
    prefs = await SharedPreferences.getInstance();

    if (!LandingView.alreadyInitialized) {
      LandingView.alreadyInitialized = true;
      about_page.packageInfo = await PackageInfo.fromPlatform();
      about_page.version = about_page.packageInfo.version;
      about_page.buildNumber = about_page.packageInfo.buildNumber;

      await initializeDateFormatting('it_IT', null);

      ComunicatiStorage storage = await ComunicatiStorage.createInstance();

      if (prefs.getString('login_url') == null) {
        prefs.setString('login_url', settings_page.defaultAuthURL);
      }

      apiAuth = APIAuth(prefs.getString('login_url'));

      if (prefs.getString('api_url') == null) {
        prefs.setString('api_url', settings_page.defaultAPIURL);
        firstLaunch = true;
      }

      apiDav = APIDav(prefs.getString('api_url'), apiAuth);
    } else {
      apiDav = APIDav.instance;
      apiAuth = APIAuth.instance;
    }

    while (!firstLaunch) {
      try {
        if (await apiDav.isOnline()) {
          break;
        }
      } catch (e) {}
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text("Errore di connessione! Nuovo tentativo tra 5 secondi..."),
        action: SnackBarAction(
          label: 'Impostazioni',
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return settings_page.ServerAddressDialog(prefs);
              },
            );
          },
        ),
      ));
      await Future.delayed(Duration(seconds: 5));
    }

    bool logged = (prefs.getBool('logged') ?? false);
    if (!logged) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } else {
      try {
        apiAuth.username = await secureStorage.read(key: 'username');
        apiAuth.password = await secureStorage.read(key: 'password');

        await apiAuth.login();
      } catch (e) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
                "Errore di accesso. Reindirizzamento alla pagina di login...")));
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                child: SvgPicture.asset('assets/icon/logo_rect.svg',
                    semanticsLabel: 'Logo dell\'applicazione'),
              ),
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                ),
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
