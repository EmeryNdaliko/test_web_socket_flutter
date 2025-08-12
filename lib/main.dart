// // import 'dart:io';
// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const MaterialApp(home: Home());
// //   }
// // }

// // class Home extends StatefulWidget {
// //   const Home({super.key});

// //   @override
// //   State<Home> createState() => _HomeState();
// // }

// // class _HomeState extends State<Home> {
// //   WebSocket? channel;
// //   Stream? socketStream;
// //   String statusMessage = 'Connecting...';

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetch();
// //   }

// //   TextEditingController inputController = TextEditingController();

// //   Future<void> fetch() async {
// //     try {
// //       channel = await WebSocket.connect(
// //         'ws://localhost:8080',
// //       ).timeout(const Duration(seconds: 10));

// //       // Transformer en stream broadcast pour multiples écoutes
// //       socketStream = channel!.asBroadcastStream();

// //       setState(() {
// //         statusMessage = 'Connected to WebSocket';
// //       });
// //     } catch (e) {
// //       setState(() {
// //         statusMessage = 'Connection error: $e';
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('WebSocket Test')),
// //       body: socketStream == null
// //           ? Center(child: Text(statusMessage))
// //           : Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Column(
// //                 children: [
// //                   TextFormField(
// //                     controller: inputController,
// //                     decoration: InputDecoration(hint: Text('Votre message')),
// //                   ),
// //                   StreamBuilder(
// //                     stream: socketStream,
// //                     builder: (context, snapshot) {
// //                       if (snapshot.hasError) {
// //                         return Center(child: Text('Error: ${snapshot.error}'));
// //                       }
// //                       if (!snapshot.hasData) {
// //                         return Center(child: Text(statusMessage));
// //                       }
// //                       return Center(
// //                         child: Text(
// //                           snapshot.data.toString(),
// //                           style: const TextStyle(fontSize: 18),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: sendData,
// //         child: const Icon(Icons.send),
// //       ),
// //     );
// //   }

// //   void sendData() {
// //     if (inputController.text.isNotEmpty) {
// //       channel?.add(inputController.text);
// //     } else {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// void main() {
//   runApp(MyApp());
// }

// class UserModel {
//   int id = 0;
//   String name = '';

//   UserModel({required this.id, required this.name});

//   factory UserModel.fromJson(Map<String, dynamic> data) {
//     return UserModel(id: data['id'], name: data['mane']);
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

//   @override
//   void initState() {
//     super.initState();

//     channel.stream.listen((message) {
//       // var data = jsonDecode(message);
//       var data = message;

//       // if (data['action'] == 'users_list') {
//       //   setState(() {
//       //     users = data['data'];
//       //   });
//       // }

//       print(data);
//     });

//     // Charger les utilisateurs
//     channel.sink.add(jsonEncode({"action": "get_users"}));
//   }

//   void addUser(Map<String, dynamic> data) {
//     channel.sink.add(jsonEncode({"action": "add_user", "data": data}));
//     channel.sink.add(jsonEncode({"action": "get_users"})); // rafraîchir
//   }

//   TextEditingController idController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('WebSocket + MySQL')),
//         body: Column(
//           children: [
//             Form(
//               key: _formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     // TextFormField(
//                     //   controller: idController,
//                     //   decoration: InputDecoration(hint: Text('id')),
//                     // ),
//                     TextFormField(
//                       controller: nameController,
//                       decoration: InputDecoration(hint: Text('name')),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(title: Text(users[index].name));
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.send),
//           onPressed: () {
//             var user = UserModel(id: 0, name: nameController.text);
//             addUser(user.toJson());
//             nameController.clear();
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


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class UserModel {
  int id;
  String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
  List<UserModel> users = [];

  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    channel.stream.listen((message) {
      try {
        var data = jsonDecode(message);

        // Si c'est une réponse avec la liste des utilisateurs
        if (data is Map && data.containsKey('users')) {
          List<UserModel> updatedUsers = (data['users'] as List)
              .map((u) => UserModel.fromJson(u))
              .toList();

          setState(() {
            users = updatedUsers;
          });
        }

      } catch (e) {
        print("Erreur parsing JSON : $e");
      }
    });

    // Charger la liste dès le démarrage
    getUsers();
  }

  void getUsers() {
    channel.sink.add(jsonEncode({"action": "get_users"}));
  }

  void addUser(Map<String, dynamic> data) {
    channel.sink.add(jsonEncode({"action": "add_users", "data": data}));
    // Après ajout, on redemande la liste
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('WebSocket + MySQL')),
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nom'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index].name),
                    subtitle: Text("ID: ${users[index].id}"),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.send),
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              var user = UserModel(id: 0, name: nameController.text);
              addUser(user.toJson());
              nameController.clear();
            }
          },
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
