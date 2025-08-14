import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_websocket/controller/controller.dart';
import 'package:test_websocket/model/user_model.dart';
import 'package:test_websocket/pages/chat_page.dart';
import 'package:test_websocket/pages/my_navigation_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final List<UserModel> users = [];
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? imagePath;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    EasyLoading.show(status: "Chargement...");
    try {
      final response = await http.get(
        Uri.parse('http://10.211.158.14/test_websocket/get_users.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users.clear();
          users.addAll(data.map((u) => UserModel.fromJson(u)));
        });
      } else {
        EasyLoading.showError("Erreur ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.showError("Erreur réseau : $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> addUser(String name, String? imagePath) async {
    EasyLoading.show(status: "Envoi...");
    try {
      final uri = Uri.parse("http://10.211.158.14/test_websocket/new_user.php");
      final request = http.MultipartRequest('POST', uri)..fields['name'] = name;

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        await getUsers();
      } else {
        EasyLoading.showError("Erreur lors de l'envoi");
      }
    } catch (e) {
      EasyLoading.showError("Erreur réseau : $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => imagePath = image.path);
    }
  }

  Widget _buildUserAvatar(UserModel user) {
    if ((user.image ?? '').isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(
          'http://10.211.158.14/test_websocket/uploads/${user.image}',
        ),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey[300],
      child: const Icon(Iconsax.gallery_add_bold, color: Colors.grey),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        hoverColor: Colors.transparent,
        leading: _buildUserAvatar(user),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("ID: ${user.id}"),
        onTap: () => Get.to(() => ChatPage(user: user)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.withAlpha(20),

      appBar: AppBar(
        backgroundColor: Colors.cyan.shade400,
        foregroundColor: Colors.white,
        title: Text(
          'Iko chat...',
          style: TextTheme.of(context).titleLarge!.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),

      body: Column(
        children: [
          // Barre ajout utilisateur
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,

                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Nom',
                      prefixIcon: Icon(Iconsax.user_outline),
                      filled: true,
                      fillColor: Colors.cyan.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    // controller: nameController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Rechercher',
                      prefixIcon: Icon(Bootstrap.search),
                      filled: true,
                      fillColor: Colors.cyan.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Choisir une image'),
                      ),
                      if (imagePath != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('Image sélectionnée'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (imagePath != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(File(imagePath!)),
            ),
          // Liste utilisateurs
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) => _buildUserCard(users[index]),
            ),
          ),

          MyNavigationBar(),
        ],
      ),

      // floatingActionButton: FloatingActionButton.small(
      //   backgroundColor: Colors.cyan.shade400,
      //   foregroundColor: Colors.white,
      //   child: const Icon(Iconsax.user_add_outline),
      //   onPressed: () async {
      //     if (nameController.text.isNotEmpty) {
      //       await addUser(nameController.text, imagePath);
      //       nameController.clear();
      //       setState(() => imagePath = null);
      //     } else {
      //       EasyLoading.showInfo('Vérifiez vos données');
      //     }
      //   },
      // ),
    );
  }
}
