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

part of 'api_dav.dart';

const Map<String, Gruppo> gruppi = {
  "studenti": Gruppo.studenti,
  "docenti": Gruppo.docenti,
  "genitori": Gruppo.genitori,
};

const Map<Gruppo, String> gruppiInverse = {
  Gruppo.studenti: "studenti",
  Gruppo.docenti: "docenti",
  Gruppo.genitori: "genitori",
};

const Map<int, int> oraOrdinale = {
  08: 1,
  09: 2,
  10: 3,
  11: 4,
  12: 5,
  13: 6,
  14: 7,
};

enum Giorno {
  lunedi,
  martedi,
  mercoledi,
  giovedi,
  venerdi,
  sabato,
  domenica,
}

const Map<String, Giorno> giorni = {
  "lunedì": Giorno.lunedi,
  "martedì": Giorno.martedi,
  "mercoledì": Giorno.mercoledi,
  "giovedì": Giorno.giovedi,
  "venerdì": Giorno.venerdi,
  "sabato": Giorno.sabato,
  "domenica": Giorno.domenica,
};

const Map<Giorno, String> giorniInverse = {
  Giorno.lunedi: "lunedì",
  Giorno.martedi: "martedì",
  Giorno.mercoledi: "mercoledì",
  Giorno.giovedi: "giovedì",
  Giorno.venerdi: "venerdì",
  Giorno.sabato: "sabato",
  Giorno.domenica: "domenica",
};

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
      url: item['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "nome": this.nome,
      "data": this.data.microsecondsSinceEpoch,
      "tipo": gruppiInverse[this.tipo],
      "url": this.url,
    };
  }

  Comunicato.fromMap(Map<String, dynamic> map) {
    this.nome = map["nome"];
    this.data = DateTime.fromMicrosecondsSinceEpoch(map["data"]);
    this.tipo = gruppi[map["tipo"]];
    this.url = map["url"];
  }

  @override
  String toString() =>
      "Comunicato($nome, ${data.toString()}, ${gruppiInverse[tipo]}, $url)";
}

class Docente implements Comparable<Docente> {
  String nome;
  String cognome;

  Docente({this.nome, this.cognome});

  factory Docente.fromJson(Map<String, dynamic> item) {
    return Docente(
      nome: item['nome'],
      cognome: item['cognome'],
    );
  }

  factory Docente.fromStringList(List<String> item) {
    return Docente(
      nome: item[0],
      cognome: item[1],
    );
  }

  @override
  int compareTo(Docente other) {
    if (other.nome == this.nome && other.cognome == this.cognome) return 0;
    if (other.cognome.compareTo(this.cognome) < 0 ||
        other.cognome == this.cognome && other.nome.compareTo(this.nome) < 0)
      return 1;
    return -1;
  }

  @override
  String toString() => "${cognome} ${nome}";

  Map toJson() => {"nome": nome, "cognome": cognome};

  List<String> toStringList() => [nome, cognome];
}

class TimeSpan {
  Duration _inizio;
  Duration _durata;
  Giorno giorno;

  TimeSpan(this.giorno, this._inizio, this._durata);

  factory TimeSpan.fromString(String giorno, String inizio, String durata) {
    List<int> inizioSplit = inizio.split('h').map(int.parse).toList();
    List<int> durataSplit = durata.split('h').map(int.parse).toList();
    return TimeSpan(
        giorni[giorno],
        Duration(hours: inizioSplit[0], minutes: inizioSplit[1]),
        Duration(hours: durataSplit[0], minutes: durataSplit[1]));
  }

  int get ordinale => oraOrdinale[_inizio.inHours];
  String get inizio => _inizio.toString().split(':00.')[0];
  int get durata => _durata.inHours;
  String get durataFormat => '${durata}h';

  @override
  String toString() {
    return '${giorniInverse[giorno]} ${inizio} ${durataFormat}';
  }
}

class Attivita {
  int id;
  TimeSpan orario;
  String mat_cod;
  String materia;
  Docente docente;
  String classe;
  String aula;
  String sede;

  Attivita(
      {this.id,
      this.orario,
      this.mat_cod,
      this.materia,
      this.docente,
      this.classe,
      this.aula,
      this.sede});

  factory Attivita.fromJson(Map<String, dynamic> item) {
    return Attivita(
      id: item['id'],
      orario:
          TimeSpan.fromString(item['giorno'], item['inizio'], item['durata']),
      mat_cod: item['mat_cod'],
      materia: item['materia'],
      docente: Docente(nome: item['doc_nome'], cognome: item['doc_cognome']),
      classe: item['classe'],
      aula: item['aula'],
      sede: item['sede'],
    );
  }

  @override
  String toString() => "$orario: $materia";
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

class NewsElement {
  String title;
  String imageUrl;
  String articleUrl;

  NewsElement(this.title, this.imageUrl, this.articleUrl);
}
