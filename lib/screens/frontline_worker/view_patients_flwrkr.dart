import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/flwrkr_screen.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/new_patient_flwrkr.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/view_patient_flwrkr.dart';
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

class ViewPatientsFrontLineWorker extends StatefulWidget {
  const ViewPatientsFrontLineWorker({super.key});

  @override
  State<ViewPatientsFrontLineWorker> createState() =>
      _ViewPatientsFrontLineWorkerState();
}

class _ViewPatientsFrontLineWorkerState
    extends State<ViewPatientsFrontLineWorker> {
  final List<dynamic> patientList = [];
  bool isLoading = true;

  String? secretToken;
  String? patientToken;
  String loadingMessage = "Fetching Patients ...";

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

      Dio()
          .get(
        Constants().viewPatientsUrl,
        options: Options(
          headers: {"Authorization": "Bearer $secretToken"},
          validateStatus: (status) => status! < 500,
        ),
      )
          .then((response) {
        if (kDebugMode) {
          print(response.data);
        }

        if (response.statusCode == 200) {
          if (response.data["message"] != "No users") {
            setState(() {
              patientList.addAll(
                response.data["message"],
              );
            });

            if (patientList.isEmpty) {
              loadingMessage = "No patients found!";
            }

          } else if (response.data["message"] != null) {
            showToast(response.data["message"]);
          } else {
            showToast("Something went wrong! Please try again later.");
          }

          if (kDebugMode) {
            print(response.data);
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

    setState(() {
      isLoading = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || (patientList.isEmpty && isLoading)
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
                        return const FrontLineWorkerScreen();
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
                      "Patients Added by Me",
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
                          height: 16.0,
                        ),
                        if (patientList.isEmpty) ...[
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
                                    "No patients found!",
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
                                  "You can add patients by clicking the button below.",
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
                                      return const NewPatientFrontlineWorkerScreen();
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
                                    "Add New Patient",
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
                        ] else ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: patientList.length,
                            itemBuilder: (context, index) {
                              return ExpansionTile(
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
                                  "ID: ${patientList[index]["patientId"]}",
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
                                  children: [
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    const Divider(
                                      thickness: 1,
                                    ),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Text(
                                      patientList[index]["userName"],
                                      style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        DateFormat("d/M/y h:mm a").format(
                                          DateTime.parse(
                                            patientList[index]["timeStamp"]
                                                .toString(),
                                          ),
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
                                        return ViewPatientFrontlineWorkerScreen(
                                            patientId: patientList[index]
                                                    ["patientId"]
                                                .toString());
                                      }));
                                    },
                                    leading: const Icon(Icons.person),
                                    title: Text(
                                      "View Patient",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
