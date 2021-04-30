/*
 * settings_page.dart
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

//TODO: make a function to send the author an email with the app log

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:string_validator/string_validator.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:davapp/backend/api.dart';

const defaultAPIURL = String.fromEnvironment('API_URL');
const defaultAuthURL = String.fromEnvironment('AUTH_URL');

Map<Gruppo, String> groupNames = {
  Gruppo.studenti: "Studente",
  Gruppo.docenti: "Docente",
  Gruppo.genitori: "Genitore",
};

AppBar settingsBar() => AppBar(
      title: const Text('Impostazioni'),
    );

class ThemeDialog extends StatefulWidget {
  ThemeDialog({Key key}) : super(key: key);

  @override
  _ThemeDialogState createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  AdaptiveThemeMode _theme;

  @override
  void initState() {
    super.initState();
    this._theme = AdaptiveTheme.of(context).mode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scegli tema'),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.all(0.0),
          child: ListBody(
            children: <Widget>[
              RadioListTile<AdaptiveThemeMode>(
                title: const Text('Sistema'),
                value: AdaptiveThemeMode.system,
                groupValue: _theme,
                onChanged: (AdaptiveThemeMode value) {
                  setState(() {
                    _theme = value;
                  });
                },
              ),
              RadioListTile<AdaptiveThemeMode>(
                title: const Text('Chiaro'),
                value: AdaptiveThemeMode.light,
                groupValue: _theme,
                onChanged: (AdaptiveThemeMode value) {
                  setState(() {
                    _theme = value;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Scuro'),
                value: AdaptiveThemeMode.dark,
                groupValue: _theme,
                onChanged: (AdaptiveThemeMode value) {
                  setState(() {
                    _theme = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annulla'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Salva'),
          onPressed: () {
            AdaptiveTheme.of(context).setThemeMode(_theme);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ServerAddressDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final SharedPreferences prefs;
  final _APITextFieldController = TextEditingController();
  final _AuthTextFieldController = TextEditingController();

  ServerAddressDialog(this.prefs, {Key key}) : super(key: key) {
    _APITextFieldController.value = _APITextFieldController.value.copyWith(
      text: APIDav.instance.url,
    );
    _AuthTextFieldController.value = _AuthTextFieldController.value.copyWith(
      text: APIAuth.instance.url,
    );
  }

  String validate(String url) {
    if (url.isEmpty) {
      return 'Inserisci un URL';
    }
    if (!isURL(url, {
      'protocols': ['http', 'https']
    })) {
      return 'Inserisci un URL valido!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica indirizzi server'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _APITextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo server webapi-dav',
                ),
                onSaved: (String value) {
                  prefs.setString('api_url', value);
                  APIDav.instance.url = value;
                },
                validator: validate,
              ),
              TextFormField(
                controller: _AuthTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo server di autenticazione',
                ),
                onSaved: (String value) {
                  prefs.setString('login_url', value);
                  APIAuth.instance.url = value;
                },
                validator: validate,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Predefiniti'),
          onPressed: () {
            _APITextFieldController.text = defaultAPIURL;
            _AuthTextFieldController.text = defaultAuthURL;
          },
        ),
        TextButton(
          child: const Text('Annulla'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Salva'),
          onPressed: () {
            final form = formKey.currentState;
            if (form.validate()) {
              form.save();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  final RegExp initials = RegExp(r"\B[a-zA-Z]*|[^a-zA-Z]*");

  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  APIAuth apiAuth;
  APIDav apiDav;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadPreferences();
    this.apiAuth = APIAuth.instance;
    this.apiDav = APIDav.instance;
  }

  void loadPreferences() async {
    this.prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text(
            'Informazioni utente',
          ),
          enabled: false,
          dense: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 28.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(apiAuth.userInfo.name
                        ?.replaceAll(widget.initials, "")
                        ?.toUpperCase()) ??
                    'NC',
              ),
              title: Text(apiAuth.userInfo.name ?? 'Nome Cognome'),
              subtitle: Text((groupNames[apiAuth.userInfo.group] ?? 'Umano') +
                  '\n' +
                  'Accesso effettuato'),
              isThreeLine: true,
              trailing: PopupMenuButton<bool>(
                onSelected: (bool result) async {
                  await prefs.setBool('logged', false);
                  await FlutterSecureStorage().deleteAll();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', ModalRoute.withName('/login'));
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                  PopupMenuItem<bool>(
                    value: true,
                    child: const Text('Esci'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const ListTile(
          title: Text(
            'Aspetto',
          ),
          enabled: false,
          dense: true,
        ),
        ListTile(
          title: const Text('Tema'),
          subtitle: const Text('Cambia il tema predefinito'),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => ThemeDialog(),
            );
          },
        ),
        const ListTile(
          title: Text(
            'Avanzate',
          ),
          enabled: false,
          dense: true,
        ),
        ListTile(
          title: const Text('Modifica server'),
          subtitle: const Text(
              'Specifica gli indirizzi dei server per l\'applicazione'),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return ServerAddressDialog(prefs);
              },
            );
          },
        ),
      ],
    );
  }
}
