import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util/firebase_handler.dart' as helper;
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/user_data.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String _uniqueAuthId;
  AdditionalInfoScreen(this._uniqueAuthId);
  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  static final formKey = GlobalKey<FormState>();
  String _publicId;
  String _displayName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
        centerTitle: true,
        leading: Container(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _handleSubmit(),
          )
        ],
      ),
      body: Center(
        child: form(),
      ),
    );
  }

  Widget publicIdField(){
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      autofocus: true,
      validator: (val) => val.isEmpty ? 'Enter a unique ID.' : null,
      onSaved: (val) => _publicId = val,
      decoration: InputDecoration(
          hintText: 'Username',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget displayNameField(){
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autofocus: true,
      validator: (val) => val.isEmpty ? 'Please enter your name.' : null,
      onSaved: (val) => _displayName = val,
      decoration: InputDecoration(
          hintText: 'Display Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Form form(){
    return Form(
      key: formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          publicIdField(),
          SizedBox(height: 12.0),
          displayNameField(),
        ],
      ),
    );
  }


  void _handleSubmit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      try {
        //Create association between Auth ID with Public ID
        helper.createUserAssociation(widget._uniqueAuthId, _publicId);

        String thumbUrl = 'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-10a1f'
            '.appspot.com/o/profile_default_thumbnail_128px.png?alt=media&token=d8769ef5-281f-4d16-a4cd-f733f85fe45c';





        //Create a record in UsersInfo which contains user's personal information


        UserData user = UserData(_publicId, _displayName, thumbUrl);

        helper.updateUsersInfo(user).then((val){
          CacheHandler.storeUserPublicId(_publicId);
          CacheHandler.storeUserDisplayName(_displayName);
          CacheHandler.storeUserThumbnailUrl(thumbUrl);
          Navigator.pop(context, _publicId);
        });
      } catch (e){
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('ERROR caught'))
        );
        print(e);
      }

    }
  }
}
