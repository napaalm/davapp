/*
 * auth.dart
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

library api_auth;

import 'dart:convert';
import 'package:davapp/backend/gruppi.dart';
import 'package:davapp/backend/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart' as jose;

class UserInfo {
  String username;
  String nome;
  Gruppo gruppo;

  UserInfo(this.username, this.nome, this.gruppo);
}

class APIAuth extends APIClient {
  static APIAuth _instance;

  String username;
  String password;

  String token;
  UserInfo userInfo;

  static get instance {
    if (_instance == null) {
      return _instance;
    } else {
      throw StateError("APIAuth singleton is not instantiated");
    }
  }

  factory APIAuth(String url, String username, String password) {
    if (_instance != null) {
      throw StateError("APIAuth singleton is already instantiated");
    }
    return _getInstance(url, username, password);
  }

  static _getInstance(String url, String username, String password) {
    return APIAuth._internal(url, username, password);
  }

  APIAuth._internal(String url, String username, String password) : super(url);

  void login() async {
    var response = await apiPost(
        "/login", {"username": this.username, "password": this.password});

    this.token = jsonDecode(response)['access_token'];
    var jws = jose.JsonWebSignature.fromCompactSerialization(this.token);
    var payload = jws.unverifiedPayload.jsonContent;

    this.userInfo = new UserInfo(
        this.username, payload['full_name'], gruppi[payload['gruppo']]);
  }
}
