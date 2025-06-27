class Ticket {
  final String id;
  final String summary;
  final String description;
  final String projectKey;

  Ticket({
    required this.id,
    required this.summary,
    required this.description,
    required this.projectKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'summary': summary,
      'description': description,
      'projectKey': projectKey,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      summary: map['summary'],
      description: map['description'],
      projectKey: map['projectKey'],
    );
  }
}
