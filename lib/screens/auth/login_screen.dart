import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/auth/otp_login.dart';
import 'package:eperimetry_vtwo/screens/auth/register_screen.dart';
import 'package:eperimetry_vtwo/screens/auth/verify_account.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController userEmailController = TextEditingController();

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email address";
    } else if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  late final String verifyToken;

  Future<String> _moveToOtp() async {
    final dio = Dio();

    try {
      final response = await dio.post(Constants().loginUrl,
          options: Options(headers: {
            "Content-Type": "application/json",
          }, validateStatus: (status) => status! < 500),
          data: {
            "userEmail": userEmailController.text.trim(),
          });
      if (response.statusCode == 200) {
        final otpToken = response.data["SECRET_TOKEN"];
        showToast("OTP sent to your email address");

        if (response.data["message"] == "Verify Manager") {
          setState(() {
            verifyToken = response.data["SECRET_TOKEN"];
          });
          return "1";
        }

        return otpToken;
      } else {
        if (response.data["message"] != null) {
          showToast(response.data["message"]);
        } else {
          showToast("Something went wrong. Please try again later");
        }
        return "0";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showToast("Something went wrong. Please try again later");
      return "0";
    }
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("userEmail")) {
        final userEmail = sp.getString("userEmail");
        setState(() {
          userEmailController.text = userEmail!;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen(
            message: "Sending OTP ...",
          )
        : Scaffold(
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              shrinkWrap: true,
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
                        return const WelcomeScreen();
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
                      "Login",
                      textAlign: TextAlign.center,
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
                          height: 72,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.sourceCodePro(),
                              controller: userEmailController,
                              validator: _emailValidator,
                              decoration: InputDecoration(
                                labelText: "Email ID",
                                prefixIcon: const Icon(Icons.email_rounded),
                                hintText: "Please enter your Email-ID",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                overlayColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.2)),
                              ),
                              child: Text(
                                "Don't have an account? Create Account",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            MaterialButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _moveToOtp().then((value) {
                                    if (value == "0") {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else if (value == "1") {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              VerifyAccountScreen(
                                                  secretToken:
                                                      verifyToken.toString(),
                                                  userEmail: userEmailController
                                                      .text
                                                      .trim()),
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => LoginOtpScreen(
                                              otpToken: value,
                                              userEmail: userEmailController
                                                  .text
                                                  .trim()),
                                        ),
                                      );
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
                                "Login",
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
