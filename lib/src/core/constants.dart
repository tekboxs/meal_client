enum KStatusEnum {
  ok(200),
  connection(405),
  badRequest(400),
  notFound(404),
  internalServerError(500),
  unauthorized(401),
  serviceUnavailable(503),
  timeout(408);

  final int status;
  const KStatusEnum(this.status);

  int get getStatus => status;
  String get getStatusName => name;
}
