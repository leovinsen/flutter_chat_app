import 'package:flutter/material.dart';
import 'package:flutter_chat_app/data/repository.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String _authToken;
  final Function _refresh;
  AdditionalInfoScreen(this._authToken, this._refresh);
  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  static final formKey = GlobalKey<FormState>();
  String _publicId;
  String _displayName;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
        centerTitle: true,
        leading: Container(),
        actions: <Widget>[
          _loading ? CircularProgressIndicator() : IconButton(
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
      textInputAction: TextInputAction.next,
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
      textInputAction: TextInputAction.done,
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
        setState(() {
          _loading = true;
        });

        Repository.get().finishRegistration(_publicId, _displayName).then((a){
          Repository.get().authenticate();
          if(mounted) setState(() {
            _loading = false;
          });
        });



        //Create a record in UsersInfo which contains user's personal information
      } catch (e){
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('ERROR caught'))
        );
        print(e);
      }

    }
  }

//  Future<void> updateUsersInfo(UserData model){
//    return _usersInfoRef.child(model.publicId).set(model.toJson());
//  }
//
//  Future<void> createUserAssociation(String uniqueAuthId, String publicId){
//    return _usersRef.child(uniqueAuthId).set(publicId);
//  }
}
