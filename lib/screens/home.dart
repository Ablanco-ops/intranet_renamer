import 'package:flutter/material.dart';
import 'package:intranet_renamer/providers/data_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
        appBar: AppBar(title: const Text('Renamer')),
        drawer: Drawer(
          child: ListView(children: [
            const DrawerHeader(child: Text('Configuración')),
            ListTile(
              title: Text('Carpeta de salida'),
              subtitle: Text(dataProvider.outputPath),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: dataProvider.setOutputPath,
              ),
              
            ),
            ListTile(
              title: Text('Carpeta de entrada'),
              subtitle: Text(dataProvider.inputPath
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: dataProvider.setInputPath,
              ),
              
            ),
            ListTile(
              title: Text('Excel de empleados'),
              subtitle: Text(dataProvider.excelPath),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: dataProvider.setExcelPath,
              ),
            ),
          ]),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.6,
                child: Card(
                  child: ListView.builder(
                      itemCount: dataProvider.listaEmpleados.length,
                      itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              tileColor:
                                  dataProvider.listaEmpleados[index].filePath ==
                                          null
                                      ? Colors.red[200]
                                      : Colors.green[200],
                              title: Text(
                                  '${dataProvider.listaEmpleados[index].apellidos}, ${dataProvider.listaEmpleados[index].nombre}'),
                              subtitle:
                                  Text(dataProvider.listaEmpleados[index].id),
                            ),
                          )),
                ),
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
                        onPressed: dataProvider.getArchives, child: const Text('Elegir Zip'))
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
