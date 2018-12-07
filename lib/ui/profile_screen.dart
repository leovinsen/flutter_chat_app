import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/widgets/circular_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final AppData appData;
  ProfileScreen({this.appData});

  @override
  ProfileScreenState createState() {
    return new ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {

  Future _pickImage(ImageSource imgSource) async {
    if(imgSource == null) return;

    String publicId = widget.appData.userPublicId;
    File imageFile = await ImagePicker.pickImage(source: imgSource, maxWidth: 400, maxHeight: 400);
    StorageReference ref =
    FirebaseStorage.instance.ref().child(publicId).child("profile_picture.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);

    FirebaseDatabase db = FirebaseDatabase.instance;
    String s = await (await uploadTask.onComplete).ref.getDownloadURL();
    db.reference().child('usersInfo/$publicId').update({'thumbUrl' : s });
    debugPrint('Upload successful: $s');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          profilePicture(),
          publicIdContainer(context),
          displayNameContainer(context),

        ],
      )
    );
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

  Widget profilePicture(){
    return Container(
      margin: const EdgeInsets.all(30.0),
      child: GestureDetector(
        onTap: () async => _pickImage(await chooseImageSource()),
        child: CircleAvatar(
          radius: 100.0,
          child: CircularImage(
            size: 200.0,
            url: widget.appData.userThumbUrl,
          ),
        ),
      ),
    );
  }

  Container publicIdContainer(BuildContext context){
    return Container(
        alignment: Alignment.center,
        child: ListTile(
          title: Text('Public ID'),
          subtitle: Text(widget.appData.userPublicId, style: blueSubtitle(context)),
        ),
        decoration: whiteBoxDecoration()
    );
  }

  Container displayNameContainer(BuildContext context){
    return Container(
      alignment: Alignment.center,
        child: ListTile(
          title: Text('Display Name'),
          subtitle: Text(widget.appData.userDisplayName, style: blueSubtitle(context),),
          trailing: IconButton(icon: Icon(Icons.edit), onPressed: null),
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
}
