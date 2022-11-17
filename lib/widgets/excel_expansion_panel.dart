import 'package:flutter/material.dart';
import 'package:intranet_renamer/providers/data_provider.dart';
import 'package:provider/provider.dart';

class ExcelExpansion extends StatelessWidget {
  const ExcelExpansion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) => dataProvider.expandExcel(),
      children: [
        ExpansionPanel(
          isExpanded: dataProvider.isExcelExpanded,
            headerBuilder: (context, isExpanded) => const ListTile(
                  title: Text('Configuración del excel'),
                ),
            body: Column(
              children: [ListTile(title: Text('Columna Nombre'),trailing: DropdownButton(
                        value: dataProvider.colNombre,
                        items: dataProvider.mapaExcelNombre.keys
                            .map<DropdownMenuItem<String>>((key) =>
                                DropdownMenuItem<String>(
                                    value: key, child: Text(key)))
                            .toList(),
                        onChanged: (key) => dataProvider.colNombreChange(key!)),),
                        ListTile(title: Text('Columna Id'),trailing: DropdownButton(
                        value: dataProvider.colId,
                        items: dataProvider.mapaExcelId.keys
                            .map<DropdownMenuItem<String>>((key) =>
                                DropdownMenuItem<String>(
                                    value: key, child: Text(key)))
                            .toList(),
                        onChanged: (key) => dataProvider.colIdChange(key!)),)
                        ],
            ))
      ],
    );
  }
}
