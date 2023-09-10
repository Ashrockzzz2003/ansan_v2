import 'package:dio/dio.dart';
import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/constants.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMemberScreen extends StatefulWidget {
  const NewMemberScreen({super.key});

  @override
  State<NewMemberScreen> createState() => _NewMemberScreenState();
}

class _NewMemberScreenState extends State<NewMemberScreen> {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  /*
  {
    ”userName” : “Member1”,
    ”gender” : “M”,
    ”dob” : "2002-12-27",
    ”aadhar” : “321321321321”
  }
  */

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  String? gender;

  final aadharMaskFormatter = MaskTextInputFormatter(
    mask: "1111 1111 1111",
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

  String? _aadharValidator(String? value) {
    if (aadharMaskFormatter.getUnmaskedText().isEmpty) {
      return "Please enter your Aadhar number";
    } else if (!RegExp(r"^[0-9]{12}$")
        .hasMatch(aadharMaskFormatter.getUnmaskedText())) {
      return "Please enter a valid Aadhar number";
    }
    return null;
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  Future<String> _addMember() async {
    final dio = Dio();

    try {
      final sp = await SharedPreferences.getInstance();
      final secretToken = sp.getString("SECRET_TOKEN");

      if (secretToken == null) {
        showToast("Session Expired! Please login again.");
        return "-1";
      }


      final response = await dio.post(Constants().addNewFamilyMemberUrl,
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
            "userName": _userNameController.text.trim(),
            "gender": gender,
            "dob": _dobController.text.trim(),
            "aadhar": aadharMaskFormatter.getUnmaskedText().trim()
          });


      if (response.statusCode == 200) {
        showToast("Family member added successfully!");
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
                      "New Family Member",
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
                              style: GoogleFonts.raleway(),
                              controller: _userNameController,
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
                              controller: _dobController,
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
                                    _dobController.text = formattedDate;
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
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.sourceCodePro(),
                              controller: _aadharController,
                              validator: _aadharValidator,
                              inputFormatters: [
                                aadharMaskFormatter,
                              ],
                              decoration: InputDecoration(
                                labelText: "Aadhar Number",
                                prefixIcon: const Icon(Icons.verified_rounded),
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
                            MaterialButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _addMember().then((value) {
                                    if (value == "-1") {
                                      Navigator.pushAndRemoveUntil(context,
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const WelcomeScreen();
                                      }), (route) => false);
                                    } else if (value == "1") {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const UserScreen();
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
                                "Add Family Member",
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
