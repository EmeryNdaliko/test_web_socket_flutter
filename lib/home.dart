import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();

    channel.stream.listen((message) {
      var data = jsonDecode(message);

      if (data['action'] == 'users_list') {
        setState(() {
          users = data['data'];
        });
      }
    });

    // Charger les utilisateurs
    channel.sink.add(jsonEncode({"action": "get_users"}));
  }

  void addUser(String name) {
    channel.sink.add(jsonEncode({"action": "add_user", "name": name}));
    channel.sink.add(jsonEncode({"action": "get_users"})); // rafraîchir
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('WebSocket + MySQL')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(users[index]['name']));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: controller)),
                  ElevatedButton(
                    onPressed: () {
                      addUser(controller.text);
                      controller.clear();
                    },
                    child: Text("Ajouter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
