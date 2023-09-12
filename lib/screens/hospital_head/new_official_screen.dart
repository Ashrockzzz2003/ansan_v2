import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/hospital_head/hshead_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HsHeadNewOfficialScreen extends StatefulWidget {
  const HsHeadNewOfficialScreen({super.key});

  @override
  State<HsHeadNewOfficialScreen> createState() => _HsHeadNewOfficialScreenState();
}

class _HsHeadNewOfficialScreenState extends State<HsHeadNewOfficialScreen> {
  /*
  {
    "newManagerId" : "DOCT",
    "managerPhoneNumber" : "1111111111",
    "managerName" : "Doc under Admin",
    "userEmail" : "motoseby@afia.pro",
    "newRole" : "DOC",
    ”officeName” : “”
  }
  */

  final TextEditingController _newManagerIdController = TextEditingController();
  final TextEditingController _managerPhoneNumberController =
  TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _officeNameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _mobileNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a mobile number";
    }
    if (value.length != 10) {
      return "Mobile number must be 10 digits";
    }
    return null;
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
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

  bool isLoading = false;

  Future<String> _addMember() async {
    final dio = Dio();

    try {
      final sp = await SharedPreferences.getInstance();
      final secretToken = sp.getString("SECRET_TOKEN");

      if (secretToken == null) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }

      final response = await dio.post(
        Constants().registerOfficialUrl,
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
          "newManagerId": _newManagerIdController.text.trim().toString(),
          "managerPhoneNumber":
          _managerPhoneNumberController.text.trim().toString(),
          "managerName": _managerNameController.text.trim().toString(),
          "userEmail": _userEmailController.text.trim().toString(),
          "newRole": "DOC",
          "officeName": _officeNameController.text.trim().toString().isEmpty
              ? "NIL"
              : _officeNameController.text.trim().toString(),
        },
      );

      if (response.statusCode == 200) {
        showToast("Doctor added successfully!");
        return "1";
      } else if (response.data["message"] != null) {
        showToast(response.data["message"]);
      } else if (response.statusCode == 401) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }
    } catch (e) {
      print(e);
      showToast("Something went wrong. Please try again later.");
      return "0";
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
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (context) {
                      return const HsHeadScreen();
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
                "Register New Doctor",
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
                    height: 24,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        style: GoogleFonts.sourceCodePro(),
                        controller: _newManagerIdController,
                        validator: _fieldValidator,
                        decoration: InputDecoration(
                          labelText: "Manager ID",
                          prefixIcon: const Icon(Icons.verified_rounded),
                          hintText: "Enter a new manager ID",
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
                        controller: _managerNameController,
                        validator: _fieldValidator,
                        decoration: InputDecoration(
                          labelText: "Manager Name",
                          prefixIcon: const Icon(Icons.person_rounded),
                          hintText: "Enter manager name",
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
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.sourceCodePro(),
                        controller: _userEmailController,
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
                        height: 24,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.sourceCodePro(),
                        controller: _managerPhoneNumberController,
                        validator: _mobileNumberValidator,
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
                        controller: _officeNameController,
                        validator: null,
                        decoration: InputDecoration(
                          labelText: "Office Name",
                          prefixIcon:
                          const Icon(Icons.cell_tower_rounded),
                          hintText: "Enter office name",
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
                      TextField(
                        controller: TextEditingController(
                            text: "Doctor"),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.qr_code_rounded),
                          labelText: "Role",
                          labelStyle: GoogleFonts.raleway(
                            textStyle:
                            Theme.of(context).textTheme.titleMedium,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                          ),
                        ),
                        readOnly: true,
                        style: GoogleFonts.sourceCodePro(
                          textStyle: Theme.of(context).textTheme.titleMedium,
                        ),
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
                            _addMember().then((value) {
                              if (value == "1") {
                                Navigator.of(context).pushAndRemoveUntil(
                                    CupertinoPageRoute(
                                        builder: (context) {
                                          return const HsHeadScreen();
                                        }), (route) => false);
                              } else if (value == "0") {
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
                          "Register Doctor",
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
