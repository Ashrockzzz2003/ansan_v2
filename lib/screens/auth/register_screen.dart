import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/auth/otp_register.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  String? gender;
  final TextEditingController dobController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  final aadharMaskFormatter = MaskTextInputFormatter(
    mask: "1111 1111 1111",
    filter: {
      "1": RegExp(r"[0-9]"),
    },
  );

  final pincodeMaskFormatter = MaskTextInputFormatter(
    mask: "111-111",
    filter: {
      "1": RegExp(r"[0-9]"),
    },
  );

  final dobMaskFormatter = MaskTextInputFormatter(
    mask: "1111-11-11",
    filter: {
      "1": RegExp(r"[0-9]"),
    },
  );

  final phoneNumberMaskFormatter = MaskTextInputFormatter(
    mask: "1111111111",
    filter: {
      "1": RegExp(r"[0-9]"),
    },
  );

  String? _phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number";
    } else if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email address";
    } else if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _aadharValidator(String? value) {
    if (aadharMaskFormatter.getUnmaskedText().isEmpty) {
      return "Please enter your Aadhar number";
    } else if (!RegExp(r"^[0-9]{12}$")
        .hasMatch(aadharMaskFormatter.getUnmaskedText())) {
      return "Please enter a valid Aadhar number";
    }
    return null;
  }

  String? _pincodeValidator(String? value) {
    if (pincodeMaskFormatter.getUnmaskedText().isEmpty) {
      return "Please enter your pincode";
    } else if (!RegExp(r"^[0-9]{6}$")
        .hasMatch(pincodeMaskFormatter.getUnmaskedText())) {
      return "Please enter a valid pincode";
    }
    return null;
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  Future<String> _moveToRegisterOtp() async {
    final dio = Dio();

    try {
      final response = await dio.post(Constants().registerUrl,
          options: Options(
            headers: {
              "Content-Type": "application/json",
            },
            validateStatus: (status) {
              return status! < 500;
            },
          ),
          data: {
            "phoneNumber": phoneNumberMaskFormatter.getUnmaskedText(),
            "userName": userNameController.text.trim(),
            "gender": gender,
            "dob": dobController.text.trim(),
            "userEmail": userEmailController.text.trim(),
            "aadhar": aadharMaskFormatter.getUnmaskedText(),
            "address": addressController.text.trim(),
            "district": districtController.text.trim(),
            "state": stateController.text.trim(),
            "country": countryController.text.trim(),
            "pincode": pincodeMaskFormatter.getUnmaskedText(),
          });

      if (response.statusCode == 200) {
        showToast("OTP sent successfully.");
        return response.data["SECRET_TOKEN"];
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
        return "0";
      } else {
        showToast("Something went wrong. Please try again later.");
        return "0";
      }
    } catch (e) {
      print(e);
      return "0";
    }
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
                        return const WelcomeScreen();
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
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Register",
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
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.sourceCodePro(),
                                controller: phoneNumberController,
                                validator: _phoneNumberValidator,
                                inputFormatters: [
                                  phoneNumberMaskFormatter,
                                ],
                                decoration: InputDecoration(
                                  labelText: "Mobile Number",
                                  prefixIcon: const Icon(Icons.phone_rounded),
                                  hintText: "Enter mobile number",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.raleway(),
                                controller: userNameController,
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  prefixIcon: const Icon(Icons.person_rounded),
                                  hintText: "Enter your full name",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.datetime,
                                style: GoogleFonts.sourceCodePro(),
                                controller: dobController,
                                validator: _fieldValidator,
                                inputFormatters: [
                                  dobMaskFormatter,
                                ],
                                decoration: InputDecoration(
                                  labelText: "DOB",
                                  prefixIcon: const Icon(Icons.date_range),
                                  hintText: "Select your DOB.",
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
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime(2100));

                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    setState(() {
                                      dobController.text = formattedDate;
                                    });
                                  } else {}
                                },
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              DropdownButtonFormField(
                                items: <DropdownMenuItem<String>>[
                                  DropdownMenuItem(
                                    value: "M",
                                    child: Text(
                                      "Male",
                                      style: GoogleFonts.raleway(),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "F",
                                    child: Text(
                                      "Female",
                                      style: GoogleFonts.raleway(),
                                    ),
                                  ),
                                ],
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  labelText: "Gender",
                                  prefixIcon:
                                      const Icon(Icons.person_pin_outlined),
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
                                onChanged: (String? value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 24,
                              ),
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
                              const SizedBox(height: 24),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.sourceCodePro(),
                                controller: aadharController,
                                validator: _aadharValidator,
                                inputFormatters: [
                                  aadharMaskFormatter,
                                ],
                                decoration: InputDecoration(
                                  labelText: "Aadhar Number",
                                  prefixIcon:
                                      const Icon(Icons.verified_rounded),
                                  hintText: "Please enter your Aadhar",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                maxLines: null,
                                style: GoogleFonts.sourceCodePro(),
                                controller: addressController,
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  hintText: "Enter your address...",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.raleway(),
                                controller: districtController,
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  labelText: "District",
                                  prefixIcon:
                                      const Icon(Icons.location_on_rounded),
                                  hintText: "Enter your district",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.raleway(),
                                controller: stateController,
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  labelText: "State",
                                  prefixIcon:
                                      const Icon(Icons.local_library_rounded),
                                  hintText: "Enter your state",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.raleway(),
                                controller: countryController,
                                validator: _fieldValidator,
                                decoration: InputDecoration(
                                  labelText: "Country",
                                  prefixIcon:
                                      const Icon(Icons.flag_circle_rounded),
                                  hintText: "Enter your Country",
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
                                height: 24,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.sourceCodePro(),
                                controller: pincodeController,
                                validator: _pincodeValidator,
                                inputFormatters: [
                                  pincodeMaskFormatter,
                                ],
                                decoration: InputDecoration(
                                  labelText: "Pin Code",
                                  prefixIcon: const Icon(Icons.qr_code_rounded),
                                  hintText: "Enter your area-pin code",
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
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()));
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  overlayColor: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.2)),
                                ),
                                child: Text(
                                  "Already have an account? Login",
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
                                    _moveToRegisterOtp().then((value) {
                                      if (value == "0") {
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                RegisterOtpScreen(
                                                    otpToken: value,
                                                    data: {
                                                  "phoneNumber":
                                                      phoneNumberMaskFormatter
                                                          .getUnmaskedText(),
                                                  "userName": userNameController
                                                      .text
                                                      .trim(),
                                                  "gender": gender,
                                                  "dob":
                                                      dobController.text.trim(),
                                                  "userEmail":
                                                      userEmailController.text
                                                          .trim(),
                                                  "aadhar": aadharMaskFormatter
                                                      .getUnmaskedText(),
                                                  "address": addressController
                                                      .text
                                                      .trim(),
                                                  "district": districtController
                                                      .text
                                                      .trim(),
                                                  "state": stateController.text
                                                      .trim(),
                                                  "country": countryController
                                                      .text
                                                      .trim(),
                                                  "pincode":
                                                      phoneNumberMaskFormatter
                                                          .getUnmaskedText(),
                                                }),
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
                                  "Register",
                                  style: GoogleFonts.raleway(
                                    textStyle:
                                        Theme.of(context).textTheme.titleLarge,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 72,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
