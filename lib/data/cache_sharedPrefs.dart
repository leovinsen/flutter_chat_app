import 'package:shared_preferences/shared_preferences.dart';

class CacheSharedPrefs {
  final String _kAuthToken = 'userAuthToken';
  final String _kPublicId = 'userPublicId';
  final String _kAuthStatus = 'userAuthStatus';

  static final CacheSharedPrefs instance = CacheSharedPrefs._internal();
  SharedPreferences _sp;
  bool didInit = false;


  CacheSharedPrefs._internal(){
//    init();
  }

//  void init() async {
//    _sp = await SharedPreferences.getInstance();
//  }

  Future<bool> destroy() async {
    var sp = await getSP();
    return await sp.clear();
  }

  Future<SharedPreferences> getSP() async {
    if (!didInit) {
      _sp = await SharedPreferences.getInstance();
      didInit = true;
    }
    return _sp;
  }


  ///LastAuthToken refers to the last uniqueID that was saved
  Future<String> getUserAuthToken() async {
    var sp = await getSP();
    return sp.get(_kAuthToken);
  }

  Future<String> getUserPublicId() async {
    var sp = await getSP();
    return sp.get(_kPublicId);

}

  Future<String> getUserAuthStatus() async {
    var sp = await getSP();
    return sp.get(_kAuthStatus);
  }

  Future<bool> updateUserAuthToken(String token) async {
    return await _sp.setString(_kAuthToken, token);
  }

  Future<bool> updateUserPublicId(String id) async {
    return await _sp.setString(_kPublicId, id);
  }
//
//  Future<bool> updateUserAuthStatus(String authStatus) async {
//    return await _sp.setString(_kAuthStatus, authStatus);
//  }
}