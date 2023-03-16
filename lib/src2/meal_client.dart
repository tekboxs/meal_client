enum MealErrors { route, auth, serverInternal, timeout, unknown }

enum MealCases { blank, notFound }



// abstract class IMealClient extends MealUnoService {
//   IMealClient(
//     String baseUrl,
//     MealHttpInterceptors interceptors,
//     IMealAuthenticator auth,
//   ) : super(baseUrl, interceptors, auth);

//   removeToken() async {
//     await Storage.remove('token');
//   }
// }
