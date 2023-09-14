class Patient {
  /*
  * NB: Pass null for phoneNumber and userEmail if not passed. Else pass the respective value
  {
      "phoneNumber" : null,
      "userName" : "Mithun",
      "gender" : "M",
      "dob" : "2001-03-12",
      "userEmail" : null,
      "aadhar" : "111111111111",
      "address" : "Kiliyattuveliyil",
      "district" : "Alappuzha",
      "state" : "Kerala",
      "country" : "India",
      "pincode" : "688003"
  }
  */

  Patient({
    required this.patientId,
    required this.userName,
    required this.gender,
    required this.dob,
    required this.aadharNo,
    required this.address,
    required this.district,
    required this.state,
    required this.country,
    required this.pincode,
    required this.surveyLevel,
    required this.roleId,
    required this.isParent,
    required this.age,

    this.phoneNumber,
    this.userEmail,


    this.parentId,
    this.allergies,
    this.height,
    this.weight,
    this.covidVaccination,
    this.anyAllergies,
    this.symptoms,
    this.symptomDuration,
    this.injury,
    this.medication,
    this.medicalHistory,
    this.consumptions,
    this.familyHistory,
    this.redness,
    this.pain,
    this.halos,
    this.suddenExacerbation,
    this.consulted,
    this.medicines,
    this.generalInvestigation,
    this.diabeticRetinopathy,
    this.macularDegenerations,
    this.macularHole,
    this.glaucoma,
    this.catract,
    this.uveitis,
    this.fundusPhotography,
    this.fundusAngiography,
    this.opticalCoherenceTomography,
    this.visualFieldAnalysis,
    this.gonioscopy,
    this.centralCornealThicknessAnalysis,
    this.slitLampInvestigation,
    this.applanationTonometry,
    this.bScan,
    this.biochemicalParameters,
  });

  // Optional
  final String? phoneNumber;
  final String? userEmail;
  final String? parentId;
  final String? allergies;
  final String? height;
  final String? weight;
  final String? covidVaccination;

  // Level 1
  final String? anyAllergies; // 1 or 0
  final String? symptoms;
  final String? symptomDuration;
  final String? injury; // Yes or No
  final String? medication;
  final String? medicalHistory;
  final String? consumptions;
  final String? familyHistory;

  // Level 2
  final String? redness;
  final String? pain;
  final String? halos;
  final String? suddenExacerbation;
  final String? consulted;
  final String? medicines;
  final String? generalInvestigation;
  final String? diabeticRetinopathy;
  final String? macularDegenerations;
  final String? macularHole;
  final String? glaucoma;
  final String? catract;
  final String? uveitis;
  final String? fundusPhotography;
  final String? fundusAngiography;
  final String? opticalCoherenceTomography;
  final String? visualFieldAnalysis;
  final String? gonioscopy;
  final String? centralCornealThicknessAnalysis;
  final String? slitLampInvestigation;
  final String? applanationTonometry;
  final String? bScan;
  final String? biochemicalParameters;


  // Basic Required
  final String patientId;
  final String userName;
  final String gender;
  final String dob;
  final String age;
  final String aadharNo;
  final String address;
  final String district;
  final String state;
  final String country;
  final String pincode;
  final String surveyLevel;
  final String roleId;
  final String isParent; // 1 or 0

  String? patientToken;

  String? get secretToken => patientToken;
  set secretToken(String? token) => patientToken = token;

  // Patient fromJson


}
