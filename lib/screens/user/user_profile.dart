import 'dart:convert';

import 'package:eperimetry_vtwo/screens/user/user_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = true;

  Map<String, dynamic>? user;

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("currentUser")) {
        final currentUser = sp.getString("currentUser");
        setState(() {
          user = jsonDecode(currentUser!);
        });
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) {
          return const WelcomeScreen();
        }), (route) => false);
      }
    });
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || user == null
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
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                    title: Text(
                      "Profile",
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
                        TextField(
                          controller: TextEditingController(
                              text: user!["patientId"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.qr_code_rounded),
                            labelText: "PatientID",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["userName"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_rounded),
                            labelText: "Full Name",
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["phoneNumber"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded),
                            labelText: "Mobile Number",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["gender"] == "M"
                                  ? "Male"
                                  : "Female" ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: user!["gender"] == "M"
                                ? const Icon(Icons.male_rounded)
                                : const Icon(Icons.female_rounded),
                            labelText: "Gender",
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text:
                                  user!["dob"].toString().split("T")[0] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.date_range_rounded),
                            labelText: "Date of Birth",
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
                          height: 16,
                        ),
                        TextField(
                          controller:
                              TextEditingController(text: user!["age"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.access_time_filled_rounded),
                            labelText: "Age",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["userEmail"] ?? ""),
                          maxLines: null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_rounded),
                            labelText: "Email ID",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["aadhar"] ?? ""),
                          inputFormatters: [
                            MaskTextInputFormatter(
                              mask: "1111 1111 1111",
                              filter: {
                                "1": RegExp(r"[0-9]"),
                              },
                            ),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.badge_rounded),
                            labelText: "Aadhar",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["address"] ?? ""),
                          maxLines: null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.home_rounded),
                            labelText: "Address",
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
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["district"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on_rounded),
                            labelText: "District",
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["state"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.local_library_rounded),
                            labelText: "State",
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["country"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.flag_circle_rounded),
                            labelText: "Country",
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: user!["pincode"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.qr_code_2_rounded),
                            labelText: "Pincode",
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
                          height: 48,
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
