import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_auth/yandex_auth_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelYandexAuth platform = MethodChannelYandexAuth();
  const MethodChannel channel = MethodChannel('yandex_auth');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'signIn') {
            return {'token': '42', 'expiresIn': 0};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('signIn', () async {
    expect(await platform.signIn(), {'token': '42', 'expiresIn': 0});
  });
}
