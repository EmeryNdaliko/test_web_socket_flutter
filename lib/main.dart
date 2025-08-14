import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:test_websocket/view/user_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(builder: EasyLoading.init(), home: UserView());
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// void main() {
//   runApp(const MyApp());
// }

// class UserModel {
//   int id;
//   String name;

//   UserModel({required this.id, required this.name});

//   factory UserModel.fromJson(Map<String, dynamic> data) {
//     return UserModel(
//       id: data['id'] ?? 0,
//       name: data['name'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {'id': id, 'name': name};
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<StatefulWidget> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
//   List<UserModel> users = [];

//   TextEditingController nameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();

//     channel.stream.listen((message) {
//       try {
//         var data = jsonDecode(message);

//         // Si c'est une réponse avec la liste des utilisateurs
//         if (data is Map && data.containsKey('users')) {
//           List<UserModel> updatedUsers = (data['users'] as List)
//               .map((u) => UserModel.fromJson(u))
//               .toList();

//           setState(() {
//             users = updatedUsers;
//           });
//         }

//       } catch (e) {
//         print("Erreur parsing JSON : $e");
//       }
//     });

//     // Charger la liste dès le démarrage
//     getUsers();
//   }

//   void getUsers() {
//     channel.sink.add(jsonEncode({"action": "get_users"}));
//   }

//   void addUser(Map<String, dynamic> data) {
//     channel.sink.add(jsonEncode({"action": "add_users", "data": data}));
//     // Après ajout, on redemande la liste
//     getUsers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('WebSocket + MySQL')),
//         body: Column(
//           children: [
//             Form(
//               key: _formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextFormField(
//                   controller: nameController,
//                   decoration: const InputDecoration(hintText: 'Nom'),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(users[index].name),
//                     subtitle: Text("ID: ${users[index].id}"),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.send),
//           onPressed: () {
//             if (nameController.text.isNotEmpty) {
//               var user = UserModel(id: 0, name: nameController.text);
//               addUser(user.toJson());
//               nameController.clear();
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     channel.sink.close();
//     super.dispose();
//   }
// }
