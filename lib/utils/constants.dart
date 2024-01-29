class Constants {
  // final baseUrl = "https://ansan.cb.amrita.edu/api";

  final baseUrl = "http://localhost:3001/api";
  String get loginUrl => "$baseUrl/login";
  String get loginVerifyUrl => "$baseUrl/loginVerify";

  String get registerUrl => "$baseUrl/register";
  String get registerVerifyUrl => "$baseUrl/registerValidate";

  String get addNewFamilyMemberUrl => "$baseUrl/addMember";
  String get takeSurvey15aUrl => "$baseUrl/takeSurvey";
  String get allFamilyMembersUrl => "$baseUrl/getMembers";

  // Management
  String get verifyManagerDetailsUrl => "$baseUrl/verifyManagerDetails";
  String get editManagerDetailsUrl => "$baseUrl/editManagementData";
  String get predictGlaucomaUrl => "$baseUrl/predictGlaucoma";
  String get allPatientReportsUrl => "$baseUrl/getReportId";
  String get getReportUrl => "$baseUrl/getReportData";
  String get downloadReportUrl => "$baseUrl/downloadReport";
  String get addDescriptionUrl => "$baseUrl/addDescription";
  String get emailReportUrl => "$baseUrl/emailReport";

  // TODO: Update and test this API
  String get viewPatientsUrl => "$baseUrl/getPatientsUnderMe";
  String get getSurveyUrl => "$baseUrl/getSurvey";

  // ADMIN
  String get registerOfficialUrl => "$baseUrl/registerOfficial";
  String get allOfficialsUrl => "$baseUrl/getRegisteredUsers";
  String get toggleOfficialStatusUrl => "$baseUrl/toggleStatus";
  String get registerPatientUrl => "$baseUrl/addPatient";
  String get getPatientUrl => "$baseUrl/getPatient";
}
