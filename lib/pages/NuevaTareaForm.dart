import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ListaTareasScreen.dart';


class NuevaTareaForm extends StatefulWidget {
  @override
  _NuevaTareaFormState createState() => _NuevaTareaFormState();
}

class _NuevaTareaFormState extends State<NuevaTareaForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _estado = false;

  final String apiUrl = 'https://68520b0c8612b47a2c0bec23.mockapi.io/tarea';

  Future<void> _enviarTarea() async {
    final String nombre = _nombreController.text;

    final Map<String, dynamic> data = {
      'nombre': nombre,
      'estado': _estado,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea creada con éxito')),
        );
        _formKey.currentState!.reset();
        _nombreController.clear();
        setState(() => _estado = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la tarea')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la tarea'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text(_estado ? 'Completado' : 'Activo'),
                value: _estado,
                onChanged: (bool value) {
                  setState(() {
                    _estado = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _enviarTarea();
                  }
                },
                child: Text('Guardar Tarea'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListaTareasScreen()),
                  );
                },
                child: Text('Ver Lista de Tareas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
