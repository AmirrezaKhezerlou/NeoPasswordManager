import 'dart:io' show Platform, Directory;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:math';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class PasswordModel {
  final String id;
  final String? label;
  final String password;
  final DateTime creationDate;
  final DateTime? lastUpdated;

  PasswordModel({
    required this.id,
    this.label,
    required this.password,
    required this.creationDate,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'password': password,
      'creationDate': creationDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'] as String,
      label: map['label'] as String?,
      password: map['password'] as String,
      creationDate: DateTime.parse(map['creationDate'] as String),
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated'] as String) : null,
    );
  }
}

extension PasswordModelExtension on PasswordModel {
  PasswordModel copyWith({
    String? id,
    String? label,
    String? password,
    DateTime? creationDate,
    DateTime? lastUpdated,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      label: label ?? this.label,
      password: password ?? this.password,
      creationDate: creationDate ?? this.creationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _ffiInitialized = false;
  final String _dbName = 'passwords.db';
  final String _tableName = 'passwordEntries';
  final String _columnId = 'id';
  final String _columnLabel = 'label';
  final String _columnPassword = 'password';
  final String _columnCreationDate = 'creationDate';
  final String _columnLastUpdated = 'lastUpdated';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {

    if (!_ffiInitialized && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      ffi.sqfliteFfiInit();
      _ffiInitialized = true;
    }

    String dbPath;
    if (Platform.isAndroid || Platform.isIOS) {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, _dbName);
    } else {

      final appData = Platform.isWindows
          ? Platform.environment['APPDATA'] ?? p.join(Platform.environment['USERPROFILE'] ?? '', 'AppData', 'Roaming')
          : Platform.environment['HOME'] ?? '';
      dbPath = p.join(appData, 'NeoPass', _dbName);
    }


    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await Directory(p.dirname(dbPath)).create(recursive: true);
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return await ffi.databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          onCreate: _onCreate,
          version: 1,
        ),

      );
    } else {
      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId TEXT PRIMARY KEY,
        $_columnLabel TEXT,
        $_columnPassword TEXT NOT NULL,
        $_columnCreationDate TEXT NOT NULL,
        $_columnLastUpdated TEXT
      )
    ''');
  }

  Future<int> addPassword(PasswordModel password) async {
    final db = await database;
    return await db.insert(
      _tableName,
      password.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PasswordModel?> getPasswordById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? PasswordModel.fromMap(maps.first) : null;
  }

  Future<List<PasswordModel>> getAllPasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return maps.map((e) => PasswordModel.fromMap(e)).toList();
  }

  Future<int> updatePassword(PasswordModel password) async {
    final db = await database;
    return await db.update(
      _tableName,
      password.toMap(),
      where: '$_columnId = ?',
      whereArgs: [password.id],
    );
  }

  Future<int> deletePassword(String id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }
}

class PasswordDatabase {
  static final PasswordDatabase instance = PasswordDatabase._internal();
  factory PasswordDatabase() => instance;
  PasswordDatabase._internal();

  final _dbHelper = DatabaseHelper.instance;
  final _random = Random();

  String _generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(10000)}';
  }

  Future<void> addPassword(PasswordModel model) async {
    final passwordToAdd = model.id.isEmpty
        ? model.copyWith(
      id: _generateUniqueId(),
      creationDate: DateTime.now(),
      lastUpdated: null,
    )
        : model;
    await _dbHelper.addPassword(passwordToAdd);
  }

  Future<PasswordModel?> getPassword(String id) async {
    return await _dbHelper.getPasswordById(id);
  }

  Future<List<PasswordModel>> getAllPasswords() async {
    return await _dbHelper.getAllPasswords();
  }

  Future<void> updatePassword(PasswordModel model) async {
    final updatedModel = model.copyWith(lastUpdated: DateTime.now());
    await _dbHelper.updatePassword(updatedModel);
  }

  Future<void> deletePassword(String id) async {
    await _dbHelper.deletePassword(id);
  }
}