/*
 * types.dart
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

part of api_dav;

class ApiMessage {
  int codice;
  String info;

  ApiMessage({this.codice, this.info});

  factory ApiMessage.fromJson(Map<String, dynamic> item) {
    return ApiMessage(
      codice: item['codice'],
      info: item['info'],
    );
  }
}

class Comunicato {
  String nome;
  DateTime data;
  Gruppo tipo;
  String url;

  Comunicato({this.nome, this.data, this.tipo, this.url});

  factory Comunicato.fromJson(Map<String, dynamic> item) {
    return Comunicato(
      nome: item['nome'],
      data: DateTime.parse(item['data']),
      tipo: gruppi[item['tipo']],
    );
  }
}

class Docente {
  String nome;
  String cognome;

  Docente({this.nome, this.cognome});

  factory Docente.fromJson(Map<String, dynamic> item) {
    return Docente(
      nome: item['nome'],
      cognome: item['cognome'],
    );
  }

  Map toJson() => {"nome": nome, "cognome": cognome};
}

class Attivita {
  int id;
  String durata;
  String mat_cod;
  String materia;
  Docente docente;
  String classe;
  String aula;
  String giorno;
  String inizio;
  String sede;

  Attivita(
      {this.id,
      this.durata,
      this.mat_cod,
      this.materia,
      this.docente,
      this.classe,
      this.aula,
      this.giorno,
      this.inizio,
      this.sede});

  factory Attivita.fromJson(Map<String, dynamic> item) {
    return Attivita(
      id: item['id'],
      durata: item['durata'],
      mat_cod: item['mat_cod'],
      materia: item['materia'],
      docente: Docente(nome: item['doc_nome'], cognome: item['doc_cognome']),
      classe: item['classe'],
      aula: item['aula'],
      giorno: item['giorno'],
      inizio: item['inizio'],
      sede: item['sede'],
    );
  }
}

class Orario {
  String nome;
  Attivita attivita;

  Orario({this.nome, this.attivita});

  factory Orario.fromJson(Map<String, dynamic> item) {
    return Orario(
      nome: item['nome'],
      attivita: Attivita.fromJson(item['attivita']),
    );
  }
}

class AgendaEvent {
  DateTime inizio;
  DateTime fine;
  String contenuto;
  String titolo;

  AgendaEvent({this.inizio, this.fine, this.contenuto, this.titolo});

  factory AgendaEvent.fromJson(Map<String, dynamic> item) {
    return AgendaEvent(
      inizio: DateTime.fromMillisecondsSinceEpoch(item['inizio'] * 1000),
      fine: DateTime.fromMillisecondsSinceEpoch(item['fine'] * 1000),
      contenuto: item['contenuto'],
      titolo: item['titolo'],
    );
  }
}
