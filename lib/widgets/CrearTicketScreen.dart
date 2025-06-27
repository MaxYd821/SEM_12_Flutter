import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrearTicketScreen extends StatefulWidget {
  final List<Map<String, String>> proyectos;

  CrearTicketScreen({required this.proyectos});

  @override
  _CrearTicketScreenState createState() => _CrearTicketScreenState();
}

class _CrearTicketScreenState extends State<CrearTicketScreen> {
  String? _selectedProjectKey;
  String? _selectedIssueTypeId;
  List<Map<String, String>> _issueTypes = [];

  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchIssueTypesForProject(String projectKey) async {
    final url = Uri.parse(
        'https://jiraupn.atlassian.net/rest/api/2/issue/createmeta?projectKeys=$projectKey&expand=projects.issuetypes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic YXJ0dXJvLnVwbmNhakBnbWFpbC5jb206QVRBVFQzeEZmR0YwZFp0T3pkNFVZYVBFbGNZX2lsZEpqbE96em5tMXdIaC1jenB1SDRUWVBQSFN4TkVoUkY0WGdoSlJ4aEJEWHBSSE1UMENxZ0JiUEVHbVRwZXpubmNrSnRCNXBVM2NfSzFJWWgtMktFQzRsb3BGUVB5QmM2dDZIOFExcGlzYWNlaUh3WFR4V25od0ZaVVAwdlZ2X3hiS096VEI5V1RyODBwV05UV0ZWME5NVVdNPUQ0REEyRkNG', // 🔐 Reemplaza con tu token real
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final issuetypes = data['projects'][0]['issuetypes'] as List<dynamic>;

      setState(() {
        _issueTypes = issuetypes
            .map<Map<String, String>>((item) => {
          'id': item['id'],
          'name': item['name'],
        })
            .toList();
        _selectedIssueTypeId = null; // Reinicia si cambias de proyecto
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener tipos de incidencia')),
      );
    }
  }

  void _crearTicket() async {
    if (_selectedProjectKey == null || _selectedIssueTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final url = Uri.parse('https://jiraupn.atlassian.net/rest/api/2/issue');

    final body = {
      "fields": {
        "project": {"key": _selectedProjectKey},
        "summary": _summaryController.text,
        "description": _descriptionController.text,
        "issuetype": {"id": _selectedIssueTypeId}
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic YXJ0dXJvLnVwbmNhakBnbWFpbC5jb206QVRBVFQzeEZmR0YwZFp0T3pkNFVZYVBFbGNZX2lsZEpqbE96em5tMXdIaC1jenB1SDRUWVBQSFN4TkVoUkY0WGdoSlJ4aEJEWHBSSE1UMENxZ0JiUEVHbVRwZXpubmNrSnRCNXBVM2NfSzFJWWgtMktFQzRsb3BGUVB5QmM2dDZIOFExcGlzYWNlaUh3WFR4V25od0ZaVVAwdlZ2X3hiS096VEI5V1RyODBwV05UV0ZWME5NVVdNPUQ0REEyRkNG', // 🔐 Reemplaza con tu token real
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket creado con éxito')),
      );
      Navigator.pop(context);
    } else {
      print('Error: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el ticket')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Selecciona un proyecto',
                  border: OutlineInputBorder(), // Opcional, pero mejora la UI
                ),
                value: _selectedProjectKey,
                onChanged: (value) {
                  setState(() {
                    _selectedProjectKey = value;
                    _issueTypes = []; // Limpia los tipos anteriores mientras carga
                    _selectedIssueTypeId = null;
                  });
                  if (value != null) {
                    fetchIssueTypesForProject(value); // ← llama aquí para cargar los tipos
                  }
                },
                items: widget.proyectos.map((proyecto) {
                  return DropdownMenuItem<String>(
                    value: proyecto['key'],
                    child: Text(proyecto['name']!),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              if (_issueTypes.isNotEmpty)
                DropdownButtonFormField<String>(
                  hint: Text('Selecciona el tipo de incidencia'),
                  value: _selectedIssueTypeId,
                  onChanged: (value) {
                    setState(() {
                      _selectedIssueTypeId = value;
                    });
                  },
                  items: _issueTypes.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo['id'],
                      child: Text(tipo['name']!),
                    );
                  }).toList(),
                ),
              TextField(
                controller: _summaryController,
                decoration: InputDecoration(labelText: 'Resumen'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearTicket,
                child: Text('Crear Ticket'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Regresar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
