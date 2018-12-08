import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function function;

  CustomButton(this.text, this.function);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.black),),
      onPressed: function,
    );
  }
}
