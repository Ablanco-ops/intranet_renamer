import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intranet_renamer/common.dart';
import 'package:intranet_renamer/pdf_extractor.dart';
import 'package:intranet_renamer/providers/data_provider.dart';
import 'package:intranet_renamer/zip_processor.dart';
import 'package:provider/provider.dart';

import '../exceptions.dart';
import '../widgets/excel_expansion_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<DataProvider>(context);

    dataProvider.getPreferences();

    return Scaffold(
        appBar: AppBar(title: const Text('Renombrador Hijolusa')),
        drawer: Drawer(
          child: ListView(children: [
            const DrawerHeader(child: Text('Configuración')),
            ListTile(
              title: const Text('Carpeta de salida'),
              subtitle: Text(dataProvider.outputPath),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: dataProvider.setOutputPath,
              ),
            ),
            ListTile(
              title: const Text('Carpeta de entrada'),
              subtitle: Text(dataProvider.inputPath),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: dataProvider.setInputPath,
              ),
            ),
            ListTile(
              title: const Text('Excel de empleados'),
              subtitle: Text(dataProvider.excelPath),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: dataProvider.setExcelPath,
              ),
            ),
            const ExcelExpansion()
          ]),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.height * 0.6,
                    child: Stack(alignment: Alignment.center, children: [
                      Card(
                        child: ListView.builder(
                            itemCount: dataProvider.listaEmpleados.length,
                            itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    tileColor: dataProvider
                                            .listaEmpleados[index].files.isEmpty
                                        ? Colors.red[200]
                                        : Colors.green[200],
                                    title: Text(dataProvider
                                        .listaEmpleados[index].nombre),
                                    subtitle: Text(
                                        dataProvider.listaEmpleados[index].id),
                                  ),
                                )),
                      ),
                      Positioned(
                        child: dataProvider.processing
                            ? const CircularProgressIndicator()
                            : const SizedBox(),
                      )
                    ]),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.2,
                        height: size.height * 0.25,
                        child: Card(
                            child: ListView(
                          children: [
                            ListTile(
                              title: Center(
                                  child: Text(
                                'Empleados',
                                style: Theme.of(context).textTheme.headline5,
                              )),
                            ),
                            ListTile(
                              title: const Text('Empleados totales'),
                              trailing: Text(dataProvider.listaEmpleados.length
                                  .toString()),
                            ),
                          ],
                        )),
                      ),
                      SizedBox(
                        width: size.width * 0.2,
                        height: size.height * 0.25,
                        child: DropTarget(
                          onDragDone: (file) async {
                            dataProvider.showProgressIndicator();
                            if (file.files.length != 1) {
                              Excepciones.tooManyFiles(context);
                            } else if (!file.files[0].name.endsWith('zip') &&
                                !file.files[0].name.endsWith('ZIP')) {
                              Excepciones.incorrectFile(context);
                            } else {
                              await clearDirectory(dataProvider.inputPath);
                              try {
                                final zip = ZipProcessor(
                                    outPath: dataProvider.outputPath,
                                    inPath: dataProvider.inputPath);
                                await compute(
                                    zip.extractFile, file.files[0].path);
                                dataProvider.countWorkingFiles();
                              } catch (e) {
                                print(e);
                                Excepciones.decodingError(context);
                              }
                            }
                            dataProvider.showProgressIndicator();
                          },
                          onDragEntered: (_) => dataProvider.draggingFile(true),
                          onDragExited: (_) => dataProvider.draggingFile(false),
                          child: Card(
                            color: dataProvider.dragging
                                ? Colors.blue[200]
                                : Theme.of(context).cardColor,
                            child: dataProvider.pdfNumber == 0
                                ? Center(
                                    child: Icon(
                                    Icons.folder_zip_rounded,
                                    size: size.height * 0.1,
                                  ))
                                : ListView(children: [
                                    ListTile(
                                      title: Center(
                                          child: Text(
                                        'Documentos',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      )),
                                    ),
                                    ListTile(
                                        title: const Text('Documentos totales'),
                                        trailing: Text(
                                            dataProvider.pdfNumber.toString())),
                                    ListTile(
                                      title: const Text('Documentos asociados'),
                                      trailing: Text(
                                          dataProvider.docAsociados.toString()),
                                    )
                                  ]),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                  child: SizedBox(
                width: size.width * 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton(
                        value: dataProvider.tipoElegido,
                        items: dataProvider.mapaTipos.keys
                            .map<DropdownMenuItem<String>>((key) =>
                                DropdownMenuItem<String>(
                                    value: key, child: Text(key)))
                            .toList(),
                        onChanged: (key) => dataProvider.typeChange(key!)),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            final correcto = dataProvider.readExcel();
                            if (!await correcto) {
                              customSnack(
                                  'No hay entradas en las columnas seleccionadas del archivo Excel',
                                  context);
                            }
                          } catch (e) {
                            Excepciones.excelReadError(context);
                          }
                        },
                        child: const Text('Cargar Empleados')),
                    ElevatedButton(
                        onPressed: () async {
                          final pdfExtractor = PdfExtractor(
                            inputPath: dataProvider.inputPath,
                          );
                          dataProvider.showProgressIndicator();
                          try {
                            final lista = await compute(pdfExtractor.addDoc,
                                dataProvider.listaEmpleados);
                            dataProvider.setListaEmpleados(lista);
                          } catch (e) {
                            print(e);
                            Excepciones.readingPdfError(context);
                          }
                          dataProvider.showProgressIndicator();
                        },
                        child: const Text('Asociar Archivos')),
                    ElevatedButton(
                        onPressed: () async {
                          if (dataProvider.docAsociados > 0) {
                            final zip = ZipProcessor(
                                outPath: dataProvider.outputPath,
                                inPath: dataProvider.inputPath);
                            final data = {
                              'listaEmpleados': dataProvider.listaEmpleados,
                              'tipo': dataProvider
                                  .mapaTipos[dataProvider.tipoElegido]
                            };
                            dataProvider.showProgressIndicator();
                            try {
                              final lista =
                                  await compute(zip.generateZip, data);
                              dataProvider.setListaEmpleados(lista);
                              customSnack(
                                  'Zip generado en ${dataProvider.outputPath}',
                                  context);
                            } catch (e) {
                              Excepciones.renameError(context);
                            }

                            dataProvider.showProgressIndicator();
                          } else {
                            customSnack('No hay documentos asociados', context);
                          }
                        },
                        child: const Text('Generar zip'))
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
