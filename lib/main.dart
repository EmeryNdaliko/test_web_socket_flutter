import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  WebSocket? channel;
  Stream? socketStream;
  String statusMessage = 'Connecting...';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      channel = await WebSocket.connect('ws://localhost:8080')
          .timeout(const Duration(seconds: 10));

      // Transformer en stream broadcast pour multiples écoutes
      socketStream = channel!.asBroadcastStream();

      setState(() {
        statusMessage = 'Connected to WebSocket';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Connection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Test')),
      body: socketStream == null
          ? Center(child: Text(statusMessage))
          : StreamBuilder(
              stream: socketStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text(statusMessage));
                }
                return Center(
                  child: Text(
                    snapshot.data.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          channel?.add('Hello from Flutter!');
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
