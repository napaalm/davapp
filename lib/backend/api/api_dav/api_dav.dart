/*
 * davapi.dart
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

import 'dart:convert';
import 'package:davapp/backend/api.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart' as jose;

part 'types.dart';

class APIDav extends APIClient {
  static APIDav _instance;
  APIAuth auth;

  final RegExp regexClasse = RegExp(r"^[1-5][a-zA-Z]\$");

  static get instance {
    if (_instance != null) {
      return _instance;
    } else {
      throw StateError("APIDav singleton is not instantiated");
    }
  }

  factory APIDav(String url, APIAuth auth) {
    if (_instance != null) {
      throw StateError("APIDav singleton is already instantiated");
    }
    return _getInstance(url, auth);
  }

  static _getInstance(String url, APIAuth auth) {
    return _instance = APIDav._internal(url, auth);
  }

  APIDav._internal(String url, this.auth) : super(url);

  Map<String, String> get headers {
    var headers = {'Authorization': 'Bearer ' + auth.token};
    headers.addAll(super.headers);

    return headers;
  }

  @override
  Future<dynamic> apiGet(String path) async {
    try {
      return await super.apiGet(path);
    } on http.ClientException {
      await auth.login();
      return await super.apiGet(path);
    }
  }

  @override
  Future<dynamic> apiPost(String path, dynamic body) async {
    try {
      return await super.apiPost(path, body);
    } on http.ClientException {
      await auth.login();
      return await super.apiPost(path, body);
    }
  }

  Future<List<Docente>> docenti() async => (await apiGet("/docenti"))
      .map((dynamic obj) => Docente.fromJson(obj as Map))
      .cast<Docente>()
      .toList();

  Future<List<String>> classi() async =>
      (await apiGet("/classi")).cast<String>();

  Future<List<AgendaEvent>> agenda(DateTime dopo, DateTime prima) async =>
      (await apiPost("/agenda", {
        "dopo": dopo.millisecondsSinceEpoch ~/ 1000,
        "prima": prima.millisecondsSinceEpoch ~/ 1000
      }))
          .map((dynamic obj) => AgendaEvent.fromJson(obj as Map))
          .cast<AgendaEvent>()
          .toList();

  Future<List<Comunicato>> comunicatiGenitori([int number]) async =>
      (await apiGet(
              "/comunicati/genitori" + (number != null ? "/$number" : "")))
          .map((dynamic obj) => Comunicato.fromJson(obj as Map))
          .cast<Comunicato>()
          .toList();

  Future<List<Comunicato>> comunicatiDocenti([int number]) async =>
      (await apiGet("/comunicati/docenti" + (number != null ? "/$number" : "")))
          .map((dynamic obj) => Comunicato.fromJson(obj as Map))
          .cast<Comunicato>()
          .toList();

  Future<List<Comunicato>> comunicatiStudenti([int number]) async =>
      (await apiGet(
              "/comunicati/studenti" + (number != null ? "/$number" : "")))
          .map((dynamic obj) => Comunicato.fromJson(obj as Map))
          .cast<Comunicato>()
          .toList();

  Future<List<Attivita>> orario([String classe]) async {
    if (classe != null && !regexClasse.hasMatch(classe)) {
      throw FormatException("Formato classe invalido");
    }

    return (await apiGet("/orario" + (classe != null ? "/classe/$classe" : "")))
        .map((dynamic obj) => Attivita.fromJson(obj as Map))
        .cast<Attivita>()
        .toList();
  }

  Future<List<Attivita>> orarioDocente(Docente docente) async =>
      (await apiPost("/orario/docente", docente))
          .map((dynamic obj) => Attivita.fromJson(obj as Map))
          .cast<Attivita>()
          .toList();

  Future<ApiMessage> about() async =>
      ApiMessage.fromJson(await apiGet("/about"));

  Future<ApiMessage> version() async =>
      ApiMessage.fromJson(await apiGet("/version"));

  Future<bool> isOnline() async {
    try {
      var response = await client.get(this.apiURL + "/teapot");

      if (response.statusCode == 418) {
        return true;
      } else {
        return false;
      }
    } on http.ClientException {
      return false;
    }
  }
}
