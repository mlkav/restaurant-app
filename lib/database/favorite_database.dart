// lib\database\favorite_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

class FavoriteDatabase {
  static final FavoriteDatabase _instance = FavoriteDatabase._internal();
  factory FavoriteDatabase() => _instance;
  FavoriteDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            pictureId TEXT,
            city TEXT,
            rating REAL,
            address TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert('favorites', {
      'id': restaurant.id,
      'name': restaurant.name,
      'description': restaurant.description,
      'pictureId': restaurant.pictureId,
      'city': restaurant.city,
      'rating': restaurant.rating,
      'address': restaurant.address ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Restaurant(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        pictureId: maps[i]['pictureId'],
        city: maps[i]['city'],
        rating: maps[i]['rating'],
        address: maps[i]['address'],
      );
    });
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}
