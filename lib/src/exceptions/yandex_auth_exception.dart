/// Коды ошибок Yandex Auth, стандартизованные между Android и iOS.
///
/// Совпадают со строковыми значениями, которые отдают нативные SDK
/// через метод-канал.
enum YandexAuthErrorCode {
  cancelled('cancelled'),
  activation('activation'),
  concurrent('concurrent'),
  noActivity('no_activity'),
  sdkError('sdk_error'),
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
/// Все исключения, которые может выбросить [YandexAuth.signIn()],
/// являются подклассами этого типа — это позволяет перехватывать
/// как группу, так и конкретные случаи.
sealed class YandexAuthException implements Exception {
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
  const YandexAuthCancelledException()
      : super(message: 'Авторизация отменена пользователем');
}

/// Ошибка авторизации.
///
/// Используется для всех ошибок, кроме явной отмены: сбой активации
/// SDK, отсутствие Activity, ошибки сети и т.п. Конкретная причина
/// доступна через [code].
final class YandexAuthFailedException extends YandexAuthException {
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
