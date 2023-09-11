import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Question {
  Question({
    required this.questionFull,
    this.questionLabel,
    this.placeHolder,
    this.icon,
    required this.isRequired,
    required this.isMultipleChoice,
    required this.isMultiSelect,
    required this.isText,
    required this.isNumber,
    this.options,
    this.values,
  });

  String questionFull;
  String? questionLabel;
  String? placeHolder;
  Icon? icon;
  bool isRequired;
  bool isMultipleChoice;
  bool isMultiSelect;
  bool isText;
  bool isNumber;
  List<String>? options;
  List<String>? values;

  Widget renderQuestion(BuildContext context, TextEditingController controller,
      String? Function(String?)? validator) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            questionFull,
            style: GoogleFonts.raleway(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(),
        if (isText) ...[
          TextFormField(
            keyboardType: TextInputType.name,
            style: GoogleFonts.raleway(),
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              labelText: questionLabel,
              prefixIcon: icon,
              hintText: placeHolder,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              labelStyle: GoogleFonts.raleway(),
            ),
          ),
        ] else if (isNumber) ...[
          TextFormField(
            keyboardType: TextInputType.number,
            style: GoogleFonts.sourceCodePro(),
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              labelText: questionLabel,
              prefixIcon: icon,
              hintText: placeHolder,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              labelStyle: GoogleFonts.raleway(),
            ),
          ),
        ] else if (isMultipleChoice) ...[
          for (int i = 0; i < options!.length; i++)
            RadioListTile(
              title: Text(
                options![i],
                style: GoogleFonts.raleway(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              value: values![i],
              groupValue: controller.text,
              onChanged: (String? value) {
                controller.text = value!;
              },
            ),
        ] else if (isMultiSelect) ...[
          for (int i = 0; i < options!.length; i++)
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                options![i],
                style: GoogleFonts.raleway(),
              ),
              value: controller.text.contains(values![i]),
              onChanged: (bool? value) {
                if (value!) {
                  controller.text += "${values![i]},";
                } else {
                  controller.text =
                      controller.text.replaceAll("${values![i]},", "");
                }
              },
            ),
        ] else ...[
          const SizedBox(),
        ],
      ],
    );
  }
}
