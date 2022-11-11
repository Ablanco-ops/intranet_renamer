import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intranet_renamer/pdf_extractor.dart';
import 'package:intranet_renamer/providers/data_provider.dart';
import 'package:intranet_renamer/zip_processor.dart';
import 'package:provider/provider.dart';

import '../exceptions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<DataProvider>(context);
    dataProvider.getPreferences();

    return Scaffold(
        appBar: AppBar(title: const Text('Renamer')),
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
          ]),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height*0.1,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.height * 0.6,
                    child: DropTarget(
                      onDragDone: (file) async {
                        dataProvider.showProgressIndicator();
                        if (file.files.length != 1) {
                          Excepciones.tooManyFiles(context);
                        } else if (!file.files[0].name.endsWith('zip')) {
                          Excepciones.incorrectFile(context);
                        } else {
                          final zip = ZipProcessor(
                              outPath: dataProvider.outputPath,
                              inPath: dataProvider.inputPath);
                          await compute(zip.extractFile, file.files[0].path);
                        }
                        dataProvider.showProgressIndicator();
                      },
                      onDragEntered: (_) => dataProvider.draggingFile(true),
                      onDragExited: (_) => dataProvider.draggingFile(false),
                      child: Stack(alignment: Alignment.center, children: [
                        Card(
                          color: dataProvider.dragging
                              ? Colors.blue[200]
                              : Theme.of(context).cardColor,
                          child: ListView.builder(
                              itemCount: dataProvider.listaEmpleados.length,
                              itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      tileColor: dataProvider
                                              .listaEmpleados[index]
                                              .files
                                              .isEmpty
                                          ? Colors.red[200]
                                          : Colors.green[200],
                                      title: Text(
                                          '${dataProvider.listaEmpleados[index].apellidos}, ${dataProvider.listaEmpleados[index].nombre}'),
                                      subtitle: Text(dataProvider
                                          .listaEmpleados[index].id),
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
                  ),
                  SizedBox(
                      width: size.width * 0.2,
                      height: size.height * 0.4,
                      child: Card(
                          child: ListView(
                        children: [
                          ListTile(
                            title: Text('Empleados'),trailing: Text(dataProvider.listaEmpleados.length.toString()),
                          ),
                          ListTile(title: Text('Documentos asociados'),trailing: Text(dataProvider.numDoc.toString()),)
                        ],
                      )))
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
                        onPressed: dataProvider.readExcel,
                        child: const Text('Cargar Empleados')),
                    ElevatedButton(
                        onPressed: () async {
                          final pdfExtractor = PdfExtractor(
                            inputPath: dataProvider.inputPath,
                          );
                          dataProvider.showProgressIndicator();
                          final lista = await compute(
                              pdfExtractor.addDoc, dataProvider.listaEmpleados);
                          dataProvider.setListaEmpleados(lista);
                          dataProvider.showProgressIndicator();
                        },
                        child: Text('Asociar Archivos'))
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
