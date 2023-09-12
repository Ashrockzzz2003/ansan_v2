import 'dart:convert';

import 'package:eperimetry_vtwo/screens/hospital_head/hshead_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HsHeadProfileScreen extends StatefulWidget {
  const HsHeadProfileScreen({super.key});

  @override
  State<HsHeadProfileScreen> createState() => _HsHeadProfileScreenState();
}

class _HsHeadProfileScreenState extends State<HsHeadProfileScreen> {
  bool isLoading = true;

  Map<String, dynamic>? hsHead;

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("currentUser")) {
        final currentUser = sp.getString("currentUser");
        setState(() {
          hsHead = jsonDecode(currentUser!);
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
    return isLoading || hsHead == null
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
                              text: hsHead!["managerId"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.qr_code_rounded),
                            labelText: "Manager ID",
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
                              text: hsHead!["managerName"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_rounded),
                            labelText: "Manager Name",
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
                              text: hsHead!["userEmail"] ?? ""),
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
                          style: GoogleFonts.raleway(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: TextEditingController(
                              text: hsHead!["phoneNumber"] ?? ""),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded),
                            labelText: "Phone Number",
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
                        if (hsHead!["officeName"].toString().isNotEmpty) ...[
                          TextField(
                            controller: TextEditingController(
                                text: hsHead!["officeName"] ?? ""),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.home_rounded),
                              labelText: "Office Name",
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
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
