import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_auth/yandex_auth.dart';
import 'package:yandex_auth/yandex_auth_platform_interface.dart';
import 'package:yandex_auth/yandex_auth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYandexAuthPlatform
    with MockPlatformInterfaceMixin
    implements YandexAuthPlatform {
  @override
  Future<Map<String, dynamic>?> signIn() => Future.value({'token': '42'});
}

void main() {
  final YandexAuthPlatform initialPlatform = YandexAuthPlatform.instance;

  test('$MethodChannelYandexAuth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYandexAuth>());
  });

  test('signIn', () async {
    YandexAuth yandexAuthPlugin = YandexAuth();
    MockYandexAuthPlatform fakePlatform = MockYandexAuthPlatform();
    YandexAuthPlatform.instance = fakePlatform;

    expect(await yandexAuthPlugin.signIn(), {'token': '42'});
  });
}
