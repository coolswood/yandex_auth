import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_auth/src/exceptions/yandex_auth_exception.dart';
import 'package:yandex_auth/src/models/yandex_auth_result.dart';
import 'package:yandex_auth/yandex_auth_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelYandexAuth platform;
  const MethodChannel channel = MethodChannel('yandex_auth');

  setUp(() {
    platform = MethodChannelYandexAuth();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void mockHandler(Future<Object?>? Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  test('signIn: успех возвращает YandexAuthResult', () async {
    mockHandler((methodCall) async {
      if (methodCall.method == 'signIn') {
        return {'token': '42', 'expiresIn': 3600};
      }
      return null;
    });

    final result = await platform.signIn();
    expect(result, YandexAuthResult(token: '42', expiresIn: 3600));
  });

  test('signIn: код "cancelled" → YandexAuthCancelledException', () async {
    mockHandler((methodCall) async {
      throw PlatformException(code: 'cancelled', message: 'Signin cancelled');
    });

    await expectLater(
      platform.signIn(),
      throwsA(isA<YandexAuthCancelledException>()),
    );
  });

  test(
    'signIn: код "sdk_error" → YandexAuthFailedException с правильным кодом',
    () async {
      mockHandler((methodCall) async {
        throw PlatformException(
          code: 'sdk_error',
          message: 'network failure',
          details: 'stacktrace',
        );
      });

      await expectLater(
        platform.signIn(),
        throwsA(
          isA<YandexAuthFailedException>()
              .having((e) => e.code, 'code', YandexAuthErrorCode.sdkError)
              .having((e) => e.message, 'message', 'network failure')
              .having((e) => e.details, 'details', 'stacktrace'),
        ),
      );
    },
  );

  test(
    'signIn: неизвестный код → YandexAuthFailedException с code=unknown',
    () async {
      mockHandler((methodCall) async {
        throw PlatformException(code: 'something_unexpected', message: 'weird');
      });

      await expectLater(
        platform.signIn(),
        throwsA(
          isA<YandexAuthFailedException>().having(
            (e) => e.code,
            'code',
            YandexAuthErrorCode.unknown,
          ),
        ),
      );
    },
  );

  test(
    'signIn: null-результат → YandexAuthFailedException (страховка)',
    () async {
      mockHandler((methodCall) async => null);

      await expectLater(
        platform.signIn(),
        throwsA(
          isA<YandexAuthFailedException>().having(
            (e) => e.code,
            'code',
            YandexAuthErrorCode.unknown,
          ),
        ),
      );
    },
  );

  test('logout: успешный no-op/вызов не выбрасывает', () async {
    mockHandler((methodCall) async {
      if (methodCall.method == 'logout') return null;
      return null;
    });

    await platform.logout();
  });

  test('logout: ошибка SDK → YandexAuthFailedException', () async {
    mockHandler((methodCall) async {
      throw PlatformException(code: 'sdk_error', message: 'logout failed');
    });

    await expectLater(
      platform.logout(),
      throwsA(
        isA<YandexAuthFailedException>().having(
          (e) => e.code,
          'code',
          YandexAuthErrorCode.sdkError,
        ),
      ),
    );
  });
}
