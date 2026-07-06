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

Вызовите метод `signIn()` для запуска процесса авторизации. Метод возвращает
`Future<YandexAuthResult>` с токеном при успехе либо выбрасывает типизированное
исключение при неудаче.

```dart
import 'package:yandex_auth/yandex_auth.dart';

final _yandexAuth = YandexAuth();

Future<void> loginWithYandex() async {
  try {
    final result = await _yandexAuth.signIn();
    final String token = result.token;
    final int? expiresIn = result.expiresIn; // На iOS может быть null
    print('Токен успешно получен: $token, истекает через: $expiresIn сек.');
  } on YandexAuthCancelledException {
    // Пользователь отменил авторизацию — штатная ситуация
    print('Авторизация отменена пользователем');
  } on YandexAuthFailedException catch (e) {
    // Сбой активации SDK, ошибка сети, нет Activity и т.п.
    print('Ошибка (${e.code.value}): ${e.message}');
    if (e.details != null) print('Детали: ${e.details}');
  }
}
```

### ⚠️ Обработка ошибок

Плагин выбрасывает исключения из семейства `YandexAuthException`:

| Исключение                         | Когда                                              |
|------------------------------------|----------------------------------------------------|
| `YandexAuthCancelledException`     | Пользователь закрыл экран входа / нажал «Отмена»   |
| `YandexAuthFailedException`        | Прочие ошибки (см. `code` ниже)                    |

`YandexAuthFailedException.code` принимает значения `YandexAuthErrorCode`:

| Код           | Значение                                              |
|---------------|-------------------------------------------------------|
| `activation`  | Не задан/пуст `YAClientId` или не удалось активировать SDK |
| `concurrent`  | Повторный вызов `signIn()` поверх уже идущего          |
| `no_activity` | Activity (Android) / root view controller (iOS) недоступны |
| `sdk_error`   | Ошибка Yandex Login SDK (сеть, невалидный config и т.п.) |
| `cancelled`   | Отмена пользователем (только в виде `YandexAuthCancelledException`) |
| `unknown`     | Неизвестная/нестандартная ошибка                       |

Коды стандартизованы и совпадают на Android и iOS.

