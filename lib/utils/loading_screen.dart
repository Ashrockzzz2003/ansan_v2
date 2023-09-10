import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 24,
            ),
            Text(
              message ?? "Loading...",
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    fontSize: 16,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
