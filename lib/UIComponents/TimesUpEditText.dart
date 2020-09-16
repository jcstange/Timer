import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimesUpEditText extends StatefulWidget {
  final String initialValue;
  final int maxLength;
  final TextInputType inputType;

  TimesUpEditText({Key key, this.initialValue, this.maxLength, this.inputType})
      : super(key: key);

  _TimesUpEditTextState state;

  @override
  _TimesUpEditTextState createState() => state = _TimesUpEditTextState();
}

class _TimesUpEditTextState extends State<TimesUpEditText> {
  String initialValue;
  var _isEditingText = true;
  var _editingController;

  @override
  void initState() {
    initialValue = widget.initialValue;
    _editingController = TextEditingController(text: initialValue);
    super.initState();
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
              initialValue = "";
              _isEditingText = true;
            }
          });
        },
        onChanged: (newValue) {
          setState(() {
            print(newValue);
            initialValue = newValue;
          });
        },
        onSubmitted: (newValue) {
          setState(() {
            initialValue = newValue;
            _isEditingText = false;
          });
        },
        autofocus: true,
        controller: _editingController)
        : InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Text(initialValue,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
            )));
  }
}
