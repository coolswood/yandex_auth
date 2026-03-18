import 'yandex_auth_platform_interface.dart';

class YandexAuth {
  Future<Map<String, dynamic>?> signIn() {
    return YandexAuthPlatform.instance.signIn();
  }
}
