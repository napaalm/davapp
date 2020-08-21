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
import 'package:davapp/backend/api_client.dart';
import 'package:davapp/backend/gruppi.dart';
import 'package:davapp/backend/api_auth/api_auth.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart' as jose;

part 'types.dart';

class APIDav extends APIClient {
  static APIDav _instance;
  APIAuth auth;

  final RegExp regexClasse = RegExp("^[1-5][a-zA-Z]\$");

  static get instance {
    if (_instance == null) {
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

  APIDav._internal(String url, APIAuth auth) : super(url);

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

  Future<Iterable<Docente>> docenti() async =>
      (await apiGet("/docenti")).map((Map obj) => Docente.fromJson(obj));

  Future<Iterable<String>> classi() async => await apiGet("/classi");

  Future<Iterable<AgendaEvent>> agenda(DateTime dopo, DateTime prima) async =>
      (await apiPost("/agenda", {
        "dopo": dopo.millisecondsSinceEpoch ~/ 1000,
        "prima": prima.millisecondsSinceEpoch ~/ 1000
      }))
          .map((Map obj) => AgendaEvent.fromJson(obj));

  Future<Iterable<Comunicato>> comunicatiGenitori([int number]) async =>
      (await apiGet(
              "/comunicati/genitori" + (number != null ? "/$number" : "")))
          .map((Map obj) => Comunicato.fromJson(obj));

  Future<Iterable<Comunicato>> comunicatiDocenti([int number]) async =>
      (await apiGet("/comunicati/docenti" + (number != null ? "/$number" : "")))
          .map((Map obj) => Comunicato.fromJson(obj));

  Future<Iterable<Comunicato>> comunicatiStudenti([int number]) async =>
      (await apiGet(
              "/comunicati/studenti" + (number != null ? "/$number" : "")))
          .map((Map obj) => Comunicato.fromJson(obj));

  Future<Iterable<Attivita>> orario([String classe]) async {
    if (classe != null && !regexClasse.hasMatch(classe)) {
      throw FormatException("Formato classe invalido");
    }

    return (await apiGet("/orario" + (classe != null ? "/classe/$classe" : "")))
        .map((Map obj) => Attivita.fromJson(obj));
  }

  Future<Iterable<Attivita>> orarioDocente(Docente docente) async =>
      (await apiPost("/orario/docente", docente))
          .map((Map obj) => Attivita.fromJson(obj));

  Future<ApiMessage> about() async =>
      ApiMessage.fromJson(await apiGet("/about"));

  Future<ApiMessage> version() async =>
      ApiMessage.fromJson(await apiGet("/version"));

  Future<bool> isOnline() async {
    try {
      var response =
          await client.get(this.apiURL + "/teapot", headers: this.headers);

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
