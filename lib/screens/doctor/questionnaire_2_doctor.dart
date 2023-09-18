import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/model/question.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/doctor/view_patient_doctor.dart';
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

class Questionnaire15cDoctorScreen extends StatefulWidget {
  const Questionnaire15cDoctorScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<Questionnaire15cDoctorScreen> createState() =>
      _Questionnaire15cDoctorScreenState();
}

class _Questionnaire15cDoctorScreenState
    extends State<Questionnaire15cDoctorScreen> {
  String? secretToken = "";
  String? patientToken = "";
  bool isLoading = false;

  int activeStep = 0;
  int maxIndex = 23;

  List<int> numbers = List.generate(23, (index) => index + 1);

  late List<TextEditingController> controllers;

  late List<Question> questionList;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("SECRET_TOKEN") && sp.containsKey("patient_token")) {
        secretToken = sp.getString("SECRET_TOKEN");
        patientToken = sp.getString("patient_token");
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
      // Level 2
      /*
      req.body.redness == null ||
      req.body.pain == null ||
      req.body.halos == null ||
      req.body.suddenExacerbation == null ||
      req.body.consulted == null ||
      req.body.medicines == null ||
      req.body.generalInvestigation == null ||
      req.body.diabeticRetinopathy == null ||
      req.body.macularDegenerations == null ||
      req.body.macularhole == null ||
      req.body.glaucoma == null ||
      req.body.catract == null ||
      req.body.uveitis == null ||
      req.body.fundusPhotography == null ||
      req.body.fundusAngiography == null ||
      req.body.opticalCoherenceTomography == null ||
      req.body.visualFieldAnalysis == null ||
      req.body.gonioscopy == null ||
      req.body.centralCornealThicknessAnalysis == null ||
      req.body.slitLampInvestigation == null ||
      req.body.applanationTonometry == null ||
      req.body.bScan == null ||
      req.body.biochemicalParameters == null
      */
      Question(
        questionFull: "Do you face Redness of eye?",
        questionLabel: "Redness Of Eye",
        placeHolder: "Redness Of Eye",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[0],
      ),
      Question(
        questionFull: "Do you face pain in eye?",
        questionLabel: "Pain In Eyes",
        placeHolder: "Pain In Eyes",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[1],
      ),
      Question(
        questionFull: "Do you see halos around lights?",
        questionLabel: "Halos around lights",
        placeHolder: "Halos around lights",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[2],
      ),
      Question(
        questionFull: "Any time you had sudden exacerbation of the problem?",
        questionLabel: "Sudden Exacerbation",
        placeHolder: "Sudden Exacerbation",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[3],
      ),
      Question(
        questionFull: "Did you show to any doctor for this problem?",
        questionLabel: "Consulted",
        placeHolder: "Consulted",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[4],
      ),
      Question(
        questionFull: "Have you been taking any medicines for this problem?",
        questionLabel: "Medicines",
        placeHolder: "Medicines",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[5],
      ),
      Question(
        questionFull: "Any general investigations you have got done?",
        questionLabel: "General Investigations",
        placeHolder: "General Investigations",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[6],
      ),
      Question(
        questionFull: "Do you have diabetic retinopathy?",
        questionLabel: "Diabetic Retinopathy",
        placeHolder: "Diabetic Retinopathy",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[7],
      ),
      Question(
        questionFull: "Do you have macular degenerations?",
        questionLabel: "Macular Degenerations",
        placeHolder: "Macular Degenerations",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[8],
      ),
      Question(
        questionFull: "Do you have macular hole?",
        questionLabel: "Macular Hole",
        placeHolder: "Macular Hole",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[9],
      ),
      Question(
        questionFull: "Do you have glaucoma?",
        questionLabel: "Glaucoma",
        placeHolder: "Glaucoma",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[10],
      ),
      Question(
        questionFull: "Do you have cataract?",
        questionLabel: "Cataract",
        placeHolder: "Cataract",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[11],
      ),
      Question(
        questionFull: "Do you have uveitis?",
        questionLabel: "Uveitis",
        placeHolder: "Uveitis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[12],
      ),
      Question(
        questionFull: "Have you got Fundus Photography investigations?",
        questionLabel: "Fundus Photography",
        placeHolder: "Fundus Photography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[13],
      ),
      Question(
        questionFull: "Have you got Fundus Angiography investigations?",
        questionLabel: "Fundus Angiography",
        placeHolder: "Fundus Angiography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[14],
      ),
      Question(
        questionFull:
            "Have you got Optical Coherence Tomography investigations?",
        questionLabel: "Optical Coherence Tomography",
        placeHolder: "Optical Coherence Tomography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[15],
      ),
      Question(
        questionFull: "Have you got Visual Field Analysis investigations?",
        questionLabel: "Visual Field Analysis",
        placeHolder: "Visual Field Analysis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[16],
      ),
      Question(
        questionFull: "Have you got Gonioscopy investigations?",
        questionLabel: "Gonioscopy",
        placeHolder: "Gonioscopy",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[17],
      ),
      Question(
        questionFull:
            "Have you got Central Corneal Thickness Analysis investigations?",
        questionLabel: "Central Corneal Thickness Analysis",
        placeHolder: "Central Corneal Thickness Analysis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[18],
      ),
      Question(
        questionFull: "Have you got Slit Lamp investigations?",
        questionLabel: "Slit Lamp",
        placeHolder: "Slit Lamp",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[19],
      ),
      Question(
        questionFull: "Have you got Applanation Tonometry investigations?",
        questionLabel: "Applanation Tonometry",
        placeHolder: "Applanation Tonometry",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[20],
      ),
      Question(
        questionFull: "Have you got B Scan investigations?",
        questionLabel: "B Scan",
        placeHolder: "B Scan",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[21],
      ),
      Question(
        questionFull: "Have you got Biochemical Parameters investigations?",
        questionLabel: "Biochemical Parameters",
        placeHolder: "Biochemical Parameters",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[22],
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
                        return ViewPatientDoctor(patientId: widget.patientId);
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
                      "Questionnaire 2",
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

    if (secretToken == null || patientToken == null) {
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
          "patient_token": patientToken,
          "redness": controllers[0].text.toString(),
          "pain": controllers[1].text.toString(),
          "halos": controllers[2].text.toString(),
          "suddenExacerbation": controllers[3].text.toString(),
          "consulted": controllers[4].text.toString(),
          "medicines": controllers[5].text.toString(),
          "generalInvestigation": controllers[6].text.toString(),
          "diabeticRetinopathy": controllers[7].text.toString(),
          "macularDegenerations": controllers[8].text.toString(),
          "macularhole": controllers[9].text.toString(),
          "glaucoma": controllers[10].text.toString(),
          "catract": controllers[11].text.toString(),
          "uveitis": controllers[12].text.toString(),
          "fundusPhotography": controllers[13].text.toString(),
          "fundusAngiography": controllers[14].text.toString(),
          "opticalCoherenceTomography": controllers[15].text.toString(),
          "visualFieldAnalysis": controllers[16].text.toString(),
          "gonioscopy": controllers[17].text.toString(),
          "centralCornealThicknessAnalysis": controllers[18].text.toString(),
          "slitLampInvestigation": controllers[19].text.toString(),
          "applanationTonometry": controllers[20].text.toString(),
          "bScan": controllers[21].text.toString(),
          "biochemicalParameters": controllers[22].text.toString()
        },
      );

      if (kDebugMode) {
        print(response.data);
      }

      if (response.statusCode == 200) {
        showToast("Survey submitted successfully!");
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
                        return ViewPatientDoctor(patientId: widget.patientId);
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
