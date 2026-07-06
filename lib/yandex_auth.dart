/// Плагин Yandex Auth для Flutter.
///
/// Предоставляет единый интерфейс [YandexAuth] для авторизации через
/// Yandex Login SDK на Android и iOS.
///
/// {@tool snippet}
/// ```dart
/// import 'package:yandex_auth/yandex_auth.dart';
///
/// final yandexAuth = YandexAuth();
///
/// Future<void> login() async {
///   try {
///     final result = await yandexAuth.signIn();
///     // работаем с result.token
///   } on YandexAuthCancelledException {
///     // пользователь отменил
///   } on YandexAuthFailedException catch (e) {
///     // ошибка, см. e.code
///   }
/// }
/// ```
/// {@end-tool}
library;

import 'src/models/yandex_auth_result.dart';
import 'yandex_auth_platform_interface.dart';

export 'src/exceptions/yandex_auth_exception.dart';
export 'src/models/yandex_auth_result.dart';

/// Точка входа в плагин Yandex Auth.
///
/// Запускает нативный процесс авторизации через Yandex Login SDK.
/// Возвращает [YandexAuthResult] с токеном при успехе либо выбрасывает
/// типизированное исключение [YandexAuthException] при неудаче.
class YandexAuth {
  /// Запускает авторизацию через Яндекс.
  ///
  /// При успехе возвращает [YandexAuthResult] с токеном.
  /// Если пользователь отменил вход — выбрасывает
  /// [YandexAuthCancelledException]. Прочие ошибки (сбой SDK, нет
  /// Activity, ошибка активации) — [YandexAuthFailedException].
  Future<YandexAuthResult> signIn() {
    return YandexAuthPlatform.instance.signIn();
  }

  /// Сбрасывает состояние авторизации.
  ///
  /// На iOS очищает кеш JWT внутри Yandex Login SDK. На Android метод
  /// является no-op, поскольку Yandex Auth SDK для Android stateless
  /// и не хранит токены — приложение должно удалить токен из своего
  /// хранилища самостоятельно. При ошибке (только iOS) выбрасывает
  /// [YandexAuthFailedException].
  Future<void> logout() {
    return YandexAuthPlatform.instance.logout();
  }
}
