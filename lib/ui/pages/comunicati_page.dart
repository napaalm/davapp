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

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:davapp/backend/api.dart';
import 'package:http/http.dart' as http;
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

enum ComunicatiType {
  studenti,
  genitori,
  docenti,
  salvati,
}

class ComunicatoView extends StatelessWidget {
  final FileInfo fileInfo;
  final Future<PdfDocument> document;
  final String name;
  final String fileName;
  final bool shareable = true;

  ComunicatoView(this.document, this.fileInfo, this.name, this.fileName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicato'),
        actions: this.shareable
            ? [
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => ShareFilesAndScreenshotWidgets().shareFile(
                        this.name,
                        this.fileName,
                        this.fileInfo.file.readAsBytesSync(),
                        "application/pdf",
                        text: this.fileInfo.originalUrl)),
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

class LazyComunicatiGenerator {
  final RegExp nameRegExp = RegExp(r'^([0-9]*)-(.*)\.pdf');
  final DateFormat dateFormat = DateFormat.yMMMMd('it_IT').add_Hm();

  final Function(int) comunicatiGetter;
  List<Comunicato> comunicatiCache;

  LazyComunicatiGenerator(this.comunicatiGetter) {
    updateCache(20);
  }

  void updateCache([int number]) async {
    this.comunicatiCache = await this.comunicatiGetter(number);
  }

  Widget getComunicato(BuildContext context, int index) {
    if (index == 0) updateCache();
    try {
      final comunicato = comunicatiCache[index];
      final nameRegExpMatch = this.nameRegExp.firstMatch(comunicato.nome);
      final comunicatoNumber = nameRegExpMatch?.group(1) ?? '?';
      final comunicatoName =
          nameRegExpMatch?.group(2)?.replaceAll('_', ' ') ?? '?';
      return Card(
        child: ListTile(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: Center(
              child: Text(
                comunicatoNumber,
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.5),
              ),
            ),
          ),
          title: Text(comunicatoName),
          subtitle:
              Text(dateFormat.format(comunicato.data) ?? 'qualche tempo fa...'),
          trailing: IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () {},
          ),
          isThreeLine: true,
          enabled: true,
          onTap: () async {
            final fileStream = DefaultCacheManager()
                .getFileStream(comunicato.url, withProgress: true);

            FileInfo fileInfo;

            final result = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Apertura documento..."),
                content: StreamBuilder(
                    stream: fileStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return LinearProgressIndicator();
                      }
                      if (snapshot.data is FileInfo) {
                        fileInfo = snapshot.data;
                        Navigator.pop(context);
                        return LinearProgressIndicator(value: 1.0);
                      }
                      return LinearProgressIndicator(
                          value: snapshot.data.progress);
                    }),
              ),
              barrierDismissible: false,
            );

            final document = PdfDocument.openFile(fileInfo.file.path);

            await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) => ComunicatoView(
                      document, fileInfo, comunicatoName, comunicato.nome),
                ));
          },
        ),
      );
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
  };

  ComunicatiPage(ComunicatiType comunicatiType, {Key key}) : super(key: key) {
    this.lazyComunicatiGenerator =
        LazyComunicatiGenerator(this.comunicatiGetter[comunicatiType]);
  }

  @override
  _ComunicatiPageState createState() => _ComunicatiPageState();
}

class _ComunicatiPageState extends State<ComunicatiPage> {
  Future<void> refreshList() async {
    await widget.lazyComunicatiGenerator.updateCache();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.builder(
        itemBuilder: widget.lazyComunicatiGenerator.getComunicato,
      ),
    );
  }
}
