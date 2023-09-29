import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/admin/admin_screen.dart';
import 'package:eperimetry_vtwo/screens/admin/new_patient_admin.dart';
import 'package:eperimetry_vtwo/screens/admin/new_test_admin.dart';
import 'package:eperimetry_vtwo/screens/admin/patient_reports_admin.dart';
import 'package:eperimetry_vtwo/screens/admin/questionnaire_1_admin.dart';
import 'package:eperimetry_vtwo/screens/admin/questionnaire_2_admin.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewPatientAdmin extends StatefulWidget {
  const ViewPatientAdmin({super.key, required this.patientId});

  final String patientId;

  @override
  State<ViewPatientAdmin> createState() => _ViewPatientAdminState();
}

class _ViewPatientAdminState extends State<ViewPatientAdmin> {
  bool isLoading = true;

  Map<String, dynamic> patientData = {
    "statusCode": "400"
  };
  final String patientToken = "";

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      final secretToken = sp.getString("SECRET_TOKEN");
      if (secretToken == null || secretToken.isEmpty) {
        showToast("Session Expired. Please login again.");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const WelcomeScreen();
        }), (route) => false);
      }

      Dio().post(
        Constants().getPatientUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $secretToken",
            "Content-Type": "application/json"
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: {
          "patientId": widget.patientId,
        },
      ).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            SharedPreferences.getInstance().then((sp) {
              sp.setString("patient_token", response.data["patient_token"]);
              setState(() {
                patientData = response.data["deatils"];
              });
            });
          });
        } else if (response.data["message"] != null) {
          setState(() {
            patientData = {};
          });
          showToast(response.data["message"]);
        } else {
          if (kDebugMode) {
            print(response.data);
          }
          setState(() {
            patientData = {};
          });
          showToast("Something went wrong. Please try again later.");
        }
      }).catchError((e) {
        if (kDebugMode) {
          print(e);
        }
        setState(() {
          patientData = {};
        });
        showToast("Something went wrong. Please try again later.");
      });
    });

    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || (patientData["statusCode"] != null && patientData["statusCode"] == "400")
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
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return const AdminScreen();
                      }), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 8.0),
                    centerTitle: true,
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                    collapseMode: CollapseMode.parallax,
                    background: Image.asset(
                      "assets/login.png",
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.2),
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Patient Details",
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
                          height: 24,
                        ),
                        if (patientData.isNotEmpty) ...[
                          ExpansionTile(
                            initiallyExpanded: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            collapsedBackgroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.2),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.3),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                            leading:
                                const Icon(Icons.medical_information_rounded),
                            // Container(
                            //   padding: const EdgeInsets.all(16.0),
                            //   decoration: BoxDecoration(
                            //     color: Theme.of(context).colorScheme.primary,
                            //     borderRadius: BorderRadius.circular(8.0),
                            //   ),
                            //   child: Text(
                            //     patientData["patientId"].toString(),
                            //     style: GoogleFonts.raleway(
                            //       fontWeight: FontWeight.w500,
                            //       textStyle:
                            //       Theme.of(context).textTheme.bodyLarge,
                            //       color:
                            //       Theme.of(context).colorScheme.onPrimary,
                            //     ),
                            //   ),
                            // ),
                            title: Text(
                              patientData["userName"],
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            subtitle: Align(
                              alignment: Alignment.centerLeft,
                              child: Chip(
                                padding: const EdgeInsets.all(2.0),
                                label: Text(
                                  patientData["surveyLevel"].toString() == "0"
                                      ? "Questionnaire 1 Pending"
                                      : patientData["surveyLevel"].toString() ==
                                              "1"
                                          ? "Questionnaire 2 pending"
                                          : "Questionnaire Done",
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w500,
                                    color: patientData["surveyLevel"]
                                                    .toString() ==
                                                "0" ||
                                            patientData["surveyLevel"]
                                                    .toString() ==
                                                "1"
                                        ? Theme.of(context).colorScheme.onError
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                backgroundColor: patientData["surveyLevel"]
                                                .toString() ==
                                            "0" ||
                                        patientData["surveyLevel"].toString() ==
                                            "1"
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            children: [
                              const Divider(
                                thickness: 1,
                              ),
                              ListTile(
                                onTap: () {
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Patient Details",
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
                                                prefixIcon: const Icon(
                                                    Icons.qr_code_rounded),
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
                                                      patientData["userName"] ??
                                                          ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.person_rounded),
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
                                                  text: patientData[
                                                          "phoneNumber"] ??
                                                      ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.phone_rounded),
                                                labelText: "Mobile Number",
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
                                                  text: patientData[
                                                          "userEmail"] ??
                                                      ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.phone_rounded),
                                                labelText: "Email-ID",
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
                                                  text: patientData["gender"] ==
                                                          "M"
                                                      ? "Male"
                                                      : "Female"),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    patientData["gender"] == "M"
                                                        ? const Icon(
                                                            Icons.male_rounded)
                                                        : const Icon(Icons
                                                            .female_rounded),
                                                labelText: "Gender",
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
                                                text: patientData["dob"]
                                                    .toString()
                                                    .split("T")[0],
                                              ),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.date_range_rounded),
                                                labelText: "Date of Birth",
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
                                                      patientData["age"] ?? ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(Icons
                                                    .access_time_filled_rounded),
                                                labelText: "Age",
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
                                                  text: patientData["aadhar"] ??
                                                      ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.badge_rounded),
                                                labelText: "Aadhar",
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
                                                      patientData["address"] ??
                                                          ""),
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.home_rounded),
                                                labelText: "Address",
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
                                                      patientData["district"] ??
                                                          ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.location_on_rounded),
                                                labelText: "District",
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
                                                  text: patientData["state"] ??
                                                      ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(Icons
                                                    .local_library_rounded),
                                                labelText: "State",
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
                                                      patientData["country"] ??
                                                          ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.flag_circle_rounded),
                                                labelText: "Country",
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
                                                      patientData["pincode"] ??
                                                          ""),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.qr_code_2_rounded),
                                                labelText: "Pincode",
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
                                              height: 32,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                leading: const Icon(Icons.person),
                                title: Text(
                                  "View Details",
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (patientData["surveyLevel"].toString() ==
                                  "0") ...[
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) {
                                        return QuestionnaireFull15bAdminScreen(
                                          patientId: patientData["patientId"]
                                              .toString(),
                                        );
                                      },
                                    ));
                                  },
                                  leading: const Icon(Icons.assignment),
                                  title: Text(
                                    "Take Questionnaire",
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ] else if (patientData["surveyLevel"]
                                      .toString() ==
                                  "1") ...[
                                ListTile(
                                  onTap: () {
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Questionnaire",
                                                    style: GoogleFonts.raleway(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .headlineMedium,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                                controller:
                                                    TextEditingController(
                                                        text: patientData[
                                                                "patientId"]
                                                            .toString()),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.qr_code_rounded),
                                                  labelText: "PatientID",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: patientData[
                                                                "userName"] ??
                                                            ""),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.person_rounded),
                                                  labelText: "Full Name",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      "${patientData["height"]}cm",
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.height_rounded),
                                                  labelText: "Height (cm)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      "${patientData["weight"]} kg",
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.height_rounded),
                                                  labelText: "Weight (kg)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "covidVaccination"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Vaccination Status",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["allergies"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Your allergies",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["symptoms"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Symptoms",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "symptomDuration"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Symptoms Duration",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["injury"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any accidents or injuries?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      patientData["medication"]
                                                          .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any long term medication? Please specify. (Enter NIL if none)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "medicalHistory"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any past medical history?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "consumptions"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Other consumptions.",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "familyHistory"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Family History of any diseases?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                  leading: const Icon(Icons.assignment),
                                  title: Text(
                                    "View Questionnaire 1",
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) {
                                        return Questionnaire15cAdminScreen(
                                          patientId: patientData["patientId"]
                                              .toString(),
                                        );
                                      },
                                    ));
                                  },
                                  leading: const Icon(Icons.assignment),
                                  title: Text(
                                    "Take Questionnaire 2",
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                ListTile(
                                  onTap: () {
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Questionnaire",
                                                    style: GoogleFonts.raleway(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .headlineMedium,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                                controller:
                                                    TextEditingController(
                                                        text: patientData[
                                                                "patientId"]
                                                            .toString()),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.qr_code_rounded),
                                                  labelText: "PatientID",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: patientData[
                                                                "userName"] ??
                                                            ""),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.person_rounded),
                                                  labelText: "Full Name",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      "${patientData["height"]}cm",
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.height_rounded),
                                                  labelText: "Height (cm)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      "${patientData["weight"]} kg",
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.height_rounded),
                                                  labelText: "Weight (kg)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer),
                                                  ),
                                                ),
                                                readOnly: true,
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TextField(
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "covidVaccination"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Vaccination Status",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["allergies"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Your allergies",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["symptoms"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Symptoms",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "symptomDuration"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Symptoms Duration",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["injury"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any accidents or injuries?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      patientData["medication"]
                                                          .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any long term medication? Please specify. (Enter NIL if none)",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "medicalHistory"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Any past medical history?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "consumptions"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Other consumptions.",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "familyHistory"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .medical_services_rounded),
                                                  labelText:
                                                      "Family History of any diseases?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["redness"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Redness Of Eye",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["pain"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText: "Pain In Eyes",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["halos"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Halos around lights",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "suddenExacerbation"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Any time you had sudden exacerbation of the problem?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["consulted"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Did you show to any doctor for this problem?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["medicines"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you been taking any medicines for this problem?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "generalInvestigation"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Any general investigations you have got done?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "diabeticRetinopathy"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Do you have diabetic retinopathy?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "macularDegenerations"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Did you have macular degenerations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      patientData["macularhole"]
                                                          .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Do you have macular hole?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["glaucoma"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Do you have glaucoma?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["catract"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Do you have cataract?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["uveitis"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Do you have uveitis?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "fundusPhotography"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Fundus Photography investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "fundusAngiography"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Fundus Angiography investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "opticalCoherenceTomography"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Optical Coherence Tomography investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "visualFieldAnalysis"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Visual Field Analysis investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text:
                                                      patientData["gonioscopy"]
                                                          .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Gonioscopy investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "centralCornealThicknessAnalysis"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Central Corneal Thickness Analysis investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "slitLampInvestigation"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Slit Lamp investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "applanationTonometry"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Applanation Tonometry investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData["bScan"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got B Scan investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                controller:
                                                    TextEditingController(
                                                  text: patientData[
                                                          "biochemicalParameters"]
                                                      .toString(),
                                                ),
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(Icons
                                                      .coronavirus_rounded),
                                                  labelText:
                                                      "Have you got Biochemical Parameters investigations?",
                                                  labelStyle:
                                                      GoogleFonts.raleway(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                  leading: const Icon(Icons.assignment),
                                  title: Text(
                                    "View Questionnaire",
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) {
                                        return PatientReportsScreen(
                                          patientId: patientData["patientId"]
                                              .toString(),
                                          patientEmail: patientData["userEmail"]
                                              .toString(),
                                        );
                                      },
                                    ));
                                  },
                                  leading: const Icon(Icons.analytics_rounded),
                                  title: Text(
                                    "View Test Results",
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color:
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          if (patientData["surveyLevel"].toString() == "2") ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Tests and Reports",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: redirect to view reports screen
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return PatientReportsScreen(
                                                patientId: widget.patientId,
                                                patientEmail: patientData[
                                                        "userEmail"]
                                                    .toString()
                                            );
                                          }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 16.0,
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.temple_hindu_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        label: Text(
                                          "View Reports",
                                          style: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: redirect to add new report.
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return NewReportAdminScreen(
                                                patientId: widget.patientId,
                                                patientEmail: patientData[
                                                        "userEmail"]
                                                    .toString()
                                            );
                                          }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 16.0,
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.medical_services_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        label: Text(
                                          "New Test",
                                          style: GoogleFonts.raleway(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Tests and Reports",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  // display a container with message that says we have to complete the questionnaire before starting to take reports
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      "Complete the questionnaire to start taking tests.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onError,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 24,
                          ),
                        ] else ...[
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    "No patient found with patient-ID ${widget.patientId}!",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.sourceCodePro(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "You can add new patients by clicking the button below.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.raleway(
                                    textStyle:
                                        Theme.of(context).textTheme.titleSmall,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return const NewPatientAdminScreen();
                                    }));
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 10.0),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Text(
                                    "New Patient",
                                    style: GoogleFonts.raleway(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 24,
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
