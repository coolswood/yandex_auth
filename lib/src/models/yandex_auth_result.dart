/// Результат успешной авторизации через Yandex Auth.
class YandexAuthResult {
  /// Создаёт результат авторизации.
  YandexAuthResult({
    required this.token,
    this.expiresIn,
  });

  /// OAuth-токен Яндекс.
  final String token;

  /// Срок жизни токена в секундах.
  ///
  /// На Android возвращается всегда; на iOS может быть null, так как
  /// Yandex Login SDK для iOS не отдаёт это поле напрямую.
  final int? expiresIn;

  /// Создаёт [YandexAuthResult] из карты method channel.
  factory YandexAuthResult.fromMap(Map<String, dynamic> map) {
    return YandexAuthResult(
      token: map['token'] as String,
      expiresIn: map['expiresIn'] as int?,
    );
  }

  /// Сериализует результат в карту (для логирования/тестов).
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      if (expiresIn != null) 'expiresIn': expiresIn,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YandexAuthResult &&
          token == other.token &&
          expiresIn == other.expiresIn;

  @override
  int get hashCode => Object.hash(token, expiresIn);

  @override
  String toString() => 'YandexAuthResult(token: $token, expiresIn: $expiresIn)';
}
