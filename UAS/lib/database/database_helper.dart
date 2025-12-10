import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rentalku_v3.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, email TEXT, password TEXT, role TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, brand TEXT, price INTEGER, imageUrl TEXT,
            seatCount INTEGER, transmission TEXT, year TEXT, status TEXT,
            rating REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER, carId INTEGER, carName TEXT, carImage TEXT,
            startDate TEXT, endDate TEXT, totalPayment INTEGER, status TEXT
          )
        ''');

        await db.insert('cars', {
          'name': 'Toyota Yaris', 'brand': 'Toyota', 'price': 450000,
          'imageUrl': 'https://img.freepik.com/premium-photo/yellow-hatchback-car-isolated-white-background_1029473-585320.jpg',
          'seatCount': 4, 'transmission': 'Matic', 'year': '2023', 'status': 'Available',
          'rating': 4.5,
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE cars ADD COLUMN rating REAL DEFAULT 0.0');
        }
      },
    );
  }

  //user lohgin dan register
  Future<int> registerUser(String name, String email, String password, String role) async {
    final db = await database;
    var check = await db.query("users", where: "email = ?", whereArgs: [email]);
    if (check.isNotEmpty) return -1;
    return await db.insert('users', {'name': name, 'email': email, 'password': password, 'role': role});
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    var res = await db.query("users", where: "email = ? AND password = ?", whereArgs: [email, password]);
    return res.isNotEmpty ? res.first : null;
  }

  //mobil
  Future<List<Map<String, dynamic>>> getCars({String? query}) async {
    final db = await database;
    if (query != null && query.isNotEmpty) {
      return await db.query('cars', where: 'name LIKE ?', whereArgs: ['%$query%']);
    }
    return await db.query('cars');
  }

  Future<int> addCar(Map<String, dynamic> carData) async => await (await database).insert('cars', carData);
  Future<int> updateCar(int id, Map<String, dynamic> carData) async => await (await database).update('cars', carData, where: 'id = ?', whereArgs: [id]);
  Future<int> deleteCar(int id) async => await (await database).delete('cars', where: 'id = ?', whereArgs: [id]);

  //transaksi
  Future<int> createTransaction(Map<String, dynamic> trxData) async => await (await database).insert('transactions', trxData);
  
  Future<List<Map<String, dynamic>>> getAllTransactionsWithUsers() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.*, u.name AS userName 
      FROM transactions t 
      LEFT JOIN users u ON t.userId = u.id 
      ORDER BY t.id DESC
    ''');
  }

  Future<int> updateTransactionStatus(int id, String status) async => await (await database).update('transactions', {'status': status}, where: 'id = ?', whereArgs: [id]);
  Future<int> deleteTransaction(int id) async => await (await database).delete('transactions', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getBookingHistoryByUser(int userId) async {
    return await (await database).query('transactions', where: 'userId = ?', whereArgs: [userId], orderBy: 'id DESC');
  }
}