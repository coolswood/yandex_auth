import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_auth/yandex_auth.dart';
import 'package:yandex_auth/yandex_auth_platform_interface.dart';
import 'package:yandex_auth/yandex_auth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYandexAuthPlatform
    with MockPlatformInterfaceMixin
    implements YandexAuthPlatform {
  @override
  Future<YandexAuthResult> signIn() =>
      Future.value(YandexAuthResult(token: '42'));

  @override
  Future<void> logout() => Future.value();
}

void main() {
  final YandexAuthPlatform initialPlatform = YandexAuthPlatform.instance;

  test('$MethodChannelYandexAuth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYandexAuth>());
  });

  test('signIn возвращает результат из платформенной реализации', () async {
    YandexAuth yandexAuthPlugin = YandexAuth();
    MockYandexAuthPlatform fakePlatform = MockYandexAuthPlatform();
    YandexAuthPlatform.instance = fakePlatform;

    final result = await yandexAuthPlugin.signIn();
    expect(result.token, '42');
  });
}
