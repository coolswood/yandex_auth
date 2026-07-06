import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'yandex_auth_method_channel.dart';

import 'src/models/yandex_auth_result.dart';

/// Платформенный интерфейс для реализации [YandexAuth].
///
/// Конкретные реализации (например [MethodChannelYandexAuth])
/// регистрируются через [instance].
abstract class YandexAuthPlatform extends PlatformInterface {
  /// Constructs a YandexAuthPlatform.
  YandexAuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static YandexAuthPlatform _instance = MethodChannelYandexAuth();

  /// The default instance of [YandexAuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelYandexAuth].
  static YandexAuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [YandexAuthPlatform] when
  /// they register themselves.
  static set instance(YandexAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Запускает авторизацию через Яндекс.
  ///
  /// См. документацию на [YandexAuth.signIn].
  Future<YandexAuthResult> signIn() {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  /// Сбрасывает состояние авторизации на стороне SDK.
  ///
  /// На iOS очищает кеш JWT внутри Yandex Login SDK. На Android — no-op,
  /// так как Yandex Auth SDK для Android stateless и не хранит токены;
  /// приложение должно удалить токен из своего хранилища самостоятельно.
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }
}
