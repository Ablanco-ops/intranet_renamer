import 'package:flutter/material.dart';
import 'package:intranet_renamer/data_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Renamer')),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.6,
                child: Card(),
              ),
              SizedBox(
                  child: SizedBox(
                    width: size.width*0.5,
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
                        onChanged: (key) =>
                            dataProvider.typeChange(key!)),
                    ElevatedButton(
                        onPressed: () {}, child: const Text('Empaquetar'))
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
