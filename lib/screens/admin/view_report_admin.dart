import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/admin/patient_reports_admin.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewReportAdminScreen extends StatefulWidget {
  const ViewReportAdminScreen(
      {super.key, required this.patientId, required this.reportId});

  final String patientId;
  final String reportId;

  @override
  State<ViewReportAdminScreen> createState() => _ViewReportAdminScreenState();
}

class _ViewReportAdminScreenState extends State<ViewReportAdminScreen> {
  Map<String, dynamic> reportData = {};
  Map<String, dynamic> patientData = {};

  List<dynamic> imageFiles = [];

  bool isLoading = true;

  String? secretToken;
  String? patientToken;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _doctorComment = TextEditingController();

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    SharedPreferences.getInstance().then((sp) {
      setState(() {
        secretToken = sp.getString("SECRET_TOKEN");
        patientToken = sp.getString("patient_token");
      });

      Dio().post(
        Constants().getReportUrl,
        options: Options(
          headers: {"Authorization": "Bearer $secretToken"},
          validateStatus: (status) => status! < 500,
        ),
        data: {
          "patient_token": patientToken,
          "reportId": widget.reportId,
        },
      ).then((response) {
        if (response.statusCode == 200) {
          final reportD = response.data["data"] as Map<String, dynamic>;

          setState(() {
            reportData = {
              "reportId": reportD["reportId"],
              "managerId": reportD["managerId"],
              "leftEye": "${reportD["modelOutput"].toString().split(",")[0]} %",
              "rightEye":
                  "${reportD["modelOutput"].toString().split(",")[1]} %",
              "description": reportD["description"],
              "descriptionMangerId": reportD["descriptionMangerId"],
              "timeStamp": reportD["timeStamp"],
            };
            patientData = response.data["data"] as Map<String, dynamic>;
            _doctorComment.text = reportData["description"] ?? "";
            imageFiles.addAll([
              "https://ansan.cb.amrita.edu/fundus/${patientData["leftImage1"].toString()}.png",
              "https://ansan.cb.amrita.edu/fundus/${patientData["leftImage2"].toString()}.png",
              "https://ansan.cb.amrita.edu/fundus/${patientData["rightImage1"].toString()}.png",
              "https://ansan.cb.amrita.edu/fundus/${patientData["rightImage2"].toString()}.png",
            ]);
          });

          setState(() {
            isLoading = false;
          });
        } else if (response.statusCode == 401) {
          showToast("Session Expired! Please login again.");
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) {
            return const WelcomeScreen();
          }), (route) => false);
        } else if (response.data["message"] != null) {
          showToast(response.data["message"]);
        } else {
          showToast("Something went wrong! Please try again later.");
        }

        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        if (kDebugMode) {
          print(e);
        }
        showToast("Something went wrong!");
        setState(() {
          isLoading = false;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  floating: false,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return PatientReportsScreen(
                            patientId: widget.patientId);
                      }), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    background: Image.asset(
                      "assets/login.png",
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.2),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Patient Report",
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Patient ID
                        const SizedBox(
                          height: 24,
                        ),
                        Chip(
                          padding: const EdgeInsets.all(2.0),
                          label: Text(
                            "Patient ID: ${widget.patientId}",
                            style: GoogleFonts.sourceCodePro(
                              fontWeight: FontWeight.w500,
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Card(
                          borderOnForeground: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.reportId,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sourceCodePro(
                                    textStyle:
                                        Theme.of(context).textTheme.titleLarge,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                const Divider(
                                  height: 0,
                                ),
                                // table with chips indicating the results
                                Table(
                                  border: TableBorder.symmetric(
                                    inside: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                  ),
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Left Eye",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.raleway(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Right Eye",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.raleway(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Chip(
                                              label: Text(
                                                reportData["leftEye"],
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Chip(
                                              label: Text(
                                                reportData["rightEye"],
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 0,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),

                                for (int i = 0; i < imageFiles.length; i++) ...[
                                  Chip(
                                    label: Text(
                                      i == 0
                                          ? "Left Eye Image 1"
                                          : i == 1
                                              ? "Left Eye Image 2"
                                              : i == 2
                                                  ? "Right Eye Image 1"
                                                  : "Right Eye Image 2",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Image.network(
                                    imageFiles[i],
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width *
                                        0.84,
                                    filterQuality: FilterQuality.high,
                                    isAntiAlias: true,
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        ElevatedButton.icon(
                          label: Text(
                            "View Questionnaire",
                            style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSecondary,
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          icon: Icon(
                            Icons.question_answer_rounded,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              enableDrag: true,
                              useSafeArea: true,
                              isDismissible: true,
                              showDragHandle: true,
                              isScrollControlled: true,
                              builder: (context) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Questionnaire",
                                            style: GoogleFonts.raleway(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 48,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text: patientData["patientId"]
                                                .toString()),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.qr_code_rounded),
                                          labelText: "PatientID",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.sourceCodePro(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                            text:
                                                patientData["userName"] ?? ""),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.person_rounded),
                                          labelText: "Full Name",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: "${patientData["height"]}cm",
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.height_rounded),
                                          labelText: "Height (cm)",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.sourceCodePro(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: "${patientData["weight"]} kg",
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.height_rounded),
                                          labelText: "Weight (kg)",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.sourceCodePro(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["covidVaccination"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText: "Vaccination Status",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["allergies"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Your allergies",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["symptoms"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Symptoms",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["symptomDuration"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Symptoms Duration",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["injury"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText:
                                              "Any accidents or injuries?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["medication"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText:
                                              "Any long term medication? Please specify. (Enter NIL if none)",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["medicalHistory"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText:
                                              "Any past medical history?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["consumptions"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText: "Other consumptions.",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["familyHistory"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.medical_services_rounded),
                                          labelText:
                                              "Family History of any diseases?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["redness"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Redness Of Eye",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["pain"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Pain In Eyes",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["halos"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Halos around lights",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["suddenExacerbation"]
                                                  .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Any time you had sudden exacerbation of the problem?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["consulted"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Did you show to any doctor for this problem?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["medicines"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you been taking any medicines for this problem?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "generalInvestigation"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Any general investigations you have got done?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["diabeticRetinopathy"]
                                                  .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Do you have diabetic retinopathy?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "macularDegenerations"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Did you have macular degenerations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["macularhole"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Do you have macular hole?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["glaucoma"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Do you have glaucoma?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["catract"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Do you have cataract?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["uveitis"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText: "Do you have uveitis?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["fundusPhotography"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Fundus Photography investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["fundusAngiography"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Fundus Angiography investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "opticalCoherenceTomography"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Optical Coherence Tomography investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text:
                                              patientData["visualFieldAnalysis"]
                                                  .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Visual Field Analysis investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["gonioscopy"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Gonioscopy investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "centralCornealThicknessAnalysis"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Central Corneal Thickness Analysis investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "slitLampInvestigation"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Slit Lamp investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "applanationTonometry"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Applanation Tonometry investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData["bScan"].toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got B Scan investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      TextField(
                                        controller: TextEditingController(
                                          text: patientData[
                                                  "biochemicalParameters"]
                                              .toString(),
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.coronavirus_rounded),
                                          labelText:
                                              "Have you got Biochemical Parameters investigations?",
                                          labelStyle: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                        ),
                                        readOnly: true,
                                        style: GoogleFonts.raleway(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      const SizedBox(
                                        height: 32,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
