import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Question extends StatefulWidget {
  const Question({
    super.key,
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
    required this.controller,
    this.validator,
  });

  final String questionFull;
  final String? questionLabel;
  final String? placeHolder;
  final Icon? icon;
  final bool isRequired;
  final bool isMultipleChoice;
  final bool isMultiSelect;
  final bool isText;
  final bool isNumber;
  final List<String>? options;
  final List<String>? values;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            widget.questionFull,
            style: GoogleFonts.raleway(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 16,
        ),
        if (widget.isText) ...[
          TextFormField(
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: null,
            style: GoogleFonts.raleway(),
            controller: widget.controller,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.questionLabel,
              prefixIcon: widget.icon,
              hintText: widget.placeHolder,
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
        ] else if (widget.isNumber) ...[
          TextFormField(
            keyboardType: TextInputType.number,
            style: GoogleFonts.sourceCodePro(),
            controller: widget.controller,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.questionLabel,
              prefixIcon: widget.icon,
              hintText: widget.placeHolder,
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
        ] else if (widget.isMultipleChoice) ...[
          for (int i = 0; i < widget.options!.length; i++)
            RadioListTile(
              title: Text(
                widget.options![i],
                style: GoogleFonts.raleway(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              value: widget.values![i],
              groupValue: widget.controller.text,
              onChanged: (String? value) {
                setState(() {
                  widget.controller.text = value!;
                });
              },
            ),
        ] else if (widget.isMultiSelect) ...[
          for (int i = 0; i < widget.options!.length; i++)
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                widget.options![i],
                style: GoogleFonts.raleway(),
              ),
              value: widget.controller.text.contains(widget.values![i]),
              onChanged: (bool? value) {
                if (value!) {
                  setState(() {
                    widget.controller.text += "${widget.values![i]},";
                  });
                } else {
                  setState(() {
                    widget.controller.text = widget.controller.text
                        .replaceAll("${widget.values![i]},", "");
                  });
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
