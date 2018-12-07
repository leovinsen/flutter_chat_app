import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final double size;
  final String url;
  final int index;

  const CircularImage({this.size, this.url, this.index})
      : assert(size != null),
        assert(url != null);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: url + index.toString(),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Hero(
                tag: url,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    child: CachedNetworkImage(imageUrl: url,fit: BoxFit.contain,),
                  ),
                ),
              ),
            )
          ));
        },
        child: Container(
          width: size,
          height: size,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: CachedNetworkImageProvider(url)
            )
          ),
        ),
      ),
    );
  }
}
