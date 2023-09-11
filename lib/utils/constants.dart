class Constants {
  final baseUrl = "https://ansan.cb.amrita.edu/api";

  String get loginUrl => "$baseUrl/login";
  String get loginVerifyUrl => "$baseUrl/loginVerify";

  String get registerUrl => "$baseUrl/register";
  String get registerVerifyUrl => "$baseUrl/registerValidate";

  String get addNewFamilyMemberUrl => "$baseUrl/addMember";
  String get takeSurvey15aUrl => "$baseUrl/takeSurvey";
}
