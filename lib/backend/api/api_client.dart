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
  _StringUriException(String message, [String uri])
      : super(message, (uri != null) ? Uri.dataFromString(uri) : null);
}

class UnauthorizedException extends _StringUriException {
  UnauthorizedException(String message, [String uri]) : super(message, uri);
}

class BadRequestException extends _StringUriException {
  BadRequestException(String message, [String uri])
      : super("Bad request: " + message, uri);
}

class InternalServerErrorException extends _StringUriException {
  InternalServerErrorException(String message, [String uri])
      : super("Errore interno al server: " + message, uri);
}

abstract class APIClient {
  String apiURL;
  http.Client client;

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void set url(String url) {
    if (url.endsWith('/')) {
      this.apiURL = url.substring(0, url.length - 1); // remove trailing slash
    } else {
      this.apiURL = url;
    }
  }

  APIClient(String url) {
    this.url = url;
    client = new http.Client();
  }

  Future<dynamic> apiGet(String path) async {
    var response = await client.get(this.apiURL + path, headers: this.headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(response.body, this.apiURL + path);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      throw BadRequestException(response.body, this.apiURL + path);
    } else {
      throw InternalServerErrorException(response.body, this.apiURL + path);
    }
  }

  Future<dynamic> apiPost(String path, dynamic body) async {
    var response = await client.post(this.apiURL + path,
        headers: this.headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(response.body, this.apiURL + path);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      throw BadRequestException(response.body, this.apiURL + path);
    } else {
      throw InternalServerErrorException(response.body, this.apiURL + path);
    }
  }

  void close() {
    client.close();
  }
}
