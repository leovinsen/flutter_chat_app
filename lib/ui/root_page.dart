import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';



class RootPage extends StatefulWidget {
  //RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  incompleteRegistration,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';
  final BaseAuth auth = Auth();

  String _uniqueAuthId;
  String _publicId;
  AuthStatus _authStatus;
  bool loading = true;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    await CacheHandler.init();

    _uniqueAuthId = await getUserAuthToken();
    if(_uniqueAuthId != null) {
      _publicId = await getUserPublicId();
      _authStatus = _publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
    } else {
      _authStatus =AuthStatus.notSignedIn;
    }

    setState(() {
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
    return _publicId ?? "";
  }

  ///TODO: Create anew auth status for partial registration, to remove checkRegistration status and merge with logIn
  void _signIn(String userAuthId) async {
    _uniqueAuthId = userAuthId;
    _publicId = await getUserPublicId();
   setState(() {
     _authStatus = _publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
   });
  }

  void _signOut() {
    setState(() {
      auth.signOut();
      AppData.of(context).cleanup();
      CacheHandler.clearUserCreds();
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('calling build ROOT_PAGE');
    if (loading) {
      return _loadingScreen();
    } else {
      switch (_authStatus) {
        case AuthStatus.notSignedIn:
          return LoginPage(
            auth: auth,
            onSignIn: _signIn,
          );

        case AuthStatus.incompleteRegistration:
          return AdditionalInfoScreen(_uniqueAuthId, () {
            setState(() {

            });
          });
        case AuthStatus.signedIn:
          AppData.of(context).initUserModel(_publicId);
          return HomePage(
            onSignOut: () => _signOut(),
          );
      }
    }
  }

  Widget _loadingScreen(){
    return Container(
        color: Theme
            .of(context)
            .primaryColor,
//        padding: const EdgeInsets.all(10.0),
//        alignment: Alignment.center,
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: <Widget>[
//
//            SizedBox(
//                height: 60.0,
//                width: 60.0,
//                child: CircularProgressIndicator(
//                  strokeWidth: 4.0,
//                )),
//            SizedBox(height: 50.0),
//            Text('Signing In...')
//
//          ],
//        )
    );
  }

}
