import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'yandex_auth_platform_interface.dart';

/// An implementation of [YandexAuthPlatform] that uses method channels.
class MethodChannelYandexAuth extends YandexAuthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('yandex_auth');

  @override
  Future<Map<String, dynamic>?> signIn() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('signIn');
    return result?.cast<String, dynamic>();
  }
}
