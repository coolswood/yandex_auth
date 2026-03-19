class YandexAuthResult {
  final String token;
  final int? expiresIn;

  YandexAuthResult({
    required this.token,
    this.expiresIn,
  });

  factory YandexAuthResult.fromMap(Map<String, dynamic> map) {
    return YandexAuthResult(
      token: map['token'] as String,
      expiresIn: map['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      if (expiresIn != null) 'expiresIn': expiresIn,
    };
  }

  @override
  String toString() => 'YandexAuthResult(token: $token, expiresIn: $expiresIn)';
}
