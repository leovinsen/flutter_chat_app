import 'package:shared_preferences/shared_preferences.dart';

class CacheSharedPrefs {
  final String tag = "SHARED_PREFS";
  final String _kAuthToken = 'userAuthToken';
  final String _kPublicId = 'userPublicId';
  final String _kDisplayName = 'userDisplayName';
  final String _kThumbUrl = 'userThumbUrl';

  SharedPreferences _sp;
  bool didInit = false;

  Future<bool> init() async {
    try {
      _sp = await SharedPreferences.getInstance();
      return true;
    } catch (e){
      return false;
    }
  }

  Future<bool> destroy() async {
    var sp = await getSP();
    print('$tag: Deleting sharedPrefs');
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

  Future<String> getUserDisplayName() async {
    var sp = await getSP();
    return sp.get(_kDisplayName);
  }

  Future<String> getUserThumbUrl() async {
    var sp = await getSP();
    return sp.get(_kThumbUrl);
  }

  Future<bool> updateUserAuthToken(String token) async {
    print('$tag: Saving user token $token');
    return await _sp.setString(_kAuthToken, token);
  }

  Future<bool> updateUserPublicId(String id) async {
    print('$tag: Saving user public Id $id');
    return await _sp.setString(_kPublicId, id);
  }

  Future<bool> updateUserDisplayName(String name) async {
    print('$tag: Saving user display name $name');
    return await _sp.setString(_kDisplayName, name);
  }

  Future<bool> updateUserThumbUrl(String url) async {
    print('$tag: Saving user thumbUrl $url');
    return await _sp.setString(_kThumbUrl, url);
  }
}