import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListaTareasScreen extends StatefulWidget {
  @override
  _ListaTareasScreenState createState() => _ListaTareasScreenState();
}

class _ListaTareasScreenState extends State<ListaTareasScreen> {
  List<dynamic> tareas = [];
  List<dynamic> tareasFiltradas = [];
  String filtro = 'todos';

  final String apiUrl = 'https://68520b0c8612b47a2c0bec23.mockapi.io/tarea';

  @override
  void initState() {
    super.initState();
    _obtenerTareas();
  }

  Future<void> _obtenerTareas() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tareas = data;
          _aplicarFiltro();
        });
      } else {
        _mostrarError('Error al obtener tareas');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _aplicarFiltro() {
    setState(() {
      if (filtro == 'todos') {
        tareasFiltradas = tareas;
      } else if (filtro == 'activos') {
        tareasFiltradas = tareas.where((t) => t['estado'] == false).toList();
      } else if (filtro == 'completados') {
        tareasFiltradas = tareas.where((t) => t['estado'] == true).toList();
      }
    });
  }

  Widget _construirTarea(Map tarea) {
    return ListTile(
      title: Text(tarea['nombre']),
      trailing: IconButton(
        icon: Icon(
          tarea['estado'] ? Icons.check_circle : Icons.radio_button_unchecked,
          color: tarea['estado'] ? Colors.green : Colors.grey,
        ),
        onPressed: () => _cambiarEstadoTarea(tarea),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  filtro = 'todos';
                  _aplicarFiltro();
                },
                child: Text('Todos'),
              ),
              ElevatedButton(
                onPressed: () {
                  filtro = 'activos';
                  _aplicarFiltro();
                },
                child: Text('Activos'),
              ),
              ElevatedButton(
                onPressed: () {
                  filtro = 'completados';
                  _aplicarFiltro();
                },
                child: Text('Completados'),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _obtenerTareas,
              child: ListView.builder(
                itemCount: tareasFiltradas.length,
                itemBuilder: (context, index) =>
                    _construirTarea(tareasFiltradas[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _cambiarEstadoTarea(Map tarea) async {
    final id = tarea['id'];
    final nuevoEstado = !tarea['estado'];

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estado': nuevoEstado}),
      );

      if (response.statusCode == 200) {
        setState(() {
          tarea['estado'] = nuevoEstado;
          _aplicarFiltro();
        });
      } else {
        _mostrarError('Error al actualizar tarea');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    }
  }
}



