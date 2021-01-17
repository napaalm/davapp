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
import 'package:davapp/ui/pages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:davapp/backend/api.dart';

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
  final Map<Pagina, Widget> bars = {
    Pagina.home: homeBar(),
    Pagina.comunicatiStudenti: comunicatiBar('studenti'),
    Pagina.comunicatiGenitori: comunicatiBar('genitori'),
    Pagina.comunicatiDocenti: comunicatiBar('docenti'),
    Pagina.comunicatiSalvati: comunicatiBar('salvati'),
    Pagina.orari: orariBar(),
    Pagina.informazioniSu: aboutBar(),
    Pagina.impostazioni: settingsBar(),
  };

  MainView({Key key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Pagina _activePage = Pagina.home;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    while (true) {
      try {
        if (!await APIDav.instance.isOnline()) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/', ModalRoute.withName('/'));
          return;
        }
      } catch (e) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/', ModalRoute.withName('/'));
        return;
      }
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Widget _getPage(Pagina page) {
    switch (page) {
      case Pagina.home:
        return HomePage();
      case Pagina.comunicatiStudenti:
        return ComunicatiPage(ComunicatiType.studenti);
      case Pagina.comunicatiGenitori:
        return ComunicatiPage(ComunicatiType.genitori);
      case Pagina.comunicatiDocenti:
        return ComunicatiPage(ComunicatiType.docenti);
      case Pagina.comunicatiSalvati:
        return ComunicatiPage(ComunicatiType.salvati);
      case Pagina.orari:
        return OrariPage();
      case Pagina.informazioniSu:
        return AboutPage();
      case Pagina.impostazioni:
        return SettingsPage();
      default:
        return Text("y0u 4r3 4 1337 h4x0r");
    }
  }

  void _handleMenu(Pagina page) {
    setState(() {
      _activePage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.bars[_activePage],
      body: _getPage(_activePage),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(0.0),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.all(20.0),
                child: SvgPicture.asset('assets/icon/logo_rect.svg',
                    semanticsLabel: 'Logo applicazione'),
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
