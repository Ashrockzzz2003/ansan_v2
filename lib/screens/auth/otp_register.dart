import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/model/user.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/auth/register_screen.dart';
import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen(
      {super.key, required this.otpToken, required this.data});

  final String otpToken;
  final Map<String, dynamic> data;

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  String? otpCode;

  String? _otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP!';
    } else if (value.length != 6) {
      return 'Please enter a valid 6 digit OTP!';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid OTP';
    }
    return null;
  }

  Future<String> _verifyOtpAndLogin() async {
    final dio = Dio();

    try {
      final response = await dio.post(
        Constants().registerVerifyUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.otpToken}",
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

          if (response.data["role"] == 'USER') {
            final User user = User(
              patientId: userData["patientId"].toString(),
              phoneNumber: userData["phoneNumber"].toString(),
              userName: userData["userName"].toString(),
              gender: userData["gender"].toString(),
              dob: userData["dob"].toString(),
              age: userData["age"].toString(),
              userEmail: userData["userEmail"].toString(),
              aadharNumber: userData["aadhar"].toString(),
              address: userData["address"].toString(),
              district: userData["district"].toString(),
              state: userData["state"].toString(),
              country: userData["country"].toString(),
              pincode: userData["pincode"].toString(),
              surveyLevel: userData["surveyLevel"].toString(),
              role: response.data["role"].toString(),
            );

            sp.setString("currentUser", user.toJson());
          }
        });

        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
        return "0";
      } else if (response.statusCode == 401) {
        showToast("Session Expired. Try again!");
        return "0";
      } else if (response.statusCode == 404) {
        print(response);
        showToast("Invalid OTP. Please try again!");
      } else {
        showToast("Something went wrong. Please try again later.");
        return "0";
      }
    } catch (e) {
      print(e);
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
                        return const RegisterScreen();
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
                      "OTP Verification",
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
                        const SizedBox(
                          height: 48,
                        ),
                        Text(
                          "Please enter the OTP received on your emailID ${widget.data["userEmail"]}.",
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
                                    if (value == "1") {
                                      showToast("OTP verified successfully.");
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const UserScreen();
                                      }), (route) => false);
                                    } else if (value == "-1") {
                                      showToast(
                                          "OTP expired. Please try again.");
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const LoginScreen();
                                      }), (route) => false);
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
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
