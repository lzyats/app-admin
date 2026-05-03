class ApiErrorCode {
  const ApiErrorCode._();

  static const int ok = 200;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int banned = 423;
  static const int tokenExpired = 10001;
  static const int forceLogin = 10002;
}
