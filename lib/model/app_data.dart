import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/util/firebase_handler.dart';
import 'package:scoped_model/scoped_model.dart';


class AppData extends Model{

  FirebaseHandler _firebaseHandler;

  String _firebaseAuthId;
  UserData _userData;
  List<UserData> _contactsData;
  List<ChatRoomData> _chatRoomsData;

  String get firebaseAuthId => _firebaseAuthId;

  String get userPublidId => _userData.publicId;
  String get userDisplayName => _userData.displayName;
  String get userThumbUrl => _userData.displayName;

  List<UserData> get contactsData => _contactsData;

  List<ChatRoomData> get chatRoomData => _chatRoomsData;

  AppData(String publicId){
    initUserModel(publicId);
    init();
  }

  init(){

  }

  initUserModel(String publicId){
    _userData = UserData(null, null, null);

    //Retrieve userData from cache
    String displayName = CacheHandler.getUserDisplayName();
    String thumbUrl = CacheHandler.getUserThumbUrl();

    if(displayName != null && thumbUrl != null){
      UserData model = UserData(publicId, displayName, thumbUrl);
      _userData = model;
    }

    notifyListeners();

//    helper.getUserModelForPublicId(widget.userPublicId).then((model){
//      updateUserModel(model);
//    });

  }
}