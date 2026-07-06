/// Коды ошибок Yandex Auth, стандартизованные между Android и iOS.
///
/// Совпадают со строковыми значениями, которые отдают нативные SDK
/// через метод-канал.
enum YandexAuthErrorCode {
  /// Пользователь отменил авторизацию.
  ///
  /// Возвращается только в виде [YandexAuthCancelledException], не
  /// используется в [YandexAuthFailedException].
  cancelled('cancelled'),

  /// Ошибка активации Yandex Login SDK.
  ///
  /// Возникает, если не задан/пуст `YAClientId` или вызов
  /// `activate(with:)` завершился неудачей (только iOS).
  activation('activation'),

  /// Повторный вызов [YandexAuth.signIn] поверх уже идущего.
  concurrent('concurrent'),

  /// Activity (Android) или root view controller (iOS) недоступны.
  ///
  /// Обычно означает, что авторизация вызвана в неподходящий момент
  /// жизненного цикла приложения.
  noActivity('no_activity'),

  /// Прочая ошибка Yandex Login SDK.
  ///
  /// Сетевые сбои, невалидный конфиг приложения в консоли Яндекс,
  /// ошибки парсинга ответа и т.п.
  sdkError('sdk_error'),

  /// Неизвестная или нестандартная ошибка.
  ///
  /// Используется как запасной вариант, если нативная сторона вернула
  /// незнакомый код.
  unknown('unknown');

  const YandexAuthErrorCode(this.value);

  /// Строковое значение, используемое на границе method channel.
  final String value;

  /// Преобразует сырую строку из [PlatformException.code] в enum.
  ///
  /// Неизвестные значения безопасно превращаются в [unknown].
  static YandexAuthErrorCode fromString(String? raw) {
    for (final code in values) {
      if (code.value == raw) return code;
    }
    return YandexAuthErrorCode.unknown;
  }
}

/// Базовый класс исключений Yandex Auth.
///
/// Все исключения, которые может выбросить [YandexAuth.signIn],
/// являются подклассами этого типа — это позволяет перехватывать
/// как группу, так и конкретные случаи.
sealed class YandexAuthException implements Exception {
  /// Создаёт исключение с опциональным человекочитаемым сообщением.
  const YandexAuthException({this.message});

  /// Человекочитаемое описание ошибки.
  final String? message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Пользователь отменил авторизацию.
///
/// Это штатная ситуация, а не сбой: пользователь закрыл экран входа
/// или нажал «Отмена».
final class YandexAuthCancelledException extends YandexAuthException {
  /// Создаёт исключение отмены авторизации.
  const YandexAuthCancelledException()
    : super(message: 'Авторизация отменена пользователем');
}

/// Ошибка авторизации.
///
/// Используется для всех ошибок, кроме явной отмены: сбой активации
/// SDK, отсутствие Activity, ошибки сети и т.п. Конкретная причина
/// доступна через [code].
final class YandexAuthFailedException extends YandexAuthException {
  /// Создаёт исключение с кодом [code] и опциональными деталями.
  const YandexAuthFailedException({
    required this.code,
    super.message,
    this.details,
  });

  /// Стандартизованный код ошибки.
  final YandexAuthErrorCode code;

  /// Дополнительные детали (например, нативный стек или строка ошибки SDK).
  final String? details;

  @override
  String toString() =>
      'YandexAuthFailedException(${code.value}): $message${details != null ? ' — $details' : ''}';
}
