import 'yandex_auth_platform_interface.dart';
import 'src/models/yandex_auth_result.dart';
export 'src/models/yandex_auth_result.dart';

class YandexAuth {
  Future<YandexAuthResult?> signIn() {
    return YandexAuthPlatform.instance.signIn();
  }
}
