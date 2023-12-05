import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BMIDatabase {
  static const String _dbName = "bitp3453_bmi";
  static const String _tblName = "bmi";
  static const String _colUsername = "username";
  static const String _colWeight = "weight";
  static const String _colHeight = "height";
  static const String _colGender = "gender";
  static const String _colStatus = "bmi_status";

  String get colUsername => _colUsername;
  String get colWeight => _colWeight;
  String get colHeight => _colHeight;
  String get colGender => _colGender;
  String get colStatus => _colStatus;

  Database? _database;

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_tblName("
              "$_colUsername TEXT PRIMARY KEY,"
              "$_colWeight REAL,"
              "$_colHeight REAL,"
              "$_colGender TEXT,"
              "$_colStatus TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertData(String username, double weight, double height, String gender, String status) async {
    // Ensure the database is initialized before using it
    if (_database == null || !_database!.isOpen) {
      await _initDatabase();
    }

    return await _database!.insert(
      _tblName,
      {
        _colUsername: username,
        _colWeight: weight,
        _colHeight: height,
        _colGender: gender,
        _colStatus: status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    // Ensure the database is initialized before using it
    if (_database == null || !_database!.isOpen) {
      await _initDatabase();
    }

    return await _database!.query(_tblName);
  }
}

