/*
 * main_view.dart
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
import 'package:davapp/ui/pages/home_page.dart';

enum Pagina {
  home,
  agenda,
  orari,
  comunicatiStudenti,
  comunicatiGenitori,
  comunicatiDocenti,
  comunicatiSalvati,
  impostazioni,
  informazioniSu,
}

class MenuEntry extends StatelessWidget {
  final bool isSeparator;
  final String label;
  final Pagina page;
  final IconData iconData;
  final String semanticLabel;
  final bool selected;
  final Function handleMenu;

  const MenuEntry(
      {Key key,
      this.isSeparator = false,
      this.label,
      this.page,
      this.iconData,
      this.semanticLabel,
      this.selected = false,
      this.handleMenu})
      : assert(isSeparator != null),
        assert(selected != null),
        assert(isSeparator ||
            handleMenu != null && iconData != null && semanticLabel != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSeparator) {
      return ListTile(
        title: Text(
          this.label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        enabled: false,
      );
    } else {
      return ListTile(
        leading: Icon(
          this.iconData,
          semanticLabel: this.semanticLabel,
        ),
        title: Text(this.label),
        selected: this.selected,
        onTap: () {
          handleMenu(this.page);
          Navigator.pop(context);
        },
      );
    }
  }
}

class MainView extends StatefulWidget {
  final Map<Pagina, Widget> pages = {
    Pagina.home: HomePage(),
  };

  MainView({Key key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Pagina _activePage = Pagina.home;

  void _handleMenu(Pagina page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liceo Da Vinci"),
      ),
      body: widget.pages[_activePage],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Placeholder(
                color: Colors.grey,
              ),
            ),
            MenuEntry(
              label: 'Home',
              page: Pagina.home,
              iconData: Icons.home,
              semanticLabel: 'Pagina iniziale',
              selected: (_activePage == Pagina.home),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              isSeparator: true,
              label: 'Attività',
            ),
            MenuEntry(
              label: 'Agenda del liceo',
              page: Pagina.agenda,
              iconData: Icons.event,
              semanticLabel: 'Agenda del liceo',
              selected: (_activePage == Pagina.agenda),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              label: 'Orari',
              page: Pagina.orari,
              iconData: Icons.schedule,
              semanticLabel: 'Orari',
              selected: (_activePage == Pagina.orari),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              isSeparator: true,
              label: 'Comunicati',
            ),
            MenuEntry(
              label: 'Studenti',
              page: Pagina.comunicatiStudenti,
              iconData: Icons.school,
              semanticLabel: 'Comunicati studenti',
              selected: (_activePage == Pagina.comunicatiStudenti),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              label: 'Genitori',
              page: Pagina.comunicatiGenitori,
              iconData: Icons.people,
              semanticLabel: 'Comunicati genitori',
              selected: (_activePage == Pagina.comunicatiGenitori),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              label: 'Docenti',
              page: Pagina.comunicatiDocenti,
              iconData: Icons.work,
              semanticLabel: 'Comunicati docenti',
              selected: (_activePage == Pagina.comunicatiDocenti),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              label: 'Salvati',
              page: Pagina.comunicatiSalvati,
              iconData: Icons.save,
              semanticLabel: 'Comunicati salvati',
              selected: (_activePage == Pagina.comunicatiSalvati),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              isSeparator: true,
              label: 'Utilità',
            ),
            MenuEntry(
              label: 'Impostazioni',
              page: Pagina.impostazioni,
              iconData: Icons.settings,
              semanticLabel: 'Impostazioni',
              selected: (_activePage == Pagina.impostazioni),
              handleMenu: _handleMenu,
            ),
            MenuEntry(
              label: 'Informazioni su',
              page: Pagina.informazioniSu,
              iconData: Icons.info,
              semanticLabel: 'Informazioni',
              selected: (_activePage == Pagina.informazioniSu),
              handleMenu: _handleMenu,
            ),
          ],
        ),
      ),
    );
  }
}