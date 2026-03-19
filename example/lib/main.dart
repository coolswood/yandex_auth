import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yandex_auth/yandex_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _yandexAuthPlugin = YandexAuth();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      final result = await _yandexAuthPlugin.signIn();
      if (result != null) {
        platformVersion = 'Token: ${result.token}';
      } else {
        platformVersion = 'Sign in returned null';
      }
    } on PlatformException catch (e) {
      platformVersion = 'Failed to sign in: ${e.message}';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Status: $_platformVersion\n'),
              ElevatedButton(
                onPressed: initPlatformState,
                child: const Text('Sign In again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
