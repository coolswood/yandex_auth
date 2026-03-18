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


3. **SceneDelegate (для iOS 13+)**:
Если ваше приложение использует `SceneDelegate` для управления жизненным циклом, вам потребуется вручную проксировать URL-события в SDK:

```swift
import Flutter
import UIKit
import YandexLoginSDK

class SceneDelegate: FlutterSceneDelegate {
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        super.scene(scene, openURLContexts: URLContexts)
        for context in URLContexts {
            _ = YandexLoginSDK.shared.handleOpen(context.url)
        }
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        // URL Schemes
        for context in connectionOptions.urlContexts {
            _ = YandexLoginSDK.shared.handleOpen(context.url)
        }
        // Universal Links
        for userActivity in connectionOptions.userActivities {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
                _ = YandexLoginSDK.shared.handleOpen(url)
            }
        }
    }
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
      final String token = result.token;
      final int? expiresIn = result.expiresIn; // На iOS может быть null
      print('Токен успешно получен: $token, истекает через: $expiresIn сек.');
    } else {
      print('Авторизация отменена пользователем');
    }
  } catch (e) {
    print('Ошибка авторизации: $e');
  }
}
```
