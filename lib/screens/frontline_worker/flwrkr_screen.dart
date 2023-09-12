import 'dart:convert';

import 'package:eperimetry_vtwo/screens/frontline_worker/flwrkr_profile_screen.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrontLineWorkerScreen extends StatefulWidget {
  const FrontLineWorkerScreen({super.key});

  @override
  State<FrontLineWorkerScreen> createState() => _FrontLineWorkerScreenState();
}

class _FrontLineWorkerScreenState extends State<FrontLineWorkerScreen> {
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
        showToast("Please login again.");
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
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) =>
                              const FrontLineWorkerProfileScreen()));
                    },
                    icon: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        SharedPreferences.getInstance().then((sp) {
                          final userEmail = sp.getString("userEmail");
                          sp.clear();
                          sp.setString("userEmail", userEmail!);
                        });
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(builder: (context) {
                          return const WelcomeScreen();
                        }), (route) => false);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/logo.png",
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            "${hsHead!["managerName"]}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              textStyle: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Chip(
                            padding: const EdgeInsets.all(2.0),
                            label: Text(
                              "Frontline Worker",
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
