import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hello/DatabaseHelper.dart';
import 'package:flutter_hello/Ticket.dart';

class TicketsScreen extends StatefulWidget {
  final String projectKey;

  TicketsScreen({required this.projectKey});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final response = await http.post(
        Uri.parse('https://jiraupn.atlassian.net/rest/api/2/search'),
        headers: {
          'Authorization': 'Basic YXJ0dXJvLnVwbmNhakBnbWFpbC5jb206QVRBVFQzeEZmR0YwZFp0T3pkNFVZYVBFbGNZX2lsZEpqbE96em5tMXdIaC1jenB1SDRUWVBQSFN4TkVoUkY0WGdoSlJ4aEJEWHBSSE1UMENxZ0JiUEVHbVRwZXpubmNrSnRCNXBVM2NfSzFJWWgtMktFQzRsb3BGUVB5QmM2dDZIOFExcGlzYWNlaUh3WFR4V25od0ZaVVAwdlZ2X3hiS096VEI5V1RyODBwV05UV0ZWME5NVVdNPUQ0REEyRkNG', // Reemplaza con tu token
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jql": "project = ${widget.projectKey}",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final issues = data['issues'] as List;

        List<Ticket> tickets = issues.map((issue) {
          return Ticket(
            id: issue['id'],
            summary: issue['fields']['summary'] ?? '',
            description: issue['fields']['description'] ?? '',
            projectKey: widget.projectKey,
          );
        }).toList();

        final db = DatabaseHelper.instance;
        for (var ticket in tickets) {
          await db.insertTicket(ticket);
        }

        setState(() => _tickets = tickets);
      } else {
        _loadFromLocal();
      }
    } catch (_) {
      _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final db = DatabaseHelper.instance;
    final localTickets = await db.getTicketsByProject(widget.projectKey);
    setState(() => _tickets = localTickets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tickets - ${widget.projectKey}')),
      body: _tickets.isEmpty
          ? Center(child: Text('No hay tickets disponibles'))
          : ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final t = _tickets[index];
          return ListTile(
            title: Text(t.summary),
            subtitle: Text(t.description),
          );
        },
      ),
    );
  }
}
