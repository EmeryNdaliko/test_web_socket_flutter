import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:test_websocket/model/user_model.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  List<UserModel> users = [];

  TextEditingController nameController = TextEditingController();
  String? imagePath;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    EasyLoading.show(status: "Patientez...");
    // Remplacez l'URL par celle de votre API REST pour récupérer les utilisateurs
    final response = await http.get(
      Uri.parse('http://localhost/test_websocket/get_users.php'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        users = data.map((u) => UserModel.fromJson(u)).toList();
        print(users);
      });
    }
    EasyLoading.dismiss();
  }

  Future<void> addUser(String name, String? imagePath) async {
    EasyLoading.show(status: "Patientez...");
    var uri = Uri.parse("http://localhost/test_websocket/new_user.php");
    var request = http.MultipartRequest('POST', uri)..fields['name'] = name;
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    var response = await request.send();
    if (response.statusCode == 200) {
      await getUsers();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
        print('$imagePath');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test send image')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Nom'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: pickImage,
                        child: const Text('Choisir une image'),
                      ),
                      if (imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Image sélectionnée'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (imagePath != null)
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                image: DecorationImage(
                  image: Image.file(File(imagePath!)).image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: users[index].image.isNotEmpty
                      ? Image.network(
                          'http://localhost/test_websocket/uploads/${users[index].image}',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person),
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
        onPressed: () async {
          if (nameController.text.isNotEmpty) {
            await addUser(nameController.text, imagePath);
            nameController.clear();
            setState(() {
              imagePath = null;
            });
          } else {
            EasyLoading.showInfo('Verifier vos donne');
          }
        },
      ),
    );
  }
}
