import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/model/question.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSurveyLevelOneScreen extends StatefulWidget {
  const UserSurveyLevelOneScreen({super.key});

  @override
  State<UserSurveyLevelOneScreen> createState() =>
      _UserSurveyLevelOneScreenState();
}

class _UserSurveyLevelOneScreenState extends State<UserSurveyLevelOneScreen> {
  String? secretToken = "";
  bool isLoading = false;

  int activeStep = 0;
  int maxIndex = 12;

  List<int> numbers = List.generate(12, (index) => index + 1);

  late List<TextEditingController> controllers;

  late List<Question> questionList;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("SECRET_TOKEN")) {
        secretToken = sp.getString("SECRET_TOKEN");
      } else {
        showToast("Session expired. Please login again.");
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const WelcomeScreen();
        }), (route) => false);
      }
    });

    controllers = List.generate(maxIndex, (index) {
      return TextEditingController();
    });

    questionList = [
      Question(
        questionFull: "Please enter your height in cm",
        questionLabel: "Height",
        placeHolder: "Your height in (cm)",
        icon: const Icon(Icons.height_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: false,
        isNumber: true,
        controller: controllers[0],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please enter your weight in kg",
        questionLabel: "Weight",
        placeHolder: "Your weight in (kg)",
        icon: const Icon(Icons.balance_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: false,
        isNumber: true,
        controller: controllers[1],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please select your COVID vaccination status",
        questionLabel: "Vaccination Status",
        placeHolder: "Your vaccination status",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const [
          "Fully Vaccinated",
          "Partially Vaccinated",
          "Not Vaccinated"
        ],
        values: const [
          "Fully Vaccinated",
          "Partially Vaccinated",
          "Not Vaccinated"
        ],
        controller: controllers[2],
      ),
      Question(
        questionFull: "Do you have any allergies?",
        questionLabel: "Allergies",
        placeHolder: "Your allergies",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No"],
        values: const ["Yes", "No"],
        controller: controllers[3],
      ),
      Question(
        questionFull: "Please enter your allergies",
        questionLabel: "Allergies",
        placeHolder: "Your allergies",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[4],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please enter symptoms observed. (Enter NIL if none)",
        questionLabel: "Symptoms",
        placeHolder: "Your symptoms",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[5],
        validator: _fieldValidator,
      ),
      Question(
        questionFull:
            "How long have you been experiencing symptoms? (Enter NIL if none)",
        questionLabel: "Symptoms Duration",
        placeHolder: "x days or y weeks",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[6],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Any accidents or injuries?",
        questionLabel: "Accidents/Injuries",
        placeHolder: "Your accidents/injuries",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No"],
        values: const ["Yes", "No"],
        controller: controllers[7],
      ),
      Question(
        questionFull:
            "Any long term medication? Please specify. (Enter NIL if none)",
        questionLabel: "Medication",
        placeHolder: "Your medication",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[8],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Any past medical history.",
        questionLabel: "Medical History",
        placeHolder: "Your medical history",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Blood Pressure",
          "Diabetes",
          "Eye Diseases",
          "Thyroid",
          "Other Comorbidity Conditions",
          "None"
        ],
        values: const [
          "Blood Pressure",
          "Diabetes",
          "Eye Diseases",
          "Thyroid",
          "Other Comorbidity Conditions",
          "None"
        ],
        controller: controllers[9],
      ),
      Question(
        questionFull: "Other consumptions.",
        questionLabel: "Consumptions",
        placeHolder: "Your consumptions",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Tobacco Chewing",
          "Smoking",
          "Alcohol",
          "Others",
          "None"
        ],
        values: const [
          "Tobacco Chewing",
          "Smoking",
          "Alcohol",
          "Others",
          "None"
        ],
        controller: controllers[10],
      ),
      Question(
        questionFull: "Family History",
        questionLabel: "Family History",
        placeHolder: "Your family history",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Blood Pressure",
          "Diabetes",
          "Glaucoma",
          "Cataract",
          "Diabetic Retinopathy",
          "Other Eye Disease",
          "None"
        ],
        values: const [
          "Blood Pressure",
          "Diabetes",
          "Glaucoma",
          "Cataract",
          "Diabetic Retinopathy",
          "Other Eye Disease",
          "None"
        ],
        controller: controllers[11],
      ),
    ];
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                  expandedHeight: MediaQuery.of(context).size.height * 0.21,
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
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.2),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Questionnaire 1",
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          NumberStepper(
                            activeStepColor:
                                Theme.of(context).primaryIconTheme.color,
                            activeStepBorderColor:
                                Theme.of(context).secondaryHeaderColor,
                            stepColor: Theme.of(context).splashColor,
                            lineColor: Theme.of(context).secondaryHeaderColor,
                            stepReachedAnimationEffect: Curves.easeInOutCubic,
                            enableStepTapping: false,
                            direction: Axis.horizontal,
                            enableNextPreviousButtons: false,
                            numbers: numbers,
                            activeStep: activeStep,
                            lineLength: 24,
                            onStepReached: (index) {
                              setState(() {
                                activeStep = index;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              previousButton(),
                              nextButton(),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            child: Column(
                              children: [
                                Form(
                                    autovalidateMode: AutovalidateMode.disabled,
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        questionList[activeStep],
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
  }

  Future<String> _submitSurvey() async {
    setState(() {
      isLoading = true;
    });

    final dio = Dio();

    final sp = await SharedPreferences.getInstance();
    final Map<String, dynamic>? user = jsonDecode(sp.getString("currentUser")!);
    final String? secretToken = sp.getString("SECRET_TOKEN");

    if (secretToken == null) {
      showToast("Session Expired! Please login again.");
      return "-1";
    }

    try {
      final response = await dio.post(
        Constants().takeSurvey15aUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $secretToken"
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: {
          "height": controllers[0].text.toString(),
          "weight": controllers[1].text.toString(),
          "covidVaccination": controllers[2].text.toString(),
          "anyAllergies": controllers[3].text.toString() == "Yes" ? 1 : 0,
          "allergies": controllers[4].text.toString(),
          "symptoms": controllers[5].text.toString(),
          "symptomDuration": controllers[6].text.toString(),
          "injury": controllers[7].text.toString(),
          "medication": controllers[8].text.toString(),
          "medicalHistory": controllers[9].text.toString(),
          "consumptions": controllers[10].text.toString(),
          "familyHistory": controllers[11].text.toString(),
        },
      );

      if (response.statusCode == 200) {
        showToast("Survey submitted successfully!");
        user!["surveyLevel"] = "1";
        sp.setString("currentUser", jsonEncode(user));
        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
        return "0";
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      } else {
        showToast("Something went wrong. Please try again later.");
        return "0";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong. Please try again later.");
      return "0";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: MaterialButton(
        onPressed: activeStep == maxIndex - 1
            ? () async {
                if (_formKey.currentState!.validate() &&
                    controllers[activeStep].text.isNotEmpty) {
                  _formKey.currentState!.save();
                  _submitSurvey().then((value) {
                    if (value == "1") {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return const UserScreen();
                      }), (route) => false);
                    } else if (value == "-1") {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return const LoginScreen();
                      }), (route) => false);
                    } else {
                      setState(() {
                        activeStep = 0;
                      });
                    }
                  });
                } else {
                  showToast(
                    "Please select an option or fill the filed to proceed",
                  );
                }
              }
            : () {
                if (_formKey.currentState!.validate() &&
                    controllers[activeStep].text.isNotEmpty) {
                  _formKey.currentState!.save();

                  if (activeStep < maxIndex - 1) {
                    if (activeStep == 3) {
                      if (controllers[activeStep].text == "Yes") {
                        setState(() {
                          activeStep++;
                        });
                      } else {
                        setState(() {
                          controllers[activeStep + 1].text = "NIL";
                          activeStep += 2;
                        });
                      }
                    } else {
                      setState(() {
                        activeStep++;
                      });
                    }
                  }
                } else {
                  showToast(
                      "Please select an option or fill the filed to proceed");
                }
              },
        minWidth:
            activeStep == 0 ? MediaQuery.of(context).size.width * 0.8 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          activeStep == maxIndex - 1 ? "Submit" : "Next",
          style: GoogleFonts.raleway(
            textStyle: Theme.of(context).textTheme.titleLarge,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  Widget previousButton() {
    return activeStep > 0
        ? Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: MaterialButton(
              onPressed: activeStep <= 0
                  ? null
                  : () {
                      // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
                      if (activeStep > 0) {
                        if (activeStep == 5) {
                          if (controllers[3].text == "Yes") {
                            setState(() {
                              activeStep--;
                            });
                          } else {
                            setState(() {
                              controllers[activeStep - 1].text = "NIL";
                              activeStep -= 2;
                            });
                          }
                        } else {
                          setState(() {
                            activeStep--;
                          });
                        }
                      }
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              color: activeStep > 0
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).disabledColor,
              child: Text(
                "Previous",
                style: GoogleFonts.raleway(
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
