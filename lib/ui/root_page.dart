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

///notSignedIn means user is not logged In
///partiallySignedIn means user is logged in, but there is no records for his/her publicId
///fullySignedIn means user is logged in, and there is records for his/her publicId
enum AuthStatus {
  notSignedIn,
  partiallySignedIn,
  fullySignedIn,
}

class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';
  final BaseAuth auth = Auth();

  String _uniqueAuthId;
  String _publicId;
  AuthStatus authStatus = AuthStatus.notSignedIn;
  bool loading = true;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    await CacheHandler.init();

    _uniqueAuthId = await findUserFirebaseAuthId();

    ///2 cases: user has
    if (_uniqueAuthId != null) {
      checkRegistrationStatus();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<String> findUserFirebaseAuthId() async {
    //Get user Auth ID from local storage
     String uniqueAuthId = CacheHandler.getUserFirebaseAuthId();

    //If not found, try online
    if (uniqueAuthId == null) _uniqueAuthId = await auth.currentUser();

    return uniqueAuthId;
  }

  ///TODO: Change to Future<String>
  Future<String> findUserPublicId() async {
    String _publicId = CacheHandler.getUserPublicId();

    if (_publicId == null){
      var db = FirebaseDatabase.instance;
      var usersBranch = db.reference().child('users');
      DataSnapshot snapshot = await usersBranch.child(_uniqueAuthId).once();
      _publicId = snapshot.value;
    }
    return _publicId;
  }


  ///Checks if the user has entered a username and display name
  ///If yes, proceed, else ask user to fill in additional info
  checkRegistrationStatus() async {

    ///If publicID (username) is available, then user is fully registered
    _publicId = await findUserPublicId();

    setState(() {
      loading = false;
      authStatus = _publicId != null ? AuthStatus.fullySignedIn : AuthStatus.partiallySignedIn;
    });
  }

  ///TODO: Create anew auth status for partial registration, to remove checkRegistration status and merge with logIn
  void _signIn(String userAuthId) {
    setState(() {
      _uniqueAuthId = userAuthId;
    });

    checkRegistrationStatus();
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
        color: Theme.of(context).backgroundColor,
        alignment: Alignment.center,
        child: SizedBox(
            height: 60.0,
            width: 60.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
            )),
      );
    } else {
      switch (authStatus) {
        case AuthStatus.notSignedIn:
          return LoginPage(
            auth: auth,
            onSignIn: _signIn,
          );




        case AuthStatus.partiallySignedIn:
          return AdditionalInfoScreen(_uniqueAuthId);


        case AuthStatus.fullySignedIn:
          return ScopedModel<AppData>(
            model: AppData(_publicId),
            child: HomePage(
              //userAuthId: _uniqueAuthId,
//              userPublicId: _publicId,
              onSignOut: () => _signOut(),
              //userModel: _user,
            ),
          );
      }
    }
  }
}
