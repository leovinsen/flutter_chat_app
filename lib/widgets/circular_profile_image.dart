import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularNetworkProfileImage extends StatelessWidget {
  final double size;
  final String url;

  ///publicId is used to ensure every hero has a unique tag
  final String publicId;

  const CircularNetworkProfileImage({this.size, this.url, this.publicId})
      : assert(size != null),
        assert(publicId != null);

  @override
  Widget build(BuildContext context) {
    final tag = url + publicId;
    final Widget bigImage = url.isEmpty
        ? Image.asset(
            'assets/default_profile_picture_744px.jpg',
            fit: BoxFit.contain,
          )
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );

    final ImageProvider smallImage = url.isEmpty
        ? AssetImage('assets/default_profile_picture_128px.jpg')
        : CachedNetworkImageProvider(url);


    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: () => url.isEmpty ? null : _enlargeImage(context, tag, bigImage),
        child: Container(
          width: size,
          height: size,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(fit: BoxFit.fill, image: smallImage),
          ),
          //child: CachedNetworkImage(imageUrl: url,),
        ),
      ),
    );
  }

  void _enlargeImage(BuildContext context, String heroTag, Widget image){
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: Hero(
            tag: heroTag,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                child: image,
              ),
            ),
          ),
        )));
  }

}