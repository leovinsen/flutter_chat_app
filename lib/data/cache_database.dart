import 'package:sqflite/sqflite.dart';

class CacheDatabase{

  static final CacheDatabase _bookDatabase = new CacheDatabase._internal();

//  final String tableName = "";

  Database db;

  bool didInit = false;

  static CacheDatabase get() {
    return _bookDatabase;
  }

  CacheDatabase._internal();

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async{
    if(!didInit) await _init();
    return db;
  }


  ///TODO: BUILD STRUCTURE OF SQFlite DATABASE
  Future _init() async {
//    // Get a location using path_provider
//    Directory documentsDirectory = await getApplicationDocumentsDirectory();
//    String path = join(documentsDirectory.path, "demo.db");
//    db = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          // When creating the db, create the table
//          await db.execute(
//              "CREATE TABLE $tableName ("
//                  "${Book.db_id} STRING PRIMARY KEY,"
//                  "${Book.db_title} TEXT,"
//                  "${Book.db_url} TEXT,"
//                  "${Book.db_star} BIT,"
//                  "${Book.db_notes} TEXT"
//                  ")");
//        });
//    didInit = true;
  }

  ///MORE FUNCTIONS COMING
}