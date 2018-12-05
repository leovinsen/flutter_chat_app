import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:flutter_chat_app/util/firebase_handler.dart' as helper;


class RootPage extends StatefulWidget {
  //RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';
  final BaseAuth auth = Auth();

  String _uniqueAuthId;
  AuthStatus authStatus = AuthStatus.notSignedIn;
  bool loading = true;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    await CacheHandler.init();

    _uniqueAuthId = await getUserAuthToken();

    setState(() {
      if(_uniqueAuthId != null) authStatus = AuthStatus.signedIn;
      loading = false;
    });
  }

  Future<String> getUserAuthToken() async {
    //Get user Auth ID from local storage
     String uniqueAuthId = CacheHandler.getUserFirebaseAuthId();

    //If not found, try online
    if (uniqueAuthId == null) uniqueAuthId = await auth.currentUser();

    return uniqueAuthId;
  }

  ///TODO: Change to Future<String>
  Future<String> getUserPublicId() async {
    String _publicId = CacheHandler.getUserPublicId();

    if (_publicId == null){
      var db = FirebaseDatabase.instance;
      var usersBranch = db.reference().child('users');
      DataSnapshot snapshot = await usersBranch.child(_uniqueAuthId).once();
      _publicId = snapshot.value;
    }
    return _publicId;
  }

  ///TODO: Create anew auth status for partial registration, to remove checkRegistration status and merge with logIn
  void _signIn(String userAuthId) {
    setState(() {
      _uniqueAuthId = userAuthId;
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signOut() {
    setState(() {
      auth.signOut();
      CacheHandler.clearUserCreds();
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('calling build ROOT_PAGE');
    if (loading) {
      return Container(
          color: Theme
              .of(context)
              .backgroundColor,
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              SizedBox(
                  height: 60.0,
                  width: 60.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                  )),
              SizedBox(height: 50.0),
              Text('Signing In...')

            ],
        )
      );
    } else {
      switch (authStatus) {
        case AuthStatus.notSignedIn:
          return LoginPage(
            auth: auth,
            onSignIn: _signIn,
          );
        case AuthStatus.signedIn:
          return FutureBuilder(
              future: getUserPublicId(),
              builder: (_, snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                //return Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                //return Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                String publicId = snapshot.data;

                return publicId == null
                    ? AdditionalInfoScreen(_uniqueAuthId, (){
                      setState(() {

                      });
                })
                    : ScopedModel<AppData>(
                  model: AppData(publicId),
                  child: HomePage(
                    onSignOut: () => _signOut(),
                  ),
                );
            }
              });
      }
    }
  }
}
