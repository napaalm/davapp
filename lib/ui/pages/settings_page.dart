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
import 'package:validators/validators.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:davapp/backend/api.dart';

Map<Gruppo, String> groupNames = {
  Gruppo.studenti: "Studente",
  Gruppo.docenti: "Docente",
  Gruppo.genitori: "Genitore",
};

AppBar settingsBar() => AppBar(
      title: Text('Impostazioni'),
    );

class ServerAddressDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final SharedPreferences prefs;

  ServerAddressDialog(this.prefs, {Key key}) : super(key: key);

  String validate(String url) {
    if (url.isEmpty) {
      return 'Inserisci un URL';
    }
    if (!isURL(url, protocols: ['http', 'https'])) {
      return 'Inserisci un URL valido!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifica indirizzi server'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                initialValue: APIDav.instance.apiURL,
                decoration: InputDecoration(
                  labelText: 'Indirizzo server webapi-dav',
                ),
                onSaved: (String value) {
                  prefs.setString('api_url', value);
                  APIDav.instance.url = value;
                },
                validator: validate,
              ),
              TextFormField(
                initialValue: APIAuth.instance.apiURL,
                decoration: InputDecoration(
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
          child: Text('Annulla'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Salva'),
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
          title: Text(
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
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', ModalRoute.withName('/login'));
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                  PopupMenuItem<bool>(
                    value: true,
                    child: Text('Esci'),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListTile(
          title: Text(
            'Aspetto',
          ),
          enabled: false,
          dense: true,
        ),
        ListTile(
          title: Text('Tema applicazione'),
          subtitle: Text('Cambia il tema predefinito'),
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => ThemeConsumer(child: ThemeDialog()));
          },
        ),
        ListTile(
          title: Text(
            'Avanzate',
          ),
          enabled: false,
          dense: true,
        ),
        ListTile(
          title: Text('Modifica server'),
          subtitle:
              Text('Specifica gli indirizzi dei server per l\'applicazione'),
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
