abstract class IMealAuthenticator {
  final String defaultuser;
  final String defaultpassword;
  final String defaultaccount;
  IMealAuthenticator({
    required this.defaultuser,
    required this.defaultpassword,
    required this.defaultaccount,
  });
  doDefaultAuth();
  doCustomAuth() {}
}
