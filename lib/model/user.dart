import 'dart:convert';

class User {
  /*
  {
    patientId: 1,
    phoneNumber: 8870014773,
    userName: Ashwin Narayanan S,
    gender: M,
    dob: 2003-10-13T00:00:00.000Z,
    age: 19,
    userEmail: cb.en.u4cse21008@cb.students.amrita.edu,
    aadhar: 837301936258,
    address: GF5, Parsn Prashanthi Apartments, G K Sundaram Street, K K Pudur, Saibaba Colony,
    district: Coimbatore,
    state: Tamil Nadu,
    country: India,
    pincode: 641038,
    surveyLevel: 0
  }

  roles:

  ADMIN
  HSHEAD
  FLWRKR & DOC (Same Level)
  USER

  */

  User(
      {required this.patientId,
      required this.phoneNumber,
      required this.userName,
      required this.gender,
      required this.dob,
      required this.age,
      required this.userEmail,
      required this.aadharNumber,
      required this.address,
      required this.district,
      required this.state,
      required this.country,
      required this.pincode,
      required this.surveyLevel,
      required this.role});

  String patientId;
  String phoneNumber;
  String userName;
  String gender;
  String dob;
  String age;
  String userEmail;
  String aadharNumber;
  String address;
  String district;
  String state;
  String country;
  String pincode;
  String surveyLevel;
  String role;

  // toJson
  String toJson() {
    return jsonEncode({
      "patientId": patientId,
      "phoneNumber": phoneNumber,
      "userName": userName,
      "gender": gender,
      "dob": dob,
      "age": age,
      "userEmail": userEmail,
      "aadhar": aadharNumber,
      "address": address,
      "district": district,
      "state": state,
      "country": country,
      "pincode": pincode,
      "surveyLevel": surveyLevel,
      "role": role
    });
  }
}
