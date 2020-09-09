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

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:davapp/backend/api.dart';
import 'package:http/http.dart' as http;
import 'package:native_pdf_view/native_pdf_view.dart';

enum ComunicatiType {
  studenti,
  genitori,
  docenti,
  salvati,
}

class ComunicatoView extends StatelessWidget {
  final Future<PdfDocument> pdfDocumentFuture;

  ComunicatoView(this.pdfDocumentFuture);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicato'),
      ),
      body: PdfView(
        controller: PdfController(
          document: this.pdfDocumentFuture,
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
      var comunicato = comunicatiCache[index];
      return Card(
        child: ListTile(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: Center(
              child: Text(
                this.nameRegExp.firstMatch(comunicato.nome)?.group(1) ?? '?',
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.5),
              ),
            ),
          ),
          title: Text(
            this
                    .nameRegExp
                    .firstMatch(comunicato.nome ?? '')
                    ?.group(2)
                    ?.replaceAll('_', ' ') ??
                '?',
          ),
          subtitle:
              Text(dateFormat.format(comunicato.data) ?? 'qualche tempo fa...'),
          trailing: IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () {},
          ),
          isThreeLine: true,
          enabled: true,
          onTap: () async {
            http.Response response = await http.get(comunicato.url ??
                'https://www.antonionapolitano.eu/file_not_found.pdf');
            await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) =>
                      ComunicatoView(PdfDocument.openData(response.bodyBytes)),
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
