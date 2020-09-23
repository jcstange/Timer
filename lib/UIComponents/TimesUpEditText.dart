import 'package:Timer/TimesUpColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimesUpEditText extends StatefulWidget {
  final TextEditingController textEditingController;
  final int maxLength;
  final TextInputType inputType;

  TimesUpEditText({
    Key key,
    this.textEditingController,
    this.maxLength,
    this.inputType,
  })
      : super(key: key);

  _TimesUpEditTextState state;

  @override
  _TimesUpEditTextState createState() => state = _TimesUpEditTextState();
}

class _TimesUpEditTextState extends State<TimesUpEditText> {
  var _isEditingText = true;
  var initialValue;

  @override
  void initState() {
    super.initState();
    initialValue = widget.textEditingController.text;
  }

  @override
  Widget build(BuildContext context) {
    return _isEditingText
        ? TextField(
        maxLines: 1,
        maxLength: widget.maxLength ?? 25,
        keyboardType: widget.inputType ?? TextInputType.text,
        onTap: () {
          setState(() {
            if (_isEditingText == false) {
              widget.textEditingController.text = "";
              _isEditingText = true;
            }
          });
        },
        onChanged: (newValue) {
          setState(() {
            print(newValue);
            widget.textEditingController.text = newValue;
          });
        },
        onSubmitted: (newValue) {
          setState(() {
            widget.textEditingController.text = newValue;
            _isEditingText = false;
          });
        },
        autofocus: true,
        controller: widget.textEditingController)
        : InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Text(widget.textEditingController.text,
            style: TextStyle(
              color: TimesUpColors().royalBlue,
              fontSize: 18.0,
            )));
  }
}
