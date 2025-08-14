import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:test_websocket/model/user_model.dart';

class ChatPage extends StatefulWidget {
  final UserModel user; // L'autre participant

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final WebSocketChannel channel;
  final TextEditingController messageController = TextEditingController();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final currentUser = UserModel();

  @override
  void initState() {
    super.initState();

    // 🔹 Connexion WebSocket
    channel = IOWebSocketChannel.connect('ws://10.211.158.14:8080');

    // 🔹 Login automatique côté serveur
    channel.sink.add(
      jsonEncode({
        'action': 'login',
        'data': {
          'id': 1, // TODO current user info
          'name': 'emery ndalos',
        },
      }),
    );

    // 🔹 Récupération historique des messages
    channel.sink.add(
      jsonEncode({
        'action': 'get_messages',
        'data': {'user1': 1, 'user2': widget.user.id}, // curent user id
      }),
    );

    // 🔹 Écoute des messages entrants
    channel.stream.asBroadcastStream().listen((rawMessage) {
      final decoded = jsonDecode(rawMessage);

      switch (decoded['action']) {
        case 'load_messages':
          for (var m in decoded['data']) {
            messages.add({
              'text': m['message'],
              'isMine': m['sender_id'] == 1, // TODO current user id
              'id': m['id'],
            });
          }
          break;

        case 'new_message':
          final data = decoded['data'];
          messages.add({
            'text': data['message'],
            'isMine': data['from'] == 1, // TODO current user id
          });
          break;

        case 'delete_message':
          final msgId = decoded['data']['id'];
          messages.removeWhere((m) => m['id'] == msgId);
          break;
      }
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    channel.sink.add(
      jsonEncode({
        'action': 'send_message',
        'data': {
          'from': 1, // TODO current User id
          'to': widget.user.id,
          'text': text,
        },
      }),
    );

    messages.add({'text': text, 'isMine': true});
    messageController.clear();
  }

  void deleteMessage(int id) {
    channel.sink.add(
      jsonEncode({
        'action': 'delete_message',
        'data': {'id': id},
      }),
    );
    messages.removeWhere((m) => m['id'] == id);
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade400,
        foregroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),

          child: Icon(Icons.keyboard_backspace),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _buildUserAvatar(widget.user),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.name, style: const TextStyle(fontSize: 18)),
                Text('en ligne', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return GestureDetector(
                    onLongPress: msg['isMine']
                        ? () => deleteMessage(msg['id'] ?? 0)
                        : null,
                    child: _buildMessageBubble(msg['text'], msg['isMine']),
                  );
                },
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.cyan[400] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMine ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.cyan,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.send_1_bold,
                color: Colors.white,
                size: 24,
              ),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    if ((user.image ?? "").isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(
          'http://10.211.158.14/test_websocket/uploads/${user.image}',
        ),
      );
    }
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.black12,
      child: Icon(Iconsax.user_bold, color: Colors.grey),
    );
  }
}
