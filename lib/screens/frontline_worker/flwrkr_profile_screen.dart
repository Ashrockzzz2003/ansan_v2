import 'dart:convert';

import 'package:eperimetry_vtwo/screens/frontline_worker/flwrkr_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrontLineWorkerProfileScreen extends StatefulWidget {
  const FrontLineWorkerProfileScreen({super.key});

  @override
  State<FrontLineWorkerProfileScreen> createState() =>
      _FrontLineWorkerProfileScreenState();
}

class _FrontLineWorkerProfileScreenState
    extends State<FrontLineWorkerProfileScreen> {
  bool isLoading = true;

  Map<String, dynamic>? flWrkr;

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("currentUser")) {
        final currentUser = sp.getString("currentUser");
        setState(() {
          flWrkr = jsonDecode(currentUser!);
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
    return isLoading || flWrkr == null
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
                        return const FrontLineWorkerScreen();
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
                      "Frontline Worker Profile",
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
                              text: flWrkr!["managerId"] ?? ""),
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
                              text: flWrkr!["managerName"] ?? ""),
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
                              text: flWrkr!["userEmail"] ?? ""),
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
                              text: flWrkr!["phoneNumber"] ?? ""),
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
                        if (flWrkr!["officeName"].toString().isNotEmpty && flWrkr!["officeName"].toString() != "null") ...[
                          TextField(
                            controller: TextEditingController(
                                text: flWrkr!["officeName"] ?? ""),
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
