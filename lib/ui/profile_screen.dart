import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/ui/chat_editor.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';
import 'package:flutter_chat_app/widgets/rounded_camera_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileScreen extends StatefulWidget {
  final AppData appData;
  ProfileScreen({this.appData});

  @override
  ProfileScreenState createState() {
    return new ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {

  //bool _uploading = false;

  Future _pickImage(ImageSource imgSource) async {
    AppData data = AppData.of(context);
    if(imgSource == null) return;

    //createDialog(context);
    String publicId = data.publicId;
    File imageFile = await ImagePicker.pickImage(source: imgSource, maxWidth: 400, maxHeight: 400);
    StorageReference ref =
    FirebaseStorage.instance.ref().child(publicId).child("profile_picture.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);

    FirebaseDatabase db = FirebaseDatabase.instance;
    String s = await (await uploadTask.onComplete).ref.getDownloadURL();
    db.reference().child('usersInfo/$publicId').update({'thumbUrl' : s });
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Upload successful'), duration: Duration(seconds: 2),));
    debugPrint('Upload successful: $s');
  }

  Future<ImageSource> chooseImageSource() async {
    return await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Choose picture from'),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: () =>
                        Navigator.of(context).pop(ImageSource.camera),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () =>
                        Navigator.of(context).pop(ImageSource.gallery),
                  )
                ]
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppData>(
      builder: (_, child, model) {
        return Container(
            color: Colors.grey.shade100,
            child: ListView(
              shrinkWrap: false,
              children: <Widget>[
                profilePicture(model),
                publicIdContainer(context, model),
                displayNameContainer(context, model),
              ],
            )
        );
      }
    );
  }


  Widget profilePicture(AppData data){
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Stack(
          children: <Widget>[
            CircularNetworkProfileImage(
              size: 300.0,
              url: null,
              publicId: data.publicId,
            ),
            Positioned(
              right: 20.0,
              bottom: 20.0,
              child: RoundedCameraButton(() async =>
                  _pickImage(await chooseImageSource())),
            )
        ]
      ),
    );
  }

  Container publicIdContainer(BuildContext context, AppData data){
    return Container(
        alignment: Alignment.center,
        child: ListTile(
          title: Text('Public ID'),
          subtitle: Text(data.publicId, style: blueSubtitle(context)),
        ),
        decoration: whiteBoxDecoration()
    );
  }

  Container displayNameContainer(BuildContext context, AppData data){
    return Container(
      alignment: Alignment.center,
        child: ListTile(
          title: Text('Display Name'),
          subtitle: Text(data.displayName, style: blueSubtitle(context),),
          trailing: IconButton(icon: Icon(Icons.edit), color: Theme.of(context).primaryColor, onPressed: () =>  _openNameEditor(data)),
        ),
      decoration: whiteBoxDecoration(),
    );
  }

  Decoration whiteBoxDecoration(){
    return BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade400, blurRadius: 0.1)
        ]
    );
  }

  TextStyle blueSubtitle(BuildContext context){
    return TextStyle(
      fontSize: 12.0,
      color: Theme.of(context).primaryColorDark
    );
  }

  void _openNameEditor(AppData data) async {
    String originalName = data.displayName;

    final String results = await
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatEditor(originalName))
    )..trim();

    if(results != null && results.isNotEmpty && results != originalName){
      FirebaseDatabase db = FirebaseDatabase.instance;
      db.reference().child('usersInfo/${data.publicId}').update({'displayName' : results });
    }
  }

//  void createDialog(BuildContext context) {
//      showDialog(
//        barrierDismissible: false,
//          context: context,
//          builder: (_){
//            return AlertDialog(
//              content: Row(children: <Widget>[
//                Text('Uploading...'),
//                CircularProgressIndicator()
//              ]) ,
//            );
//          }
//      );
//    }
}
