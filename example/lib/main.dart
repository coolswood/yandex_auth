import 'package:flutter/material.dart';

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
  String _status = 'Нажмите «Sign In» для запуска авторизации';
  final _yandexAuthPlugin = YandexAuth();

  Future<void> _signIn() async {
    try {
      final result = await _yandexAuthPlugin.signIn();
      if (!mounted) return;
      setState(() {
        _status = 'Token: ${result.token}';
      });
    } on YandexAuthCancelledException {
      if (!mounted) return;
      setState(() => _status = 'Авторизация отменена пользователем');
    } on YandexAuthFailedException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Ошибка (${e.code.value}): ${e.message}';
      });
    }
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Status: $_status'),
              ),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
