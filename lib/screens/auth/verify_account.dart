import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/model/manager.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/doctor/doctor_screen.dart';
import 'package:eperimetry_vtwo/screens/frontline_worker/flwrkr_screen.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/hshead_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen(
      {super.key, required this.secretToken, required this.userEmail});

  final String secretToken;
  final String userEmail;

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String otpCode = "";

  String? _otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the OTP.";
    } else if (value.length != 6) {
      return "Please enter a valid OTP.";
    }
    return null;
  }

  Future<String> _verifyOtpAndLogin() async {
    final dio = Dio();

    try {
      final response = await dio.post(
        Constants().verifyManagerDetailsUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.secretToken}",
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: {
          "otp": otpCode,
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences.getInstance().then((sp) {
          sp.setString("SECRET_TOKEN", response.data["SECRET_TOKEN"]);
          final userData = response.data["details"];

          if (response.data["role"] == "HSPHEAD") {
            showToast("Account verified successfully.");
            final Manager manager = Manager(
              managerId: userData["managerId"].toString(),
              phoneNumber: userData["phoneNumber"].toString(),
              managerName: userData["managerName"].toString(),
              userEmail: userData["userEmail"].toString(),
              officeName: userData["officeName"].toString(),
              role: response.data["role"].toString(),
            );

            sp.setString("currentUser", manager.toJson());
            sp.setString("userEmail", userData["userEmail"].toString());
          } else if (response.data["role"] == "DOCTOR") {
            showToast("Account verified successfully.");
            final Manager manager = Manager(
              managerId: userData["managerId"].toString(),
              phoneNumber: userData["phoneNumber"].toString(),
              managerName: userData["managerName"].toString(),
              userEmail: userData["userEmail"].toString(),
              officeName: userData["officeName"].toString(),
              role: response.data["role"].toString(),
            );

            sp.setString("currentUser", manager.toJson());
            sp.setString("userEmail", userData["userEmail"].toString());
          } else if (response.data["role"] == "FRONTLINEWORKER") {
            showToast("Account verified successfully.");
            final Manager manager = Manager(
              managerId: userData["managerId"].toString(),
              phoneNumber: userData["phoneNumber"].toString(),
              managerName: userData["managerName"].toString(),
              userEmail: userData["userEmail"].toString(),
              officeName: userData["officeName"].toString(),
              role: response.data["role"].toString(),
            );

            sp.setString("currentUser", manager.toJson());
            sp.setString("userEmail", userData["userEmail"].toString());
          }
        });

        if (response.data["role"] == "HSPHEAD") {
          return "1";
        } else if (response.data["role"] == "DOCTOR") {
          return "2";
        } else if (response.data["role"] == "FRONTLINEWORKER") {
          return "3";
        }
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
        return "0";
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        showToast("Unauthorized access. Please try again later.");
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
    }

    return "0";
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
                  expandedHeight: MediaQuery.of(context).size.height * 0.21,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) {
                        return const LoginScreen();
                      }), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 8.0),
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
                      "Account Verification",
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/logo.png",
                          width: MediaQuery.of(context).size.width * 0.4,
                          filterQuality: FilterQuality.high,
                        ),
                        Text(
                          "Please enter the OTP received on your email ID ${widget.userEmail}. Please verify your details sent on your email.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Pinput(
                              controller: _otpController,
                              validator: _otpValidator,
                              length: 6,
                              showCursor: true,
                              defaultPinTheme: PinTheme(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                                textStyle: GoogleFonts.sourceCodePro(
                                  textStyle: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  otpCode = value;
                                });
                              },
                              onCompleted: (value) {
                                setState(() {
                                  otpCode = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            MaterialButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _verifyOtpAndLogin().then((value) {
                                    if (value == "-1") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const LoginScreen();
                                      }), (route) => false);
                                    } else if (value == "1") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const HsHeadScreen();
                                      }), (route) => false);
                                    } else if (value == "2") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const DoctorScreen();
                                      }), (route) => false);
                                    } else if (value == "3") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const FrontLineWorkerScreen();
                                      }), (route) => false);
                                    }
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              minWidth: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 10.0),
                              color: Theme.of(context).colorScheme.secondary,
                              child: Text(
                                "Verify",
                                style: GoogleFonts.raleway(
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
