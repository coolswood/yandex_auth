import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'yandex_auth_method_channel.dart';

import 'src/models/yandex_auth_result.dart';

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

  Future<YandexAuthResult?> signIn() {
    throw UnimplementedError('signIn() has not been implemented.');
  }
}
