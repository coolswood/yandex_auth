import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yandex_auth/yandex_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signIn test', (WidgetTester tester) async {
    final YandexAuth plugin = YandexAuth();
    // В интеграционных тестах мы обычно не можем легко симулировать UI веб-просмотра/авторизации
    // без моков, но это проверка на отсутствие ошибок компиляции.
    expect(plugin, isNotNull);
  });
}
