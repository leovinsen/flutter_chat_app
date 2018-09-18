import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/home_page.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page_new.dart';
import 'package:flutter_chat_app/util/helper.dart' as helper;

class RootPage extends StatefulWidget {
  //RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
  partiallyRegistered
}

class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';
  final BaseAuth auth = Auth();
  //UserModel _user;
  String _uniqueAuthId;
  String _publicId;
  AuthStatus authStatus = AuthStatus.notSignedIn;
  bool loading = true;
  //bool _completeRegistration = false;

  @override
  initState() {
    super.initState();
    init();

  }

  init() async{
    await CacheHandler.init();

    if(await findUserFirebaseAuthId()){
      checkRegistrationStatus();
    } else {
      userIsNotLoggedIn();
    }

//    //Get user Auth ID from local storage
//    _uniqueAuthId = CacheHandler.getUserFirebaseAuthId();
//
//    //If it does not exist
//    if(_uniqueAuthId == null){
//
//
//      //Confirm with firebase
//      _uniqueAuthId = await auth.currentUser();
//
//      //If user is logged in
//      if (_uniqueAuthId != null) {
//        checkRegistrationStatus();
//      } else {
//        userIsNotLoggedIn();
//      }
//
//    } else {
//      checkRegistrationStatus();
//    }
  }

  Future<bool> findUserFirebaseAuthId() async {

    //Get user Auth ID from local storage
    _uniqueAuthId = CacheHandler.getUserFirebaseAuthId();

    //If not found, try online
    if(_uniqueAuthId == null) _uniqueAuthId = await auth.currentUser();

    return _uniqueAuthId != null;

  }

  Future<bool> findUserPublicId() async {
    _publicId = CacheHandler.getUserPublicId();

    if (_publicId == null) _publicId = await helper.getUserPublicId(_uniqueAuthId);

    return _publicId != null;
  }


  checkRegistrationStatus() async {
    print('$tag: Checking Registration Status');
//    //If true
//    //String publicId = await helper.getUserPublicId(_uniqueAuthId);
//    String publicId;
//    //bool b = CacheHandler.getUserRegistrationStatus();
//    publicId = CacheHandler.getUserPublicId();


    if(await findUserPublicId()){
      userIsRegistered();
    } else {
      _publicId = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
          ));

      userIsRegistered();
    }
//    //check if the publicId is available locally
//    if(publicId != null){
//      userIsRegistered();
//    } else {
//
//      //if not check on firebase
//      publicId = await helper.getUserPublicId(_uniqueAuthId);
//
//      if(publicId == null){
//        await Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
//            ));
//
//        userIsRegistered();
//      } else {
//        userIsRegistered();
//      }

//      await Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => AdditionalInfoScreen(_uniqueAuthId),
//          ));
//
//      setState(() {
//        authStatus = AuthStatus.signedIn;
//        loading = false;
//      });

    }



  void userIsNotLoggedIn(){
    setState(() {
      loading = false;
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void userIsRegistered(){
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
    if(loading) {
      return  Center(child: CircularProgressIndicator(strokeWidth: 10.0,),);
    } else {
      switch (authStatus) {
        case AuthStatus.notSignedIn:
          return new LoginPageNew(
            auth: auth,
            onSignIn: _signIn,
          );
        case AuthStatus.partiallyRegistered:
          return Container(
              child: Text('loading', style: TextStyle(fontSize: 25.0),)
          );
        case AuthStatus.signedIn:
          return HomePageNew(
            //userAuthId: _uniqueAuthId,
            userPublicId: _publicId,
            onSignOut: () => _signOut(),
            //userModel: _user,
          );
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
//        if (_completeRegistration) {
//          return HomePageNew(
//            userAuthId: _uniqueAuthId,
//            onSignOut: () => _signOut(),
//            userModel: _user,
//          );
//        } else {
//          return Container(
//            child: Text('loading', style: TextStyle(fontSize: 25.0),),
//            color: Colors.white,
//          );
//        }
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
