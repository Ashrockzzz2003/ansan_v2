import 'dart:convert';

import 'package:eperimetry_vtwo/screens/hospital_head/hshead_profile_screen.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/new_official_hshead_screen.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/new_patient_hshead.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/view_officials_hshead.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/view_patient_hshead.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/view_patients_hshead.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HsHeadScreen extends StatefulWidget {
  const HsHeadScreen({super.key});

  @override
  State<HsHeadScreen> createState() => _HsHeadScreenState();
}

class _HsHeadScreenState extends State<HsHeadScreen> {
  bool isLoading = true;

  Map<String, dynamic>? hsHead;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("currentUser")) {
        final currentUser = sp.getString("currentUser");
        setState(() {
          hsHead = jsonDecode(currentUser!);
        });
      } else {
        showToast("Please login again.");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const WelcomeScreen();
        }), (route) => false);
      }
    });
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || hsHead == null
        ? const LoadingScreen()
        : Scaffold(
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const HsHeadProfileScreen()));
                    },
                    icon: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        SharedPreferences.getInstance().then((sp) {
                          final userEmail = sp.getString("userEmail");
                          sp.clear();
                          sp.setString("userEmail", userEmail!);
                        });
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(builder: (context) {
                          return const WelcomeScreen();
                        }), (route) => false);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/logo.png",
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            "${hsHead!["managerName"]}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              textStyle: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Chip(
                            padding: const EdgeInsets.all(2.0),
                            label: Text(
                              "Hospital Head",
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
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
                                  Text(
                                    "Manage Officials",
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
                                          // TODO: redirect to all members.
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return const ViewOfficialsHsHeadScreen();
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
                                          "View Officials",
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
                                          // TODO: redirect to add new Member.
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return const NewOfficialHsHeadScreen();
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
                                          Icons.add_circle_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        label: Text(
                                          "New Official",
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
                                  Text(
                                    "Manage Patients",
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
                                  Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      textInputAction: TextInputAction.search,
                                      onFieldSubmitted: (value) {
                                        if (_formKey.currentState!.validate()) {
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) {
                                            return ViewPatientHsHead(
                                              patientId:
                                                  value.trim().toString(),
                                            );
                                          }));
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.sourceCodePro(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                      controller: _searchController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a valid Patient ID";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText:
                                            "Search patient by Patient ID",
                                        suffixIcon: IconButton(
                                            icon: Icon(Icons.search_rounded,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                Navigator.of(context).push(
                                                    CupertinoPageRoute(
                                                        builder: (context) {
                                                  return ViewPatientHsHead(
                                                    patientId: _searchController
                                                        .text
                                                        .trim()
                                                        .toString(),
                                                  );
                                                }));
                                              }
                                            }),
                                        hintText: "Please enter the Patient ID",
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer),
                                        ),
                                        labelStyle: GoogleFonts.raleway(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            CupertinoPageRoute(
                                                builder: (context) {
                                          return const NewPatientHsHeadScreen();
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
                                        "New Patient",
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
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            CupertinoPageRoute(
                                                builder: (context) {
                                          return const ViewPatientsHsHead();
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
                                        Icons.remove_red_eye_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      label: Text(
                                        "View Patients",
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
