import 'package:flutter/material.dart';

class CreateContactPage extends StatelessWidget {
  final opciones = ['A', 'B', 'C'];
  CreateContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contact'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tu nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: Text('Selecciona una opción'),
                    //value: opcion,
                    isExpanded: true,
                    items: opciones.map((String valor) {
                      return DropdownMenuItem(
                        value: valor,
                        child: Text(valor),
                      );
                    }).toList(),
                    onChanged: (value) {

                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        // Aquí puedes agregar la lógica para guardar el contacto
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contacto guardado')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          "Guardar Contacto",
                          style: TextStyle(fontSize: 16)
                      )
                  )

                ],
              )
          ),
        ),
      ),
    );
  }
}