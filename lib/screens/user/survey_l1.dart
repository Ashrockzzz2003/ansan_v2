import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:eperimetry_vtwo/utils/loading_screen.dart';
import 'package:eperimetry_vtwo/utils/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSurveyLevelOneScreen extends StatefulWidget {
  const UserSurveyLevelOneScreen({super.key});

  @override
  State<UserSurveyLevelOneScreen> createState() =>
      _UserSurveyLevelOneScreenState();
}

class _UserSurveyLevelOneScreenState extends State<UserSurveyLevelOneScreen> {
  String? secretToken = "";
  bool isLoading = false;

  int activeStep = 0;
  int maxIndex = 12;

  late List<TextEditingController> controllers;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("SECRET_TOKEN")) {
        secretToken = sp.getString("SECRET_TOKEN");
      } else {
        showToast("Session expired. Please login again.");
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isLoading ? const LoadingScreen() : Scaffold(
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
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              title: Text(
                "Questionnaire Level 1",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),


        ],
      );
    );
  }
}
