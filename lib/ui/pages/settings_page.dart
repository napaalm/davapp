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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:davapp/backend/api.dart';

Map<Gruppo, String> groupNames = {
  Gruppo.studenti: "Studente",
  Gruppo.docenti: "Docente",
  Gruppo.genitori: "Genitore",
};

AppBar settingsBar() => AppBar(
      title: Text('Impostazioni'),
    );

class SettingsPage extends StatefulWidget {
  final RegExp initials = RegExp(r"\B[a-zA-Z]*|[^a-zA-Z]*");

  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  APIAuth apiAuth;
  SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    loadPreferences();
    this.apiAuth = APIAuth.instance;
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
            'Avanzate',
          ),
          enabled: false,
          dense: true,
        ),
        ListTile(
          subtitle: TextField(
            decoration: InputDecoration(
              labelText: 'Indirizzo webapi',
            ),
          ),
        ),
        ListTile(
          subtitle: TextField(
            decoration: InputDecoration(
              labelText: 'Indirizzo server di autenticazione',
            ),
          ),
        ),
      ],
    );
  }
}
