# yandex_auth

Плагин для интеграции **Yandex Login SDK** (Авторизация через Яндекс) в приложения на Flutter. 
Поддерживает **Android** (нативный SDK) и **iOS** (через Swift Package Manager).


## 🛠 Подготовка к работе

Для начала зарегистрируйте ваше приложение в [Яндекс OAuth](https://oauth.yandex.ru/) и получите **Client ID**.


### 📱 Android Setup

1. В файл `android/app/build.gradle` добавьте `manifestPlaceholders` с вашим Client ID внутри блока `defaultConfig`:
```gradle
android {
    defaultConfig {
        // ...
        manifestPlaceholders += [YANDEX_CLIENT_ID: "ВАШ_CLIENT_ID"]
    }
}
```

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
    <string>primaryyandexloginsdk</string>
    <string>secondaryyandexloginsdk</string>
    <string>yandexauth</string>
    <string>yandexauth2</string>
    <string>yandexauth4</string>
</array>

<key>YAClientId</key>
<string>ВАШ_CLIENT_ID</string>
```

> [!NOTE]
> Плагин автоматически перехватывает URL-адреса через систему делегатов Flutter. **Никаких ручных правок в `AppDelegate.swift` или `SceneDelegate.swift` делать не нужно.**

2. **Дополнительно для универсальных ссылок (Universal Links)**:
В настройках Xcode добавьте **Capability: Associated Domains** и впишите домен (заменив `ВАШ_CLIENT_ID`):
```text
applinks:yxВАШ_CLIENT_ID.oauth.yandex.ru
```

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

### ⚠️ Обработка ошибок

В случае ошибок на стороны нативных SDK (проблемы с сетью, некорректная настройка приложения в консоли Яндекс и т.д.) плагин выбросит `PlatformException`.

Вы можете получить детальную информацию для логирования:

```dart
import 'package:flutter/services.dart';

Future<void> loginWithYandex() async {
  try {
    final result = await _yandexAuth.signIn();
    // ...
  } on PlatformException catch (e) {
    print('Код ошибки: ${e.code}');
    print('Сообщение: ${e.message}');
    print('Детали (нативный стек): ${e.details}');
  } catch (e) {
    print('Неизвестная ошибка: $e');
  }
}
```

