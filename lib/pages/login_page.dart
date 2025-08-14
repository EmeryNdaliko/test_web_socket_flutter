import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_websocket/controller/controller.dart';
import 'package:test_websocket/model/user_model.dart';
import 'package:test_websocket/pages/user_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final UserController userController = Get.put(UserController());

  LoginPage({super.key});

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void _login() async {
    final user = UserModel.build(
      name: nameController.text,
      password: passwordController.text,
    );
    final name = nameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = "Le nom est requis.";
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Génération d'un ID factice (à remplacer par serveur si possible)
      final int fakeId = DateTime.now().millisecondsSinceEpoch % 100000;

      // Création de l'utilisateur courant
      userController.currentUser.value = UserModel.fromJson({
        'id': fakeId,
        'name': name,
        'image': '', // optionnel
      });

      // Connexion au WebSocket
      // userController.connectWebSocket(fakeId, name);

      // Navigation vers l'écran utilisateur
      Get.off(() => UserPage());
    } catch (e) {
      errorMessage.value = "Erreur lors de la connexion : $e";
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Connexion",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                Text(
                  "Connectez-vous sur iko_chat",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Mot de pase",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.key),
                  ),
                ),
                const SizedBox(height: 10),
                if (errorMessage.value.isNotEmpty)
                  Text(errorMessage.value, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : _login,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
