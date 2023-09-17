import 'package:flutter/material.dart';

class ViewPatientsAdmin extends StatefulWidget {
  const ViewPatientsAdmin({super.key});

  @override
  State<ViewPatientsAdmin> createState() => _ViewPatientsAdminState();
}

class _ViewPatientsAdminState extends State<ViewPatientsAdmin> {
  final List<Map<String, dynamic>> patientList = [];
  bool isLoading = true;

  String? secretToken;
  String? patientToken;
  String loadingMessage = "Fetching Patients ...";

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
