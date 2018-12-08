import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularProfileImage extends StatelessWidget {
  final double size;
  final String url;
  ///publicId is used to ensure every hero has a unique tag
  final String publicId;

  const CircularProfileImage({this.size, this.url, this.publicId})
      : assert(size != null),
        assert(publicId != null);

  @override
  Widget build(BuildContext context) {
    final tag = url + publicId;

    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Hero(
                tag: tag,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    child: CachedNetworkImage(imageUrl: url,fit: BoxFit.contain, width: double.infinity, height: double.infinity,),
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
