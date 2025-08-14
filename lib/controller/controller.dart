import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_websocket/model/user_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UserController extends GetxController {
  var currentUser = UserModel().obs;
  WebSocketChannel? channel;

  bool get isLoggedIn => currentUser.value.id != 0;

  @override
  void onInit() {
    _loadSession();
    super.onInit();
  }

  /// 🔹 Connexion / login
  Future<void> login(UserModel user) async {
    currentUser.value = user;
    await _saveSession(user);
    _connectWebSocket();
  }

  /// 🔹 Déconnexion
  Future<void> logout() async {
    currentUser.value = UserModel.build(id: 0, name: '', image: '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // supprime la session
    disconnect();
  }

  /// 🔹 Sauvegarder session complète dans une seule clé
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  /// 🔹 Charger session
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userStr));
      _connectWebSocket();
    }
  }

  /// 🔹 Connexion WebSocket
  void _connectWebSocket() {
    if (channel != null) return; // déjà connecté
    channel = IOWebSocketChannel.connect("ws://localhost:8080");

    channel!.stream.listen(
      (message) {
        print("📥 Message reçu : $message");
      },
      onError: (error) {
        print("❌ Erreur WebSocket : $error");
      },
      onDone: () {
        print("🔌 Déconnecté du WebSocket");
        channel = null;
      },
    );

    channel!.sink.add(
      jsonEncode({"action": "login", "data": currentUser.value.toJson()}),
    );
  }

  void disconnect() {
    channel?.sink.close();
    channel = null;
  }
}
