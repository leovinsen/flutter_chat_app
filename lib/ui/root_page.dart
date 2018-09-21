import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';
import 'package:flutter_chat_app/util/firebase_handler.dart' as helper;

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

  //UserModel _user;
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
      userIsNotLoggedIn();
    }
  }

  Future<bool> findUserFirebaseAuthId() async {
    //Get user Auth ID from local storage
    _uniqueAuthId = CacheHandler.getUserFirebaseAuthId();

    //If not found, try online
    if (_uniqueAuthId == null) _uniqueAuthId = await auth.currentUser();

    return _uniqueAuthId != null;
  }

  Future<bool> findUserPublicId() async {
    _publicId = CacheHandler.getUserPublicId();

    if (_publicId == null)
      _publicId = await helper.getUserPublicId(_uniqueAuthId);

    return _publicId != null;
  }

  checkRegistrationStatus() async {
    print('$tag: Checking Registration Status');
//    //If true

    if (await findUserPublicId()) {
      userIsRegistered();
    } else {
      _publicId = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
          ));

      userIsRegistered();
    }
  }

  void userIsNotLoggedIn() {
    setState(() {
      loading = false;
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void userIsRegistered() {
    setState(() {
      authStatus = AuthStatus.signedIn;
      loading = false;
    });
  }

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
          return HomePage(
            //userAuthId: _uniqueAuthId,
            userPublicId: _publicId,
            onSignOut: () => _signOut(),
            //userModel: _user,
          );
      }
    }
  }
}
