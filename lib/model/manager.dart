import 'dart:convert';

class Manager {
  /*
  managerId: CB.EN.U4CSE20069,
	phoneNumber: 8129348583,
	managerName: K Vaisakhkrishnan,
	userEmail: ashrockzzz2003@gmail.com,
	officeName: Amrita Vishwa Vidyapeetham
	*/

  Manager({
    required this.managerId,
    required this.phoneNumber,
    required this.managerName,
    required this.userEmail,
    required this.officeName,
    required this.role,
  });

  String managerId;
  String phoneNumber;
  String managerName;
  String userEmail;
  String officeName;
  String role;

  String toJson() {
    return jsonEncode({
      "managerId": managerId,
      "phoneNumber": phoneNumber,
      "managerName": managerName,
      "userEmail": userEmail,
      "officeName": officeName,
      "role": role,
    });
  }
}
