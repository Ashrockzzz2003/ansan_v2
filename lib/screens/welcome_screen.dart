import 'package:eperimetry_vtwo/screens/auth/login_screen.dart';
import 'package:eperimetry_vtwo/screens/auth/register_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          //AppBar
          SliverAppBar.large(
            floating: false,
            pinned: true,
            snap: false,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "ANSAN",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),

          //Body
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      "Welcome to ANSAN.\nLogin/Register to continue.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        "Register",
                        style: GoogleFonts.raleway(
                          textStyle: Theme.of(context).textTheme.titleLarge,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Container(
                            margin:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(
                              color: Theme.of(context).colorScheme.secondary,
                              height: 36,
                            ),
                          )),
                          Text(
                            "OR",
                            style: GoogleFonts.raleway(
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                height: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        "Login",
                        style: GoogleFonts.raleway(
                          textStyle: Theme.of(context).textTheme.titleLarge,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
