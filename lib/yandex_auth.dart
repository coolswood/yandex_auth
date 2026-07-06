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
}
