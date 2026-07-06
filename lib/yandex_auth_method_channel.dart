import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/exceptions/yandex_auth_exception.dart';
import 'src/models/yandex_auth_result.dart';
import 'yandex_auth_platform_interface.dart';

/// Имя метод-канала, используемого плагином.
///
/// Дублируется в нативном коде (Kotlin/Swift); при изменении обновлять
/// везде одновременно.
const String kYandexAuthChannelName = 'yandex_auth';

/// Реализация [YandexAuthPlatform] поверх method channel.
///
/// Преобразует [PlatformException] из нативного кода в типизированные
/// исключения [YandexAuthException].
class MethodChannelYandexAuth extends YandexAuthPlatform {
  /// Метод-канал для общения с нативной стороной.
  @visibleForTesting
  final methodChannel = const MethodChannel(kYandexAuthChannelName);

  @override
  Future<YandexAuthResult> signIn() async {
    try {
      final result = await methodChannel
          .invokeMethod<Map<dynamic, dynamic>>('signIn');
      if (result == null) {
        // Подстраховка: нативная сторона не должна возвращать null,
        // но если это произошло — трактуем как неизвестную ошибку.
        throw const YandexAuthFailedException(
          code: YandexAuthErrorCode.unknown,
          message: 'Нативная сторона вернула null',
        );
      }
      return YandexAuthResult.fromMap(result.cast<String, dynamic>());
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  /// Маппит [PlatformException] в типизированное исключение Yandex Auth.
  YandexAuthException _mapPlatformException(PlatformException e) {
    final code = YandexAuthErrorCode.fromString(e.code);
    if (code == YandexAuthErrorCode.cancelled) {
      return const YandexAuthCancelledException();
    }
    return YandexAuthFailedException(
      code: code,
      message: e.message,
      details: e.details is String ? e.details as String : e.details?.toString(),
    );
  }
}
