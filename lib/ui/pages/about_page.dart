/*
 * about_page.dart
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
import 'package:about/about.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

const sourceURL = String.fromEnvironment('SOURCE_URL');

PackageInfo packageInfo;
String version;
String buildNumber;

AppBar aboutBar() => AppBar(
      title: const Text('Informazioni su'),
    );

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AboutContent(
      applicationVersion: 'Versione ' + version + ', build #' + buildNumber,
      applicationIcon: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset('assets/icon/logo_round.svg',
            semanticsLabel: 'Logo dell\'applicazione'),
      ),
      applicationLegalese: 'Copyright © Antonio Napolitano, 2020-2021',
      applicationDescription: Text(
          'Applicazione ufficiale del Liceo Scientifico Statale "Leonardo Da Vinci" di Treviso.'),
      children: <Widget>[
        const MarkdownPageListTile(
          icon: const Icon(Icons.description),
          title: const Text('Vedi licenza'),
          filename: 'assets/LICENSE.md',
        ),
        ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Codice sorgente'),
            onTap: () {
              launch(sourceURL);
            }),
        ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Pagina web dell\'autore'),
            onTap: () {
              launch('https://www.antonionapolitano.eu/');
            }),
//        ListTile(
//            leading: Icon(Icons.attach_money),
//            title: Text('Sostieni lo sviluppo'),
//            onTap: () {
//            }),
        const LicensesPageListTile(
          title: Text('Licenze open source'),
          icon: Icon(Icons.favorite),
        ),
      ],
    );
  }
}
