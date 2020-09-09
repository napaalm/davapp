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
import 'package:shared_preferences/shared_preferences.dart';

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

  String username;
  String password;

  @override
  void initState() {
    super.initState();
    this.apiAuth = APIAuth.instance;
  }

  void _handleSubmit() async {
    final form = formKey.currentState;
    try {
      apiAuth.username = username;
      apiAuth.password = password;
      await apiAuth.login();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      await prefs.setString('username', username);
      await prefs.setString('password', password);

      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
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
        color: Colors.white,
        alignment: Alignment.center,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
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
                child: Placeholder(), // will be logo
              ),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.3,
                ),
              ),
              TextFormField(
                style: widget.textStyle,
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 15.0),
                  hintText: 'Username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
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
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.15,
                ),
              ),
              TextFormField(
                style: widget.textStyle,
                obscureText: true,
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 15.0),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
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
              Flexible(
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
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  onPressed: () async {
                    var form = formKey.currentState;
                    if (form.validate()) {
                      scaffoldKey.currentState.showSnackBar(
                          SnackBar(content: Text('Accesso al server...')));
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
