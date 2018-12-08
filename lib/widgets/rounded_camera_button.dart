import 'package:flutter/material.dart';

class RoundedCameraButton extends StatelessWidget {
  final Function function;
  const RoundedCameraButton(this.function);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(

        width: 55.0,
        height: 55.0,
        decoration: BoxDecoration(
          boxShadow:  <BoxShadow>[
            BoxShadow(
              color: Colors.black.withAlpha(100),
              offset: Offset(0.0, 0.0),
              blurRadius: 4.0,
             // spreadRadius: 3.0
            ),
          ],
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.photo_camera,
          color: Colors.white,
          size: 25.0,
        ),
      ),
      onTap: function,
    );
  }
}
