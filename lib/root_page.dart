import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/auth.dart';
import 'package:flutter_chat_app/home_page_new.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login_page_new.dart';
import 'package:flutter_chat_app/helper.dart' as helper;

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
  UserModel _user;
  String _uniqueAuthId;
  AuthStatus authStatus = AuthStatus.notSignedIn;
  bool _completeRegistration = false;

  @override
  initState() {
    super.initState();
    auth.currentUser().then((userId) {
      setState(() {
        _uniqueAuthId = userId;
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });

      if(userId != null) checkRegistrationStatus2();
    });
  }


//  isUserFullyRegistered() async {
//    String publicId = await helper.getUserPublicId(_uniqueAuthId);
//    return publicId != null;
//  }

  checkRegistrationStatus2() async {
    print('$tag: Checking Registration Status');
    //If true
    String publicId = await helper.getUserPublicId(_uniqueAuthId);

    if (publicId != null){
      UserModel userModel = await helper.getUserModelForPublicId(publicId);

      setState(() {
        _user = userModel;
        _completeRegistration = true;
      });
    } else {

      final userModel = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
          ));

      setState(() {
        _user = userModel;
        _completeRegistration = true;
      });
    }
    //Retrieve user's public Id
//    helper.getUserPublicId(_uniqueAuthId).then((publicIdSnapshot) async {
//      //If there is none
//      //Prompt user to create a publicID/UserName & DisplayName
//      if (publicIdSnapshot.value == null) {
//        //_completeRegistration = false;
//
//        //print('Snapshot value is null. No record exists in UsersInfo');
//        final userModel = await Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
//            ));
//
//        setState(() {
//          _user = userModel;
//          _completeRegistration = true;
//        });
//      } else {
//        //print('Record exist in UsersInfo');
//
////          helper.getUserModelForPublicId(publicIdSnapshot.value).then((snapshot){
//        UserModel userModel = await helper.getUserModelForPublicId(publicIdSnapshot.value);
//
//        setState(() {
//          _user = userModel;
//          _completeRegistration = true;
//        });
//      }
//    });
  }

  void _signIn(String userAuthId) {
    checkRegistrationStatus2();
    setState(() {
      _uniqueAuthId = userAuthId;
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signOut() {
    setState(() {
      auth.signOut();
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('calling build');
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPageNew(
          auth: auth,
          onSignIn: _signIn,
        );
      case AuthStatus.signedIn:
//        helper.usersRef.child(_userAuthId).once().then(( snapshot) async{
//          //If there is none
//          //Prompt user to create a publicID/UserName & DisplayName
//          if(snapshot.value == null){
//            print('Snapshot value is null. No record exists in UsersInfo');
//            final results = await Navigator.push(context, MaterialPageRoute(
//              builder: (context) => AdditionalInfoScreen(_userAuthId),
//            ));
//
//            _user = results;
//
////            _user = UserModel();
////
////            _user.thumbUrl = thumbUrl;
//            //_registered = false;
//
//
//          } else {
//            print('Record exist in UsersInfo');
//            _user = UserModel.fromSnapshot(snapshot);
//            //_registered = true;
//
//          }
//        });
        if (_completeRegistration) {
          return HomePageNew(
            userAuthId: _uniqueAuthId,
            onSignOut: () => _signOut(),
            userModel: _user,
          );
        } else {
          return Container(
            color: Colors.white,
          );
        }
    }
  }
}

//class RootPage extends StatelessWidget {
//    RootPage({Key key, this.title}) : super(key:key);
//  final String title;
//
//
//  @override
//  Widget build(BuildContext context) {
//
//    return ScopedModelDescendant<AppModel>(
//      builder: (context, child, model){
//        if(!model.ready){
//          return Container(child: CircularProgressIndicator(),);
//        } else {
//          switch(model.authStatus){
//            case AuthStatus.notSignedIn:
//              return LoginPage();
//            case AuthStatus.register:
//              return RegisterPage();
//            case AuthStatus.signedIn:
//              return HomePage(model.auth, model.uid);
//          }
//        }
//
//      }
//    );
//  }
//}

//
//class RootPage extends StatefulWidget {
//  RootPage({Key key, this.title}) : super(key:key);
//  final String title;
//  //RootPage({Key key, this.auth}) : super(key:key);
//  //final BaseAuth auth;
//
//  @override
//  _RootPageState createState() => _RootPageState();
//}
//
//enum AuthStatus {
//  signedIn,
//  notSignedIn,
//}
//
//class _RootPageState extends State<RootPage> {
//
//  AuthStatus authStatus = AuthStatus.notSignedIn;
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
////    widget.auth.currentUser().then((userId){
////      setState(() {
////        authStatus = userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
////      });
////    });
//  }
//
//  void _updateAuthStatus(AuthStatus status){
//    setState(() {
//      authStatus = status;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    switch(authStatus){
//      case AuthStatus.notSignedIn:
//        return LoginPage(
//          title: 'Login Page',
//          //auth: widget.auth,
//          //onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
//        );
//      case AuthStatus.signedIn:
//        return Container(
//          child: Text("Hello!!!"),
//        );
//    }
//
//    return Container();
//  }
//}
