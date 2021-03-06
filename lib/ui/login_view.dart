/*
 * login_view.dart
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
import 'package:davapp/ui/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatefulWidget {
  final TextStyle textStyle = TextStyle(fontSize: 20.0);

  LoginView({Key key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  APIAuth apiAuth;
  SharedPreferences prefs;
  final secureStorage = FlutterSecureStorage();

  String username;
  String password;

  @override
  void initState() {
    super.initState();
    this.apiAuth = APIAuth.instance;
    loadSharedPreferences();
  }

  void loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _handleSubmit() async {
    final form = formKey.currentState;
    try {
      apiAuth.username = username;
      apiAuth.password = password;
      await apiAuth.login();

      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      await prefs.setBool('logged', true);

      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.message),
        action: SnackBarAction(
          label: 'Impostazioni',
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return ServerAddressDialog(prefs);
              },
            );
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (MediaQuery.of(context).size.width <
                  MediaQuery.of(context).size.height)
              ? MediaQuery.of(context).size.width * 0.11
              : MediaQuery.of(context).size.height * 0.11,
        ),
        alignment: Alignment.center,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.8,
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width <
                        MediaQuery.of(context).size.height)
                    ? MediaQuery.of(context).size.width * 0.6
                    : MediaQuery.of(context).size.height * 0.6,
                height: (MediaQuery.of(context).size.width <
                        MediaQuery.of(context).size.height)
                    ? MediaQuery.of(context).size.width * 0.6
                    : MediaQuery.of(context).size.height * 0.6,
                child: SvgPicture.asset('assets/icon/logo_round.svg',
                    semanticsLabel: 'Logo dell\'applicazione'),
              ),
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.3,
                ),
              ),
              TextFormField(
                style: widget.textStyle,
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 15.0),
                  hintText: 'Username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  suffixIcon: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.0),
                    child: Icon(Icons.person),
                  ),
                ),
                onSaved: (String value) {
                  this.username = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Username richiesto';
                  }
                  return null;
                },
              ),
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.15,
                ),
              ),
              TextFormField(
                style: widget.textStyle,
                obscureText: true,
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 15.0),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  suffixIcon: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.0),
                    child: Icon(Icons.lock),
                  ),
                ),
                onSaved: (String value) {
                  password = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Password richiesta';
                  }
                  return null;
                },
              ),
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.20,
                ),
              ),
              Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Theme.of(context).colorScheme.primary,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  onPressed: () async {
                    var form = formKey.currentState;
                    if (form.validate()) {
                      scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: const Text('Accesso al server...')));
                      form.save();
                      await _handleSubmit();
                    }
                  },
                  child: Text(
                    'Accedi',
                    textAlign: TextAlign.center,
                    style: widget.textStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
