/*
 * api_client.dart
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
import 'package:http/http.dart' as http;

class _StringUriException extends http.ClientException {
  _StringUriException(String message, [Uri uri]) : super(message, uri);
}

class UnauthorizedException extends _StringUriException {
  UnauthorizedException(String message, [Uri uri]) : super(message, uri);
}

class BadRequestException extends _StringUriException {
  BadRequestException(String message, [Uri uri])
      : super("Bad request: " + message, uri);
}

class InternalServerErrorException extends _StringUriException {
  InternalServerErrorException(String message, [Uri uri])
      : super("Errore interno al server: " + message, uri);
}

abstract class APIClient {
  Uri apiUri;
  http.Client client;

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void set url(String url) => this.apiUri = Uri.parse(url);

  void get url => this.apiUri.toString();

  APIClient(String url) {
    this.url = url;
    client = new http.Client();
  }

  Future<dynamic> apiGet(String path) async {
    var uri = this.apiUri.replace(path: this.apiUri.path + path);
    var response = await client.get(uri, headers: this.headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(response.body, uri);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      throw BadRequestException(response.body, uri);
    } else {
      throw InternalServerErrorException(response.body, uri);
    }
  }

  Future<dynamic> apiPost(String path, dynamic body) async {
    var uri = this.apiUri.replace(path: this.apiUri.path + path);
    var response =
        await client.post(uri, headers: this.headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(response.body, uri);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      throw BadRequestException(response.body, uri);
    } else {
      throw InternalServerErrorException(response.body, uri);
    }
  }

  void close() {
    client.close();
  }
}
