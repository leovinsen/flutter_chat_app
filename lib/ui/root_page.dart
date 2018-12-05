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
  signedIn,
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

    if (await findUserFirebaseAuthId()) {
      checkRegistrationStatus();
    } else {
      notLoggedIn();
    }
  }

  ///TODO: Change to Future<String>
  Future<bool> findUserFirebaseAuthId() async {
    //Get user Auth ID from local storage
    _uniqueAuthId = CacheHandler.getUserFirebaseAuthId();

    //If not found, try online
    if (_uniqueAuthId == null) _uniqueAuthId = await auth.currentUser();

    return _uniqueAuthId != null;
  }

  ///TODO: Change to Future<String>
  Future<bool> findUserPublicId() async {
    _publicId = CacheHandler.getUserPublicId();

    if (_publicId == null)
      _publicId = await getUserPublicId(_uniqueAuthId);

    return _publicId != null;
  }

  ///TODO: MERGE with FinduserPublicId
  Future<String> getUserPublicId(String uniqueAuthId) async {
    var db = FirebaseDatabase.instance;
    var usersBranch = db.reference().child('users');
    DataSnapshot snapshot = await usersBranch.child(uniqueAuthId).once();
    return snapshot.value;
  }


  ///Checks if the user has entered a username and display name
  ///If yes, proceed, else ask user to fill in additional info
  checkRegistrationStatus() async {

    ///If publicID (username) is available, then user is fully registered
    if (await findUserPublicId()) {
      logIn();
    } else {
      _publicId = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
          ));

      logIn();
    }
  }

  void notLoggedIn() {
    setState(() {
      loading = false;
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void logIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
      loading = false;
    });
  }


  ///TODO: Create anew auth status for partial registration, to remove checkRegistration status and merge with logIn
  void _signIn(String userAuthId) {
    setState(() {
      _uniqueAuthId = userAuthId;
      //authStatus = AuthStatus.signedIn;
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
          return new LoginPage(
            auth: auth,
            onSignIn: _signIn,
          );
        case AuthStatus.signedIn:
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
