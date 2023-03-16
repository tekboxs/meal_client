abstract class MealHttpInterceptors<TRequest, TResponse, TError> {
  dynamic onRequest(TRequest);
  dynamic onResponse(TResponse);
  dynamic onError(TError);
}

abstract class MealHttpService {
  getRequest(
    url, {
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  });
  postRequest(
    url, {
    dynamic data,
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  });
  putRequest(
    url, {
    dynamic data,
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  });
  deleteRequest(
    url, {
    bool isBaseUrl = false,
    Map<String, String> headers = const {},
  });
}
