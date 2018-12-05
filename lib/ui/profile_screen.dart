import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final UserData user;
  ProfileScreen({this.user});

  @override
  ProfileScreenState createState() {
    return new ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {

  Future _pickImage() async {
    String publicId = widget.user.publicId;
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
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
          Container(
            margin: const EdgeInsets.all(30.0),
            child: GestureDetector(
              onTap: ()=> _pickImage(),
              child: CircleAvatar(
                radius: 100.0,
                child: Image.asset('assets/profile_default_thumbnail_64px.png', fit: BoxFit.cover,),
              ),
            ),
          ),

          publicIdContainer(context),
          displayNameContainer(context),

        ],
      )
    );
  }

  Container publicIdContainer(BuildContext context){
    return Container(
        alignment: Alignment.center,
        child: ListTile(
          title: Text('Public ID'),
          subtitle: Text(widget.user.publicId, style: blueSubtitle(context)),
        ),
        decoration: whiteBoxDecoration()
    );
  }

  Container displayNameContainer(BuildContext context){
    return Container(
      alignment: Alignment.center,
        child: ListTile(
          title: Text('Display Name'),
          subtitle: Text(widget.user.displayName, style: blueSubtitle(context),),
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
