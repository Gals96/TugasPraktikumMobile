import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Getter database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Init Database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rentalku_v3.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // ---------- TABLE USERS ----------
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, 
            email TEXT, 
            password TEXT, 
            role TEXT
          )
        ''');

        // ---------- TABLE CARS ----------
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, 
            brand TEXT, 
            price INTEGER,
            imageUrl TEXT,
            seatCount INTEGER, 
            transmission TEXT, 
            year TEXT, 
            rating REAL, 
            status TEXT
          )
        ''');

        // ---------- TABLE TRANSACTIONS ----------
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            carId INTEGER,
            carName TEXT,
            carImage TEXT,
            startDate TEXT,
            endDate TEXT,
            totalPayment INTEGER,
            status TEXT
          )
        ''');

        // ---------- SEEDING MOBIL ----------
        await db.insert('cars', {
          'name': 'Toyota Yaris (Matic)',
          'brand': 'Toyota',
          'price': 450000,
          'imageUrl': 'https://img.freepik.com/premium-photo/yellow-hatchback-car-isolated-white-background_1029473-585320.jpg',
          'seatCount': 4,
          'transmission': 'Matic',
          'year': '2023',
          'rating': 4.8,
          'status': 'Available'
        });

        await db.insert('cars', {
          'name': 'Toyota Innova',
          'brand': 'Toyota',
          'price': 600000,
          'imageUrl': 'https://png.pngtree.com/png-vector/20240905/ourmid/pngtree-white-mpv-car-side-view-png-image_13759312.png',
          'seatCount': 7,
          'transmission': 'Manual',
          'year': '2022',
          'rating': 4.7,
          'status': 'Available'
        });
      },
    );
  }

  // ============================
  //        USER AUTH
  // ============================

  Future<int> registerUser(String name, String email, String password, String role) async {
    final db = await database;

    var check = await db.query("users", where: "email = ?", whereArgs: [email]);
    if (check.isNotEmpty) return -1;

    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role
    });
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;

    var res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password]
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  // ============================
  //        CARS FEATURE
  // ============================

  Future<List<Map<String, dynamic>>> getCars({String? query}) async {
    final db = await database;

    if (query != null && query.isNotEmpty) {
      return await db.query(
        'cars',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
    }

    return await db.query('cars');
  }

  Future<int> addCar(Map<String, dynamic> carData) async {
    final db = await database;
    return await db.insert('cars', carData);
  }

  // ============================
  //     TRANSACTIONS FEATURE
  // ============================

  // Create new booking (user)
  Future<int> createTransaction(Map<String, dynamic> trxData) async {
    final db = await database;
    return await db.insert('transactions', trxData);
  }

  // Admin — all transactions (raw)
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: "id DESC");
  }

  // Admin — update status transaksi
  Future<int> updateTransactionStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'transactions',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================
  //     USER HISTORY (PELANGGAN)
  // ============================

  Future<List<Map<String, dynamic>>> getBookingHistoryByUser(int userId) async {
    final db = await database;

    return await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // ============================
  //    ADMIN — JOIN WITH USERS
  // ============================

  Future<List<Map<String, dynamic>>> getAllTransactionsWithUsers() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT t.*, 
             u.name AS userName,
             u.email AS userEmail,
             u.id AS userId
      FROM transactions t
      LEFT JOIN users u ON t.userId = u.id
      ORDER BY t.id DESC
    ''');
  }

  // ============================
  //    ADMIN — TOTAL PENDAPATAN
  // ============================

  Future<int> getTotalIncome() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(totalPayment) as total
      FROM transactions
      WHERE status = 'Selesai'
    ''');

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }

    return 0;
  }
}

// Format Rupiah
String formatRupiah(int number) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(number);
}
