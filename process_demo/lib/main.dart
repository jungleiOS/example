import 'dart:io';

import 'package:flutter/material.dart';

void main() {
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('process demo'),
      ),
      body: Center(
        child: MaterialButton(
            onPressed: () {
              runShell();
            },
            child: const Text('12323')),
      ),
    );
  }

  void runShell() async {
    ProcessResult results = await Process.run('ls', ['-l']);
    debugPrint(results.toString());
    debugPrint(results.stdout);
  }
}
