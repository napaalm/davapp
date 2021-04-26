/*
 * orari_page.dart
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

AppBar orariBar() => AppBar(
      title: Text('Orari'),
    );

enum TipoOrario { classe, docente }

class OrarioView extends StatelessWidget {
  List<List<Attivita>> orarioMat = List.generate(6, (_) => List());
  bool docenteMode;

  OrarioView(List<Attivita> orario, {this.docenteMode = false, Key key})
      : super(key: key) {
    int hour = 1;
    Giorno giorno = Giorno.lunedi;
    orario.forEach((el) {
      if (el.orario.giorno != giorno) {
        hour = 1;
        giorno = el.orario.giorno;
      }
      while (hour < el.orario.ordinale) {
        orarioMat[giorno.index].add(null);
        hour++;
      }
      orarioMat[giorno.index].add(el);
      hour += el.orario.durata;
    });
    orarioMat.forEach((col) {
      int sum = 0;
      col.forEach((el) => sum += el?.orario?.durata ?? 1);
      while (sum < 7) {
        // non ci sono sicuramente giornate da più 7 ore
        col.add(null); // aggiunge le ore di padding
        sum++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      children: orarioMat
          .asMap()
          .entries
          .map((col) => Expanded(
                // itera sui giorni mantenendo un indice (col.key)
                child: Column(
                    children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                // ottiene il giorno della settimana a partire dall'indice
                                giorniInverse[Giorno.values[col.key]]
                                    .substring(0, 3),
                                style:
                                    Theme.of(context).textTheme.subtitle2.apply(
                                          color: (now.weekday - 1 == col.key)
                                              ? Theme.of(context).indicatorColor
                                              : Theme.of(context).disabledColor,
                                        ),
                              ),
                            ),
                          )
                        ] +
                        col.value
                            .map((el) => (el != null)
                                ? Expanded(
                                    flex: el.orario.durata * 2,
                                    child: InkWell(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(el.materia),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    (docenteMode)
                                                        ? Text('Classe',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption)
                                                        : Text('Docente',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption),
                                                    (docenteMode)
                                                        ? Text(
                                                            el.classe ?? 'N.D.')
                                                        : Text(el.docente
                                                                .toString() ??
                                                            'N.D.'),
                                                    SizedBox(height: 10),
                                                    Text('Aula',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption),
                                                    Text(el.aula ?? 'N.D.'),
                                                    SizedBox(height: 10),
                                                    Text('Durata',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption),
                                                    Text(
                                                        el.orario.durataFormat),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        margin: const EdgeInsets.all(2.5),
                                        child: SizedBox.expand(
                                          child: Container(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              (docenteMode && el.classe != null)
                                                  ? '${el.classe} - ${el.aula}'
                                                  : el.materia,
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .body2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(flex: 2, child: Container()))
                            .toList()),
              ))
          .toList(),
    );
  }
}

class PersonalOrarioDialog extends StatefulWidget {
  final SharedPreferences prefs;
  Function(List<Attivita>, bool) updateCallback;
  PersonalOrarioDialog(this.prefs, this.updateCallback, {Key key})
      : super(key: key);

  @override
  _PersonalOrarioDialogState createState() => _PersonalOrarioDialogState();
}

class _PersonalOrarioDialogState extends State<PersonalOrarioDialog> {
  final formKey = GlobalKey<FormState>();
  Widget _dropdownWidget = Container();
  String _selectedClasse;
  Docente _selectedDocente;
  TipoOrario _selected;

  void _setDropdownClasse() {
    _dropdownWidget = DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        value: _selectedClasse,
        hint: Text('Scegli una classe'),
        items: OrariPage.classi?.map<DropdownMenuItem<String>>((String classe) {
              return DropdownMenuItem<String>(
                value: classe,
                child: Text(classe),
              );
            })?.toList() ??
            List<DropdownMenuItem<String>>(),
        onChanged: (String value) {
          _selectedClasse = value;
        },
        onSaved: (String value) async {
          await widget.prefs.setString('orario_classe', value);
          await widget.prefs.setBool('orario_is_docente', false);
          await widget.prefs.setBool('saved_orario', true);
          widget.updateCallback(await APIDav.instance.orario(value), false);
        },
        validator: (String value) => (value == null) ? '' : null,
      ),
    );
  }

  void _setDropdownDocente() {
    _dropdownWidget = DropdownButtonHideUnderline(
      child: DropdownButtonFormField<Docente>(
        hint: Text('Scegli un docente'),
        value: _selectedDocente,
        items: OrariPage.docenti
                ?.map<DropdownMenuItem<Docente>>((Docente docente) {
              return DropdownMenuItem<Docente>(
                value: docente,
                child: Text(docente.toString()),
              );
            })?.toList() ??
            List<DropdownMenuItem<Docente>>(),
        onChanged: (Docente value) {
          _selectedDocente = value;
        },
        onSaved: (Docente value) async {
          await widget.prefs
              .setStringList('orario_docente', value.toStringList());
          await widget.prefs.setBool('orario_is_docente', true);
          await widget.prefs.setBool('saved_orario', true);
          widget.updateCallback(
              await APIDav.instance.orarioDocente(value), true);
        },
        validator: (Docente value) => (value == null) ? '' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleziona il tuo orario'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: ListBody(
            children: <Widget>[
              ListTile(
                title: const Text('Classe'),
                onTap: () {
                  setState(() {
                    _selected = TipoOrario.classe;
                    _setDropdownClasse();
                  });
                },
                leading: Radio(
                  value: TipoOrario.classe,
                  groupValue: _selected,
                  onChanged: (TipoOrario value) {
                    setState(() {
                      _selected = value;
                      _setDropdownClasse();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Docente'),
                onTap: () {
                  setState(() {
                    _selected = TipoOrario.docente;
                    _setDropdownDocente();
                  });
                },
                leading: Radio(
                  value: TipoOrario.docente,
                  groupValue: _selected,
                  onChanged: (TipoOrario value) {
                    setState(() {
                      _selected = value;
                      _setDropdownDocente();
                    });
                  },
                ),
              ),
              _dropdownWidget,
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

class OrariPage extends StatefulWidget {
  static List<String> classi;
  static List<Docente> docenti;

  static void _loadClassi() async {
    classi = (await APIDav.instance.classi());
    classi.sort();
  }

  static void _loadDocenti() async {
    docenti = (await APIDav.instance.docenti());
    docenti.sort();
  }

  OrariPage({Key key}) : super(key: key) {
    OrariPage._loadClassi();
    OrariPage._loadDocenti();
  }

  @override
  _OrariPageState createState() => _OrariPageState();
}

class _OrariPageState extends State<OrariPage> {
  int _selectedIndex = 0;
  String _selectedClasse;
  Docente _selectedDocente;
  List<Attivita> attivitaPersonale;
  List<Attivita> attivitaClasse;
  List<Attivita> attivitaDocente;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    this.prefs = await SharedPreferences.getInstance();
    await loadPersonalOrario();
  }

  void loadPersonalOrario() async {
    if (await prefs.getBool('saved_orario') ?? false) {
      if (!await prefs.getBool('orario_is_docente')) {
        final classe = await prefs.getString('orario_classe');
        attivitaPersonale = await APIDav.instance.orario(classe);
        setState(() {
          tabsBodies[0] = OrarioView(attivitaPersonale);
        });
      } else {
        final docente =
            Docente.fromStringList(await prefs.getStringList('orario_docente'));
        final List<Attivita> attivitaDocente =
            await APIDav.instance.orarioDocente(docente);
        setState(() {
          tabsBodies[0] = OrarioView(attivitaPersonale, docenteMode: true);
        });
      }
    }
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  List<Widget> tabsBodies = <Widget>[
    Container(),
    Container(),
    Container(),
  ];

  Widget _getBar(int index) {
    switch (index) {
      case 0:
        return AppBar(
          title: Text('Personale'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.sync),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return PersonalOrarioDialog(prefs,
                          (List<Attivita> attivita, bool isDocente) {
                        setState(() {
                          attivitaPersonale = attivita;
                          tabsBodies[0] = OrarioView(attivitaPersonale,
                              docenteMode: isDocente);
                        });
                      });
                    },
                  );
                }),
          ],
        );
      case 1:
        return AppBar(
          title: Text('Classe'),
          actions: <Widget>[
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClasse,
                  hint: Text('...'),
                  onChanged: (String newValue) async {
                    _selectedClasse = newValue;
                    attivitaClasse = await APIDav.instance.orario(newValue);
                    setState(() {
                      tabsBodies[1] = OrarioView(attivitaClasse);
                    });
                  },
                  items: OrariPage.classi
                          ?.map<DropdownMenuItem<String>>((String classe) {
                        return DropdownMenuItem<String>(
                          value: classe,
                          child: Text(classe),
                        );
                      })?.toList() ??
                      List<DropdownMenuItem<String>>(),
                ),
              ),
            ),
          ],
        );
      case 2:
        return AppBar(
          title: Text('Docente'),
          actions: <Widget>[
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Docente>(
                  value: _selectedDocente,
                  hint: Text('Scegli un docente'),
                  onChanged: (Docente newValue) async {
                    _selectedDocente = newValue;
                    attivitaDocente =
                        await APIDav.instance.orarioDocente(_selectedDocente);
                    setState(() {
                      tabsBodies[2] =
                          OrarioView(attivitaDocente, docenteMode: true);
                    });
                  },
                  items: OrariPage.docenti
                          ?.map<DropdownMenuItem<Docente>>((Docente docente) {
                        return DropdownMenuItem<Docente>(
                          value: docente,
                          child: Text(docente.toString()),
                        );
                      })?.toList() ??
                      List<DropdownMenuItem<Docente>>(),
                ),
              ),
            ),
          ],
        );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getBar(_selectedIndex),
      body: tabsBodies.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personale',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Classi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Docenti',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
