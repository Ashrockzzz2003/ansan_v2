import 'dart:convert';

import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewUserSurveyLevelOneScreen extends StatefulWidget {
  const ViewUserSurveyLevelOneScreen({super.key});

  @override
  State<ViewUserSurveyLevelOneScreen> createState() =>
      _ViewUserSurveyLevelOneScreenState();
}

class _ViewUserSurveyLevelOneScreenState
    extends State<ViewUserSurveyLevelOneScreen> {
  int maxIndex = 12;

  final List<TextEditingController> _controllers =
      List.generate(12, (index) => TextEditingController());

  final List<String> questionText = [
    "Please enter your height in cm",
    "Please enter your weight in kg",
    "Please select your COVID vaccination status",
    "Do you have any allergies?",
    "Please enter your allergies",
    "Please enter symptoms observed. (Enter NIL if none)",
    "How long have you been experiencing symptoms? (Enter NIL if none)",
    "Any accidents or injuries?",
    "Any long term medication? Please specify. (Enter NIL if none)",
    "Any past medical history.",
    "Other consumptions.",
    "Family History",
  ];

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      final Map<String, dynamic> surveyLevelOne =
          jsonDecode(sp.getString("surveyOneData") ?? "");

      if (surveyLevelOne.isEmpty) {
        Navigator.pop(context);
        return;
      }

      _controllers[0].text = surveyLevelOne["height"];
      _controllers[1].text = surveyLevelOne["weight"];
      _controllers[2].text = surveyLevelOne["covidVaccination"];
      _controllers[3].text = surveyLevelOne["anyAllergies"];
      _controllers[4].text = surveyLevelOne["allergies"];
      _controllers[5].text = surveyLevelOne["symptoms"];
      _controllers[6].text = surveyLevelOne["symptomDuration"];
      _controllers[7].text = surveyLevelOne["injury"];
      _controllers[8].text = surveyLevelOne["medication"];
      _controllers[9].text = surveyLevelOne["medicalHistory"];
      _controllers[10].text = surveyLevelOne["consumptions"];
      _controllers[11].text = surveyLevelOne["familyHistory"];
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return const UserScreen();
                }), (route) => false);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Image.asset(
                "assets/login.png",
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
              ),
              title: Text(
                "Questionnaire Level 1",
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
                  Image.asset(
                    "assets/logo.png",
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.25,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  for (int i = 0; i < maxIndex; i++) ... [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              questionText[i],
                              textAlign: TextAlign.left,
                              style: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.merge(TextStyle(
                                    fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant))),

                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: _controllers[i],
                              readOnly: true,
                              style: GoogleFonts.raleway(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.merge(TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary))),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
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
