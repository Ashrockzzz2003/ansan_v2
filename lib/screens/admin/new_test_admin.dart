import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/admin/view_patient_admin.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewReportAdminScreen extends StatefulWidget {
  const NewReportAdminScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<NewReportAdminScreen> createState() => _NewReportAdminScreenState();
}

class _NewReportAdminScreenState extends State<NewReportAdminScreen> {
  String? secretToken = "";
  String? patientToken = "";
  bool isLoading = false;

  int activeStep = 0;
  int maxIndex = 4;

  List<int> numbers = List.generate(4, (index) => index + 1);

  List<File?> imageFiles = List.generate(4, (index) => null);
  List<ImagePicker?>? imagePickers;

  List<String> questionList = [
    "Please take/upload 1st image of Left Eye",
    "Please take/upload 2nd image of Left Eye",
    "Please take/upload 1st image of Right Eye",
    "Please take/upload 2nd image of Right Eye"
  ];

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
    imagePickers = List.generate(maxIndex, (index) {
      return ImagePicker();
    });
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen(
            message: "Running Tests ... ",
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
                  expandedHeight: MediaQuery.of(context).size.height * 0.21,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return ViewPatientAdmin(patientId: widget.patientId);
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
                      "The Test",
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 8.0),
                                            child: Text(
                                              questionList[activeStep],
                                              style: GoogleFonts.raleway(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                height:
                                                    imageFiles[activeStep] ==
                                                            null
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.25
                                                        : null,
                                                width: imageFiles[activeStep] ==
                                                        null
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.5
                                                    : null,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child:
                                                    imageFiles[activeStep] ==
                                                            null
                                                        ? Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
                                                                child:
                                                                    ElevatedButton(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child: Text(
                                                                      "Upload Image from Gallery",
                                                                      style: GoogleFonts
                                                                          .raleway(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    XFile?
                                                                        image =
                                                                        await ImagePicker()
                                                                            .pickImage(
                                                                      source: ImageSource
                                                                          .gallery,
                                                                      imageQuality:
                                                                          100,
                                                                      preferredCameraDevice:
                                                                          CameraDevice
                                                                              .front,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        if (image !=
                                                                            null) {
                                                                          imageFiles[activeStep] =
                                                                              File(image.path);
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
                                                                child:
                                                                    ElevatedButton(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child: Text(
                                                                      "Take Image from Camera",
                                                                      style: GoogleFonts
                                                                          .raleway(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    XFile?
                                                                        image =
                                                                        await ImagePicker()
                                                                            .pickImage(
                                                                      source: ImageSource
                                                                          .camera,
                                                                      imageQuality:
                                                                          50,
                                                                      preferredCameraDevice:
                                                                          CameraDevice
                                                                              .front,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        if (image !=
                                                                            null) {
                                                                          imageFiles[activeStep] =
                                                                              File(image.path);
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Image.file(
                                                            imageFiles[
                                                                activeStep]!,
                                                            fit: BoxFit.cover,
                                                            scale: 1.0,
                                                          ),
                                              ),
                                              if (imageFiles[activeStep] !=
                                                  null) ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0.0, 32.0, 0.0, 0.0),
                                                  child: ElevatedButton(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        "Remove Image",
                                                        style:
                                                            GoogleFonts.raleway(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onErrorContainer,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        imageFiles[activeStep] =
                                                            null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(
                                                height: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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

    // if (kDebugMode) {
    //   print(secretToken);
    //   print(patientToken);
    // }

    if (secretToken == null || patientToken == null) {
      setState(() {
        isLoading = false;
      });
      return "-1";
    }

    try {
      // multiple files as base64 form-data and json data together

      final FormData formData = FormData.fromMap({
        "leftEye1": await MultipartFile.fromFile(
          imageFiles[0]!.path,
          filename: "leftEye1.jpg",
          contentType: MediaType("image", "jpg"),
        ),
        "leftEye2": await MultipartFile.fromFile(
          imageFiles[1]!.path,
          filename: "leftEye2.jpg",
          contentType: MediaType("image", "jpg"),
        ),
        "rightEye1": await MultipartFile.fromFile(
          imageFiles[2]!.path,
          filename: "rightEye1.jpg",
          contentType: MediaType("image", "jpg"),
        ),
        "rightEye2": await MultipartFile.fromFile(
          imageFiles[3]!.path,
          filename: "rightEye2.jpg",
          contentType: MediaType("image", "jpg"),
        ),
      });

      // if(kDebugMode) {
      //   print(formData);
      // }

      final response = await dio.post(
        Constants().predictGlaucomaUrl,
        options: Options(
          headers: {"Authorization": "Bearer $secretToken $patientToken"},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200) {
        showToast("Report processed successfully!");
        return "1";
      } else if (response.statusCode == 401) {
        showToast("Session expired. Please login again.");
        return "-1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
        return "0";
      } else {
        showToast("Something went wrong. Please try again later.");
        return "0";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        isLoading = false;
      });
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
                    imageFiles[activeStep] != null) {
                  _formKey.currentState!.save();
                  _submitSurvey().then((value) {
                    if (value == "1") {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return ViewPatientAdmin(patientId: widget.patientId);
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
                    imageFiles[activeStep] != null) {
                  _formKey.currentState!.save();

                  if (activeStep < maxIndex - 1) {
                    setState(() {
                      activeStep++;
                    });
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
                        setState(() {
                          activeStep--;
                        });
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
