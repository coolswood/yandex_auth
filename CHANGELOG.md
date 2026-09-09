## 1.3.2

* iOS: `PrivacyInfo.xcprivacy` теперь реально поставляется в артефакте
  (раньше файл существовал, но не был объявлен ресурсом в `Package.swift`).
* Android: починен запуск юнит-тестов (`testDebugUnitTest`) — сборка падала
  на подстановке `YANDEX_CLIENT_ID` в манифесте, т.к. на уровне библиотеки
  значение placeholder'а неизвестно. Добавлено запасное значение в
  `defaultConfig` библиотеки; при сборке приложения приоритет остаётся у
  `manifestPlaceholders` из app-level `build.gradle`.
* Example (iOS): `Package.resolved` обновлён с YandexLoginSDK 3.0.3 до 3.1.1 —
  соответствует версии, требуемой плагином.
* Обновлены инструменты сборки Android: AGP 8.11.1 → 8.13.2,
  Kotlin 2.2.20 → 2.2.21, Mockito 5.0.0 → 5.23.0 (тесты).
* Удалён дублирующий `android/settings.gradle` (проект использует `.kts`).
* README: задокументирован `YandexAuth.logout()`; в example добавлена
  кнопка Logout.

## 1.3.1

* Добавлен метод `YandexAuth.logout()`. На iOS очищает кеш JWT внутри
  Yandex Login SDK; на Android — no-op (SDK stateless, токен нужно удалять
  в хранилище приложения). При ошибке (только iOS) выбрасывает
  `YandexAuthFailedException`.
* Публичный API задокументирован dartdoc'ом.
* Включены строгие линтеры (`strict-casts`, `strict-raw-types`,
  `public_member_api_docs`, `prefer_single_quotes`, `require_trailing_commas`).
* iOS: убран deprecated fallback через `UIApplication.shared.windows`,
  поиск root view controller теперь идёт единым путём через `UIWindowScene`.
* Обновлены нативные зависимости: iOS YandexLoginSDK 3.1.0 → 3.1.1,
  Android authsdk 3.2.0 → 3.2.1.

## 1.3.0

**Breaking changes:**

* `signIn()` теперь возвращает `Future<YandexAuthResult>` (non-null). Раньше мог
  возвращать `null` при отмене, но контракт не соблюдался на нативной стороне.
* Отмена и ошибки теперь выбрасывают типизированные исключения вместо возврата
  `null` или «голого» `PlatformException`:
  * `YandexAuthCancelledException` — пользователь отменил авторизацию.
  * `YandexAuthFailedException` — прочие ошибки, с полем `code` типа
    `YandexAuthErrorCode`.
* Стандартизованы коды ошибок между Android и iOS: `cancelled`, `activation`,
  `concurrent`, `no_activity`, `sdk_error`, `unknown`. Ранее Android возвращал
  единый `sign_in_failed`, iOS — разные `ACTIVATION_ERROR`/`CONCURRENT_OPERATIONS`/...
* Android-пакет переименован с `com.example.yandex_auth` на
  `com.coolswood.yandex_auth` (префикс `com.example.*` неприемлем для
  публикуемых плагинов).

**Прочее:**

* `YandexAuthResult` получил корректные `==` / `hashCode`.
* Восстановлен корректный config-change flow на Android (результат не теряется
  при пересоздании Activity).
* Починен тест `yandex_auth_method_channel_test.dart`, который сравнивал
  объект с `Map`.
* Расширены тесты: успех, отмена, ошибка SDK, неизвестный код, null-результат.

## 1.1.0

* **iOS**: Обновлены методы обработки ссылок в `SceneDelegate` согласно актуальной спецификации Yandex Login SDK.
* **iOS**: Внедрены `tryHandleOpenURL` и `tryHandleUserActivity` для более надежной обработки Custom URL Schemes и Universal Links.
* **iOS**: Упрощена логика фильтрации входящих `NSUserActivity`, делегируя проверку соответствия напрямую в SDK.

## 1.0.1

* **iOS**: Добавлено проксирование **всех** коллбэков в `SceneDelegate` (исправляет зависание авторизации при холодном старте на iOS 13+).
* **iOS**: Реализована очистка слушателей в `detachFromEngine(for:)`, предотвращающая утечки памяти при перезапуске движка авторизации.
* **iOS**: Вызывается `restorationHandler` в `AppDelegate` при успешном перенаправлении по Universal Link, соответствуя UIKit требованиям.
* **iOS**: Удалено захардкоженное значение `expiresIn: 0` для предотвращения ложных срабатываний об истечении срока действия токена на стороне клиента.

## 1.0.0

* Начальный релиз плагина Yandex Auth.
* Поддержка Android на базе `YandexAuthSdkContract`.
* Поддержка iOS на базе `YandexLoginSDK` (через Swift Package Manager).
* Единый интерфейс `signIn()` из Dart.
