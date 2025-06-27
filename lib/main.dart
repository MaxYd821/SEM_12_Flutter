import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_hello/widgets/CrearTicketScreen.dart';

import 'TicketsScreen.dart';

void main() {
  runApp(ProjectListApp());
}

class ProjectListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jira Projects',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: ProjectListScreen(),
    );
  }
}

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Map<String, String>>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = cargarProyectos();
  }

  Future<List<Map<String, String>>> cargarProyectos() async {
    try {
      final proyectos = await fetchProjects();
      await guardarProyectosLocalmente(proyectos);
      return proyectos;
    } catch (_) {
      return await cargarProyectosLocalmente();
    }
  }

  Future<List<Map<String, String>>> fetchProjects() async {
    final url = Uri.parse('https://jiraupn.atlassian.net/rest/api/2/project');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic YXJ0dXJvLnVwbmNhakBnbWFpbC5jb206QVRBVFQzeEZmR0YwZFp0T3pkNFVZYVBFbGNZX2lsZEpqbE96em5tMXdIaC1jenB1SDRUWVBQSFN4TkVoUkY0WGdoSlJ4aEJEWHBSSE1UMENxZ0JiUEVHbVRwZXpubmNrSnRCNXBVM2NfSzFJWWgtMktFQzRsb3BGUVB5QmM2dDZIOFExcGlzYWNlaUh3WFR4V25od0ZaVVAwdlZ2X3hiS096VEI5V1RyODBwV05UV0ZWME5NVVdNPUQ0REEyRkNG', // tu token real
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<Map<String, String>>((project) => {
        'key': project['key'],
        'name': project['name'],
      }).toList();
    } else {
      throw Exception('Error al cargar los proyectos');
    }
  }

  Future<void> guardarProyectosLocalmente(List<Map<String, String>> proyectos) async {
    final prefs = await SharedPreferences.getInstance();
    final String proyectosJson = jsonEncode(proyectos);
    await prefs.setString('proyectos_guardados', proyectosJson);
  }

  Future<List<Map<String, String>>> cargarProyectosLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    final proyectosJson = prefs.getString('proyectos_guardados');
    if (proyectosJson != null) {
      final List<dynamic> lista = jsonDecode(proyectosJson);
      return lista.cast<Map<String, dynamic>>().map((map) {
        return {
          'key': map['key'].toString(),
          'name': map['name'].toString(),
        };
      }).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyectos Jira'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay proyectos disponibles.'));
          }

          final projects = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.folder_open, color: Colors.indigo),
                  title: Text(
                    project['name']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketsScreen(projectKey: project['key']!),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Map<String, String>>>(
        future: _projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return FloatingActionButton(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearTicketScreen(proyectos: snapshot.data!),
                  ),
                );
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}


/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: NuevaTareaForm(

      ),
    );
  }
}

class MyOtherHomePage extends StatelessWidget {

  final String title;
  final Color backgroundColor;

  const MyOtherHomePage({
    super.key,
    required this.title,
    required this.backgroundColor,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      title: 'Flutter Demo Home Page',
                    )
                ),
              );
            },
            child: Text("Cambio de pantalla")
        )
      ),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _currentIndex = 0;

  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    fetchData();

  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void fetchData() async {
    final url = Uri.parse('https://67ff051e58f18d7209efd099.mockapi.io/contacts');
    final response = await http.get(url);
    setState(() {
      _data = json.decode(response.body);
    });

  }

  Widget getBody() {
    if (_currentIndex == 0) {
      return Text("Vista 0");
    } if (_currentIndex == 1) {
      return Text("Vista 1");
    }
    return ListContactFragment(data: _data);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateContactPage(),
            ),
          );
        },
        tooltip: 'Crear Contacto',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      )
    );
  }
}*/
