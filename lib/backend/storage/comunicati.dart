/*
 * comunicati.dart
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

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:davapp/backend/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ComunicatiStorage {
  static ComunicatiStorage _instance;

  Database db;
  String downloadPath;
  SplayTreeSet<Comunicato> cache;

  final String dbPath = 'sqlite.db';
  final int dbVersion = 1;
  final String tableComunicati = 'comunicati';
  final String columnNome = 'nome';
  final String columnData = 'data';
  final String columnTipo = 'tipo';
  final String columnURL = 'url';
  final String queryWhere = 'nome = ?, data = ?, tipo = ?';

  static get instance {
    if (_instance != null) {
      return _instance;
    } else {
      throw StateError("ComunicatiStorage singleton is not instantiated");
    }
  }

  static Future<ComunicatiStorage> createInstance() async {
    if (_instance != null) {
      throw StateError("ComunicatiStorage singleton is already instantiated");
    }
    _instance = ComunicatiStorage._internal();
    await _instance._load();
    return _instance;
  }

  ComunicatiStorage._internal();

  void _load() async {
    db = await openDatabase(dbPath, version: dbVersion,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE $tableComunicati ( 
          $columnNome TEXT not null, 
          $columnData INTEGER not null,
          $columnTipo TEXT not null,
          $columnURL TEXT not null,
          PRIMARY KEY ($columnNome, $columnData, $columnTipo),
          UNIQUE ($columnNome, $columnData, $columnTipo, $columnURL)
        )
      ''');
    });
    cache = SplayTreeSet.from(await _getList(), _compare);
    downloadPath = (await Directory(
                (await getApplicationSupportDirectory()).path +
                    "/saved_comunicati/")
            .create(recursive: true))
        .path;
  }

  int _compare(Comunicato c1, Comunicato c2) => c2.data.compareTo(c1.data);

  bool save(Comunicato comunicato) {
    _save(comunicato);
    return cache.add(comunicato);
  }

  Future _save(Comunicato comunicato) async {
    await db.insert(tableComunicati, comunicato.toMap());
    (await DefaultCacheManager().getSingleFile(comunicato.url))
        .copy(downloadPath + _fileName(comunicato));
  }

  bool remove(Comunicato comunicato) {
    _remove(comunicato);
    return cache.remove(comunicato);
  }

  Future _remove(Comunicato comunicato) async {
    await db.delete(tableComunicati,
        where: 'nome = ? AND data = ? AND tipo = ?',
        whereArgs: _whereArgs(comunicato));
    await File(downloadPath + _fileName(comunicato)).delete();
  }

  List<Comunicato> getList([int number]) =>
      cache.toList().sublist(0, min(number ?? cache.length, cache.length));

  Future<List<Comunicato>> _getList() async => (await db.query(tableComunicati,
          columns: ['*'], orderBy: columnData + " DESC"))
      .map((Map<String, dynamic> map) => Comunicato.fromMap(map))
      .toList();

  bool isSaved(Comunicato comunicato) => cache.contains(comunicato);

  Future<bool> isSavedDb(Comunicato comunicato) async =>
      (await db.query(tableComunicati,
              where: queryWhere, whereArgs: _whereArgs(comunicato)))
          .length >
      0;

  String _fileName(Comunicato comunicato) =>
      sha1.convert(utf8.encode(comunicato.toMap().toString())).toString() +
      ".pdf";

  String getPath(Comunicato comunicato) {
    if (!isSaved(comunicato)) throw StateError("$comunicato is not saved");
    return downloadPath + _fileName(comunicato);
  }

  List<dynamic> _whereArgs(Comunicato comunicato) {
    final comunicatoMap = comunicato.toMap();
    return [
      comunicatoMap[columnNome],
      comunicatoMap[columnData],
      comunicatoMap[columnTipo]
    ];
  }

  Future close() async => db.close();
}
