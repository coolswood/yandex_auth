import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'yandex_auth_platform_interface.dart';

import 'src/models/yandex_auth_result.dart';

/// An implementation of [YandexAuthPlatform] that uses method channels.
class MethodChannelYandexAuth extends YandexAuthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('yandex_auth');

  @override
  Future<YandexAuthResult?> signIn() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('signIn');
    if (result == null) return null;
    return YandexAuthResult.fromMap(result.cast<String, dynamic>());
  }
}
