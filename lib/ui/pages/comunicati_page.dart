/*
 * comunicati_page.dart
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
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:davapp/backend/api.dart';
import 'package:davapp/backend/storage/comunicati.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share/share.dart';

enum ComunicatiType {
  studenti,
  genitori,
  docenti,
  salvati,
}

class ComunicatoView extends StatelessWidget {
  final Future<PdfDocument> document;
  final File file;
  final Comunicato comunicato;
  final String name;
  final bool shareable = true; // to be implemented

  ComunicatoView(this.document, this.file, this.comunicato, this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicato'),
        actions: this.shareable
            ? [
                IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      String tempPath = p.join(
                          (await getTemporaryDirectory()).path,
                          this.comunicato.nome);
                      this.file.copy(tempPath);
                      Share.shareFiles(
                        [tempPath],
                        subject: this.name,
                        mimeTypes: ["application/pdf"],
                      );
                    }),
              ]
            : null,
      ),
      body: PdfView(
        controller: PdfController(
          document: this.document,
        ),
      ),
    );
  }
}

class ComunicatoCard extends StatefulWidget {
  Comunicato comunicato;
  String comunicatoNumber;
  String comunicatoName;

  final RegExp nameRegExp = RegExp(r'^([0-9]*)-(.*)\.pdf');
  final DateFormat dateFormat = DateFormat.yMMMMd('it_IT');

  ComunicatoCard(this.comunicato, {Key key}) : super(key: key) {
    final nameRegExpMatch = this.nameRegExp.firstMatch(this.comunicato.nome);
    this.comunicatoNumber = nameRegExpMatch?.group(1) ?? '?';
    this.comunicatoName =
        nameRegExpMatch?.group(2)?.replaceAll('_', ' ') ?? '?';
  }

  @override
  _ComunicatoCardState createState() => _ComunicatoCardState(comunicato);
}

class _ComunicatoCardState extends State<ComunicatoCard> {
  bool isSaved;

  _ComunicatoCardState(Comunicato comunicato)
      : this.isSaved = ComunicatiStorage.instance.isSaved(comunicato);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AspectRatio(
          aspectRatio: 1.0,
          child: Center(
            child: Text(
              widget.comunicatoNumber,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
            ),
          ),
        ),
        title: Text(widget.comunicatoName),
        subtitle: Text(widget.dateFormat.format(widget.comunicato.data) ??
            'qualche tempo fa...'),
        trailing: IconButton(
          icon: this.isSaved ? Icon(Icons.check) : Icon(Icons.save_alt),
          onPressed: this.isSaved
              ? () {
                  ComunicatiStorage.instance.remove(widget.comunicato);
                  setState(() => this.isSaved = false);
                }
              : () {
                  ComunicatiStorage.instance.save(widget.comunicato);
                  setState(() => this.isSaved = true);
                },
        ),
        isThreeLine: true,
        enabled: true,
        onTap: () async {
          File file;
          if (this.isSaved) {
            final path = ComunicatiStorage.instance.getPath(widget.comunicato);
            file = File(path);
          } else {
            final fileStream = DefaultCacheManager().getFileStream(
                widget.comunicato.url,
                withProgress: true,
                headers: {'Authorization': 'Bearer ' + APIAuth.instance.token});
            FileInfo fileInfo;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Apertura documento..."),
                content: StreamBuilder(
                    stream: fileStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      if (snapshot.data is FileInfo) {
                        fileInfo = snapshot.data;
                        Navigator.pop(context);
                        return const LinearProgressIndicator(value: 1.0);
                      }
                      return LinearProgressIndicator(
                          value: snapshot.data.progress);
                    }),
              ),
              barrierDismissible: false,
            );
            file = fileInfo.file;
          }

          final document = PdfDocument.openFile(file.path);

          await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (BuildContext context, _, __) => ComunicatoView(
                    document, file, widget.comunicato, widget.comunicatoName),
              ));
        },
      ),
    );
  }
}

class LazyComunicatiGenerator {
  final Function(int) comunicatiGetter;
  List<Comunicato> comunicatiCache = [];

  LazyComunicatiGenerator(this.comunicatiGetter);

  void refresh() async {
    await _updateCache(20);
    _updateCache();
  }

  void _updateCache([int number]) async {
    this.comunicatiCache = await this.comunicatiGetter(number);
  }

  Widget getComunicato(BuildContext context, int index) {
    try {
      return ComunicatoCard(comunicatiCache[index]);
    } on RangeError {
      return null;
    }
  }
}

AppBar comunicatiBar(String group) => AppBar(
      title: Text('Comunicati ' + group),
    );

class ComunicatiPage extends StatefulWidget {
  LazyComunicatiGenerator lazyComunicatiGenerator;

  final Map<ComunicatiType, Function(int)> comunicatiGetter = {
    ComunicatiType.studenti: APIDav.instance.comunicatiStudenti,
    ComunicatiType.genitori: APIDav.instance.comunicatiGenitori,
    ComunicatiType.docenti: APIDav.instance.comunicatiDocenti,
    ComunicatiType.salvati: ComunicatiStorage.instance.getList,
  };

  ComunicatiPage(ComunicatiType comunicatiType, {Key key}) : super(key: key) {
    this.lazyComunicatiGenerator =
        LazyComunicatiGenerator(this.comunicatiGetter[comunicatiType]);
  }

  @override
  _ComunicatiPageState createState() => _ComunicatiPageState();
}

class _ComunicatiPageState extends State<ComunicatiPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool firstLoading = true;

  Future<void> refreshList() async {
    await widget.lazyComunicatiGenerator.refresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refreshList,
      child: ListView.builder(
        itemBuilder: widget.lazyComunicatiGenerator.getComunicato,
      ),
    );
  }

  // hacky hack to reload the page automatically upon opening

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      this._refreshIndicatorKey.currentState.show();
    });
  }

  @override
  void didUpdateWidget(covariant ComunicatiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      this._refreshIndicatorKey.currentState.show();
    });
  }
}
