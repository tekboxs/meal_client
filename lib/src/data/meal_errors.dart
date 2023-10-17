enum KDefaultErrors { connection, unknown, emptyData }

class MealErrors {
  final Enum? errorKey;
  final String? message;
  final dynamic debugMessage;
  MealErrors({
    this.errorKey,
    this.message = kDefaultConnectionErrorMessage,
    this.debugMessage,
  });

  static const kDefaultConnectionErrorMessage =
      'Houve um erro na solicitação, por favor verifique sua conexão';
  static const kDefaultUnknownErrorMessage =
      'Houve um erro inesperado, por favor tente novamente';
}
