import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/patient_reports_hshead.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewReportHsHeadScreen extends StatefulWidget {
  const ViewReportHsHeadScreen({
    super.key,
    required this.patientId,
    required this.reportId,
    required this.patientEmail,
  });

  final String patientId;
  final String reportId;
  final String patientEmail;

  @override
  State<ViewReportHsHeadScreen> createState() => _ViewReportHsHeadScreenState();
}

class _ViewReportHsHeadScreenState extends State<ViewReportHsHeadScreen> {
  Map<String, dynamic> reportData = {};
  Map<String, dynamic> patientData = {};

  List<dynamic> imageFiles = [];

  bool isLoading = true;

  String? secretToken;
  String? patientToken;

  String loadingMessage = "Loading ...";
  String? pdfFileName;

  final TextEditingController _doctorComment = TextEditingController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<String> _downloadReport(String reportId) async {
    setState(() {
      isLoading = true;
      loadingMessage = "Downloading $reportId ...";
    });

    final dio = Dio();

    try {
      final response = await dio.post(
        Constants().downloadReportUrl,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $secretToken",
        }),
        data: {
          "patient_token": patientToken,
          "reportId": reportId,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.data);
        }
        setState(() {
          pdfFileName = response.data["pdfName"];
        });

        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      } else {
        showToast("Something went wrong! Please try again later.");
      }

      return "0";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong!");
    } finally {
      setState(() {
        isLoading = false;
        loadingMessage = "Fetching Reports ...";
      });
    }

    return "0";
  }

  Future<String> _emailReport(String reportId, String receiverEmail) async {
    setState(() {
      isLoading = true;
      loadingMessage = "Sending Email of $reportId ...";
    });

    final dio = Dio();

    try {
      final response = await dio.post(
        Constants().emailReportUrl,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $secretToken",
        }),
        data: {
          "receiverEmail": receiverEmail,
          "patient_token": patientToken,
          "reportId": reportId,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.data);
        }

        showToast("Email sent successfully to $receiverEmail!");

        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      } else {
        showToast("Something went wrong! Please try again later.");
      }

      return "0";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong!");
    } finally {
      setState(() {
        isLoading = false;
        loadingMessage = "Loading ...";
      });
    }

    return "0";
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
              "leftEye":
              "${(double.parse(reportD["modelOutput"].toString().split(",")[0]) * 100)} %",
              "rightEye":
              "${(double.parse(reportD["modelOutput"].toString().split(",")[1]) * 100)} %",
              "description": reportD["description"],
              "descriptionMangerId": reportD["descriptionMangerId"],
              "timeStamp": reportD["reportTimestamp"],
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
                      return PatientReportsHsHeadScreen(
                        patientId: widget.patientId,
                        patientEmail: widget.patientEmail,
                      );
                    }), (route) => false);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _downloadReport(widget.reportId.toString())
                      .then((value) {
                    if (value == "1") {
                      launchUrl(
                        Uri.parse(
                          "https://ansan.cb.amrita.edu/report/$pdfFileName.pdf",
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (value == "0") {
                      // failure
                    } else if (value == "-1") {
                      // session expired
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                            return const WelcomeScreen();
                          }), (route) => false);
                    }
                  });
                },
                icon: const Icon(Icons.file_download_outlined),
              ),
            ],
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
                    height: 24,
                  ),
                  // disclaimer that the reports are predicted by the model and not by an actual doctor. Like a warning Card with icon
                  Card(
                    borderOnForeground: true,
                    color: Theme.of(context).colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color:
                                Theme.of(context).colorScheme.onError,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Disclaimer",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onError,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Divider(
                            thickness: 1,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "These reports are predicted by an AI model and not by an actual doctor and only serve as a preliminary diagnosis.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              textStyle:
                              Theme.of(context).textTheme.bodyLarge,
                              fontWeight: FontWeight.w500,
                              color:
                              Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          const SizedBox(
                            height: 16,
                          ),
                          Chip(
                            label: Text(
                              DateFormat("EEEE d/M/y h:mm a").format(
                                DateTime.parse(
                                  reportData["timeStamp"].toString(),
                                ).toLocal(),
                              ),
                              style: GoogleFonts.sourceCodePro(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(
                            height: 16,
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
                            ClipRect(
                              child: Image.network(
                                imageFiles[i],
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width *
                                    0.84,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
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

                  Card(
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                "Doctor's Comments",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (reportData["description"] != null) ...[
                            TextField(
                              controller: TextEditingController(
                                text: reportData["description"] ?? "",
                              ),
                              maxLines: null,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                          ] else ...[
                            Text(
                              "No comments yet.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                textStyle:
                                Theme.of(context).textTheme.bodyLarge,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width * 0.84,
                            child: ElevatedButton.icon(
                              label: Text(
                                "View Questionnaire",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              icon: Icon(
                                Icons.question_answer_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
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
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text(
                                                "Questionnaire",
                                                style:
                                                GoogleFonts.raleway(
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              patientData["allergies"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText: "Your allergies",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              patientData["symptoms"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText: "Symptoms",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              "medication"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .medical_services_rounded),
                                              labelText:
                                              "Any long term medication? Please specify. (Enter NIL if none)",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              patientData["consulted"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText:
                                              "Did you show to any doctor for this problem?",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              patientData["medicines"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText:
                                              "Have you been taking any medicines for this problem?",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              "macularhole"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText:
                                              "Do you have macular hole?",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              patientData["glaucoma"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText:
                                              "Do you have glaucoma?",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                              "gonioscopy"]
                                                  .toString(),
                                            ),
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(Icons
                                                  .coronavirus_rounded),
                                              labelText:
                                              "Have you got Gonioscopy investigations?",
                                              labelStyle:
                                              GoogleFonts.raleway(
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                                                textStyle:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                                borderSide: BorderSide(
                                                    color: Theme.of(
                                                        context)
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
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width * 0.84,
                            child: ElevatedButton.icon(
                              label: Text(
                                "Download Report",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              icon: Icon(
                                Icons.download_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                backgroundColor:
                                Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                _downloadReport(
                                    widget.reportId.toString())
                                    .then(
                                      (value) {
                                    if (value == "1") {
                                      launchUrl(
                                        Uri.parse(
                                          "https://ansan.cb.amrita.edu/report/$pdfFileName.pdf",
                                        ),
                                        mode: LaunchMode
                                            .externalApplication,
                                      );
                                    } else if (value == "0") {
                                      // failure
                                    } else if (value == "-1") {
                                      // session expired
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                                return const WelcomeScreen();
                                              }), (route) => false);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Email Report",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (widget.patientEmail.isNotEmpty) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.84,
                              child: ElevatedButton.icon(
                                label: Text(
                                  "Email Patient",
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary,
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                onPressed: () {
                                  _emailReport(widget.reportId,
                                      widget.patientEmail)
                                      .then((value) {
                                    if (value == "1") {
                                      // success
                                    } else if (value == "0") {
                                      // failure
                                    } else if (value == "-1") {
                                      // session expired
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                                return const WelcomeScreen();
                                              }), (route) => false);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 8,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width * 0.84,
                            child: Form(
                              key: _emailFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    style: GoogleFonts.sourceCodePro(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return "Please give a email to send the report to.";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Custom Email",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer),
                                      ),
                                      focusedErrorBorder:
                                      OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer),
                                      ),
                                      labelStyle: GoogleFonts.raleway(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      label: Text(
                                        "Send Email",
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.send_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16.0),
                                        ),
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 16.0),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      onPressed: () {
                                        if (_emailFormKey.currentState!
                                            .validate()) {
                                          _emailReport(
                                              widget.reportId,
                                              _emailController.text
                                                  .trim()
                                                  .toString())
                                              .then((value) {
                                            if (value == "1") {
                                              // success
                                            } else if (value == "0") {
                                              // failure
                                            } else if (value == "-1") {
                                              // session expired
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                  CupertinoPageRoute(
                                                      builder:
                                                          (context) {
                                                        return const WelcomeScreen();
                                                      }), (route) => false);
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
