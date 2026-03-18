# yandex_auth

Плагин для интеграции **Yandex Login SDK** (Авторизация через Яндекс) в приложения на Flutter. 
Поддерживает **Android** (нативный SDK) и **iOS** (через Swift Package Manager).

---

## 🛠 Подготовка к работе

Для начала зарегистрируйте ваше приложение в [Яндекс OAuth](https://oauth.yandex.ru/) и получите **Client ID**.

---

### 📱 Android Setup

1. В файл `android/app/build.gradle` добавьте ваш редирект-схему (обычно `yx<your_client_id>`):
```groovy
android {
    defaultConfig {
        manifestPlaceholders = [
            yandexAuthRedirectScheme: "ВАШ_CLIENT_ID"
        ]
    }
}
```
2. Убедитесь, что у вас добавлены права на интернет в `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

### 🍏 iOS Setup

> [!IMPORTANT]
> На iOS схема в `CFBundleURLSchemes` **обязательно** должна начинаться с префикса **`yx`** перед вашим ID клиента!

1. В `Info.plist` вашего Runner добавьте настройки:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>YandexLoginSDK</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yxВАШ_CLIENT_ID</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yandexauth</string>
    <string>yandexauth2</string>
    <string>yandexauth4</string>
</array>

<key>YandexLoginClientID</key>
<string>ВАШ_CLIENT_ID</string>
```

2. **Дополнительно для универсальных ссылок (Universal Links)**:
В настройках Xcode добавьте **Capability: Associated Domains** и впишите домен (заменив `ВАШ_CLIENT_ID`):
```text
applinks:yxВАШ_CLIENT_ID.oauth.yandex.ru
```

3. **Обработка ссылок в AppDelegate.swift**:
Добавьте эти методы для поддержки возврата в приложение:
```swift
// Для Universal Links
@available(iOS 8.0, *)
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    // Внутри плагина мы ловим это событие автоматически, 
    // но если вы используете сложную маршрутизацию — убедитесь, что событие доходит.
    return true 
}

// Для URL-схем
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return super.application(app, open: url, options: options)
}
```

---

## 🚀 Использование

Вызовите метод `signIn()` для запуска процесса:

```dart
import 'package:yandex_auth/yandex_auth.dart';

final _yandexAuth = YandexAuth();

Future<void> loginWithYandex() async {
  try {
    final result = await _yandexAuth.signIn();
    if (result != null) {
      final String token = result['token'];
      print('Токен успешно получен: $token');
    } else {
      print('Авторизация отменена пользователем');
    }
  } catch (e) {
    print('Ошибка авторизации: $e');
  }
}
```
