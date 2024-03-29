import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/new_test_flwrkr.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/view_patient_flwrkr.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/view_report_flwrkr.dart';
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

class PatientReportsFrontlineWorkerScreen extends StatefulWidget {
  const PatientReportsFrontlineWorkerScreen(
      {super.key, required this.patientId, required this.patientEmail});

  final String patientId;
  final String patientEmail;

  @override
  State<PatientReportsFrontlineWorkerScreen> createState() =>
      _PatientReportsFrontlineWorkerScreenState();
}

class _PatientReportsFrontlineWorkerScreenState
    extends State<PatientReportsFrontlineWorkerScreen> {
  final List<Map<String, dynamic>> patientReports = [];
  bool isLoading = true;

  String? pdfFileName;

  String? secretToken;
  String? patientToken;
  String loadingMessage = "Fetching Reports ...";

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
        Constants().allPatientReportsUrl,
        options: Options(
          headers: {"Authorization": "Bearer $secretToken"},
          validateStatus: (status) => status! < 500,
        ),
        data: {
          "patient_token": patientToken,
        },
      ).then((response) {
        if (kDebugMode) {
          print(response.data);
        }

        if (response.statusCode == 200) {
          if (response.data["id"] == null) {
            setState(() {
              patientReports.clear();
            });
          } else if (response.data["id"].length > 0) {
            for (final report in response.data["id"]) {
              setState(() {
                patientReports.add({
                  "reportId": report["reportId"].toString(),
                  "leftEye": int.parse(
                              report["modelOutput"].toString().split(",")[0]) ==
                          0
                      ? "Negative"
                      : "Positive",
                  "rightEye": int.parse(
                              report["modelOutput"].toString().split(",")[1]) ==
                          0
                      ? "Negative"
                      : "Positive",
                  "timeStamp": report["reportTimeStamp"].toString(),
                });
              });
            }
          } else {
            setState(() {
              patientReports.clear();
            });
          }

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
        showToast("Something went wrong! 1");
        setState(() {
          isLoading = false;
        });
      });
    });

    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen(
            message: loadingMessage,
          )
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
                        return ViewPatientFrontlineWorkerScreen(
                            patientId: widget.patientId);
                      }), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 8.0),
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
                      "Patient Reports",
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

                        if (patientReports.isEmpty) ...[
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
                                    "No reports found! Please take a new test to view reports.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
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
                                  "You can take a new test by clicking the button below.",
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
                                      return NewReportFrontlineWorkerScreen(
                                        patientId: widget.patientId,
                                        patientEmail: widget.patientEmail,
                                      );
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
                                    "New Test",
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
                        // build a list view with patient id as avatar and patient name as title
                        ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: patientReports.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: ExpansionTile(
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
                                title: Text(
                                  "ID: ${patientReports[index]["reportId"]}",
                                  style: GoogleFonts.sourceCodePro(
                                    textStyle:
                                        Theme.of(context).textTheme.titleLarge,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Chip(
                                      label: Text(
                                        DateFormat("E d/M/y h:mm a").format(
                                          DateTime.parse(patientReports[index]
                                                  ["timeStamp"])
                                              .toLocal(),
                                        ),
                                        style: GoogleFonts.sourceCodePro(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        Chip(
                                          padding: const EdgeInsets.all(2.0),
                                          label: Text(
                                            "Left Eye  ",
                                            style: GoogleFonts.raleway(),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Chip(
                                          padding: const EdgeInsets.all(2.0),
                                          label: Text(
                                            patientReports[index]["leftEye"],
                                            style: GoogleFonts.raleway(
                                              fontWeight: FontWeight.w500,
                                              color: patientReports[index]
                                                          ["leftEye"] ==
                                                      "Negative"
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onError,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          backgroundColor: patientReports[index]
                                                      ["leftEye"] ==
                                                  "Negative"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Chip(
                                          padding: const EdgeInsets.all(2.0),
                                          label: Text(
                                            "Right Eye",
                                            style: GoogleFonts.raleway(),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Chip(
                                          padding: const EdgeInsets.all(2.0),
                                          label: Text(
                                            patientReports[index]["rightEye"],
                                            style: GoogleFonts.raleway(
                                              fontWeight: FontWeight.w500,
                                              color: patientReports[index]
                                                          ["rightEye"] ==
                                                      "Negative"
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onError,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          backgroundColor: patientReports[index]
                                                      ["rightEye"] ==
                                                  "Negative"
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  const Divider(
                                    thickness: 1,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return ViewReportFrontlineWorkerScreen(
                                          patientEmail: widget.patientEmail,
                                          patientId: widget.patientId,
                                          reportId: patientReports[index]
                                                  ["reportId"]
                                              .toString(),
                                        );
                                      }));
                                    },
                                    leading: const Icon(Icons.assignment),
                                    title: Text(
                                      "View Entire Report",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      // TODO: download report
                                      _downloadReport(patientReports[index]
                                                  ["reportId"]
                                              .toString())
                                          .then((value) {
                                        if (value == "1") {
                                          launchUrl(
                                            Uri.parse(
                                              "http://localhost:3001/report/$pdfFileName.pdf",
                                            ),
                                            mode: LaunchMode.inAppWebView,
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
                                      });
                                    },
                                    leading: const Icon(
                                        Icons.file_download_outlined),
                                    title: Text(
                                      "Download Report",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            );
                          },
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
