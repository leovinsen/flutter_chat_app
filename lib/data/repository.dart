import 'package:flutter_chat_app/data/cache_database.dart';
import 'package:flutter_chat_app/data/cache_sharedPrefs.dart';
import 'package:flutter_chat_app/data/network_handler.dart';
import 'package:flutter_chat_app/model/auth.dart';

enum AuthStatus {
  notSignedIn,
  incompleteRegistration,
  signedIn,
}

AuthStatus enumFromString(String str){
  return AuthStatus.values.firstWhere((elem) => elem.toString() == str, orElse: ()=> null);
}

class Repository {

  static final Repository _repo = Repository._internal();
  //static const String publicId;

  CacheDatabase database;
  CacheSharedPrefs sharedPrefs;
  NetworkHandler network;
  Auth auth;

  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = CacheDatabase.get();
    sharedPrefs = CacheSharedPrefs.instance;
    auth = Auth.instance;
    network = NetworkHandler.instance;
  }

  Future<AuthStatus> authenticate() async {
    AuthStatus status = enumFromString(await sharedPrefs.getUserAuthStatus());
    print(status.toString());
    if (status == null) {
      print('a');
      String token = await getUserAuthToken();
      if (token == null) {
        print('b');
        status = AuthStatus.notSignedIn;
      }
      else {
        print('c');
        String publicId = await getUserPublicId(token);
        status =
        (publicId == null) ? AuthStatus.incompleteRegistration : AuthStatus
            .signedIn;
      }
    }
    return status;
//
//    if (uniqueAuthId != null) {
//      var snapshot = await FirebaseDatabase.instance.reference().child(
//          'users/$uniqueAuthId').once();
//      String publicId = snapshot.value;
//      return publicId == null ? AuthStatus.incompleteRegistration : AuthStatus
//          .signedIn;
//    } else {
//      return AuthStatus.notSignedIn;
//    }
  }

  Future<String> getUserAuthToken() async {
    String token = await sharedPrefs.getUserAuthToken();
    print('token: $token');
    if (token == null)
      token = await auth.currentUser();
    print('token2: $token');
    return token;
  }

  Future<String> getUserPublicId(String token) async {
    String publicId = await sharedPrefs.getUserPublicId();
    if (publicId == null)
      publicId = await network.fetchPublicId(token);
  }

 // Future<UserData> getUserDataFor
//
//  ///Called when app is first started,
//  ///determine whether user is signed in or not
//  Future<AuthStatus> authenticate() async {
//    String uniqueAuthId = await Auth.instance.currentUser();
//    if(uniqueAuthId != null){
//      var snapshot = await FirebaseDatabase.instance.reference().child('users/$uniqueAuthId').once();
//      String publicId = snapshot.value;
//      return publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//    } else {
//      return AuthStatus.notSignedIn;
//    }
//  }

//  _uniqueAuthId = await getUserAuthToken();
//  if(_uniqueAuthId != null) {
//  _publicId = await getUserPublicId();
//  _authStatus = _publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//  } else {
//  _authStatus =AuthStatus.notSignedIn;
//  }

//  Future<String> getUserAuthToken() async {
//    //Get user Auth ID from local storage
//    String uniqueAuthId = CacheHandler.getUserFirebaseAuthId();
//
//    //If not found, try online
//    if (uniqueAuthId == null) uniqueAuthId = await auth.currentUser();
//
//    return uniqueAuthId;
//  }

//  ///TODO: Change to Future<String>
//  Future<String> getUserPublicId() async {
//    //String _publicId = CacheHandler.getUserPublicId();
//
//    if (_publicId == null){
//      var db = FirebaseDatabase.instance;
//      var usersBranch = db.reference().child('users');
//      DataSnapshot snapshot = await usersBranch.child(_uniqueAuthId).once();
//      _publicId = snapshot.value;
//    }
//    return _publicId ?? "";
//  }




}