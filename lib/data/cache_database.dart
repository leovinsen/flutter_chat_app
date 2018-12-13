import 'package:flutter_chat_app/model/user_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CacheDatabase{

//  static final CacheDatabase _bookDatabase = new CacheDatabase._internal();

  final String tableName = "users_info";

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
              CREATE TABLE $tableName (
                  ${UserData.kPublicId} TEXT PRIMARY KEY NOT NULL,
                  ${UserData.kDisplayName} TEXT NOT NULL,
                  ${UserData.kThumbUrl} TEXT)
                  ''');
        });
    didInit = true;
    print('SQLite database init done');
  }

  Future<UserData> getUserData(String publicId) async {
    var db = await _getDb();
    List<Map> maps = await db.query(tableName,
        columns: [UserData.kPublicId, UserData.kDisplayName, UserData.kThumbUrl],
        where: "${UserData.kPublicId} = ?",
        whereArgs: [publicId]);
    if (maps.length > 0) {
      return UserData.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insert(UserData user) async {

    var db = await _getDb();
    int val = await db.insert(tableName, user.toJson());
    print('DB insert return value: $val');
  }

  Future<int> update(UserData user) async {
    var db = await _getDb();
    return await db.update(tableName, user.toJson(),
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