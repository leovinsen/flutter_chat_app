
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CacheDatabase{

  final String tag = 'CACHE_DATABASE';
//  static final CacheDatabase _bookDatabase = new CacheDatabase._internal();

  final String tableUsersInfo = "users_info";
  final String tableUserContacts = "user_contacts";
  final String tableUserChats = "user_chats";
  final String colPublicId = "publicId";

  Database sqlDb;

  bool didInit = false;
//
//  static CacheDatabase get() {
//    return _bookDatabase;
//  }

//  CacheDatabase._internal();

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async{
    if(!didInit) await _init();
    return sqlDb;
  }


  ///TODO: BUILD STRUCTURE OF SQFlite DATABASE
  Future _init() async {
    // Get a location using path_provider
    print('Initializing SQLite database');
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "data.db");
    sqlDb = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute('''
              CREATE TABLE $tableUsersInfo (
                  ${UserData.kPublicId} TEXT PRIMARY KEY NOT NULL,
                  ${UserData.kDisplayName} TEXT NOT NULL,
                  ${UserData.kThumbUrl} TEXT)
                  ''');
          await db.execute('''
            CREATE TABLE $tableUserChats (
              ${ChatRoomData.kChatId} TEXT PRIMARY KEY NOT NULL,
              ${ChatRoomData.kAllMembersPublicId} TEXT NOT NULL,
              ${ChatRoomData.kAllMembersDisplayName} TEXT NOT NULL,
              ${ChatRoomData.kLastMessageSentId} TEXT NOT NULL,
              ${ChatRoomData.kLastMessageSent} TEXT NOT NULL,
              ${ChatRoomData.kLastMessageTime}  INTEGER NOT NULL)
          ''');
          await db.execute('''
            CREATE TABLE $tableUserContacts (
               $colPublicId TEXT PRIMARY KEY NOT NULL)
          ''');
        });
    didInit = true;
    print('SQLite database init done');
  }

  Future<UserData> getUserData(String publicId) async {
    var db = await _getDb();
    List<Map> maps = await db.query(tableUsersInfo,
        columns: [UserData.kPublicId, UserData.kDisplayName, UserData.kThumbUrl],
        where: "${UserData.kPublicId} = ?",
        whereArgs: [publicId]);
    if (maps.length > 0) {
      return UserData.fromMap(maps.first);
    }
    return null;
  }

  Future<List> getAllContactsData() async {
    var db = await _getDb();
    List result = await db.query(tableUsersInfo, columns: [UserData.kPublicId, UserData.kDisplayName, UserData.kThumbUrl]);
    return result;
  }

  Future<List> getAllChatRoomsData() async {
    var db = await _getDb();
    List result = await db.query(tableUserChats, columns: [
      ChatRoomData.kChatId,
      ChatRoomData.kAllMembersPublicId,
      ChatRoomData.kAllMembersDisplayName,
      ChatRoomData.kLastMessageSentId,
      ChatRoomData.kLastMessageSent,
      ChatRoomData.kLastMessageTime
    ]);
    return result;
  }

  Future<int> insertContact(String publicId) async {
    var db = await _getDb();
    return await db.insert(tableUserContacts, { colPublicId : publicId} );
  }

  Future<int> insertUser(UserData user) async {

    var db = await _getDb();
    int val = await db.insert(tableUsersInfo, user.toJson());
    print('DB insert return value: $val');
    return val;
  }

  Future<int> update(UserData user) async {
    var db = await _getDb();
    return await db.update(tableUsersInfo, user.toJson(),
        where: "${UserData.kPublicId} = ?", whereArgs: [user.publicId]);
  }

  Future delete() async {
    try {
      var databasePath = await getDatabasesPath();
      String path = join(databasePath, "data.db");
      await deleteDatabase(path);
    } catch (e) {
      throw e;
    }
  }

  ///MORE FUNCTIONS COMING
}