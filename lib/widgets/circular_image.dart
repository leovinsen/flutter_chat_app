import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final double size;
  final String url;
  const CircularImage({this.size, this.url}) : assert(size != null), assert(url != null);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(url)
            )
        )
    );
  }
}
