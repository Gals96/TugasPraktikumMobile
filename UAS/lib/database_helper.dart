import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

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
    String path = join(await getDatabasesPath(), 'rentalku_v3.db'); // Versi baru
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel User
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, email TEXT, password TEXT, role TEXT
          )
        ''');

        // Tabel Mobil
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, brand TEXT, price INTEGER, 
            imageUrl TEXT, seatCount INTEGER, transmission TEXT, 
            year TEXT, rating REAL, status TEXT
          )
        ''');

        // Tabel Transaksi
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER, carId INTEGER,
            carName TEXT, carImage TEXT,
            startDate TEXT, endDate TEXT,
            totalPayment INTEGER, status TEXT
          )
        ''');

        // Isi Data Awal Mobil (Seeding) agar tidak kosong
        await db.insert('cars', {
          'name': 'Toyota Yaris (Matic)', 'brand': 'Toyota', 'price': 450000,
          'imageUrl': 'https://img.freepik.com/premium-photo/yellow-hatchback-car-isolated-white-background_1029473-585320.jpg',
          'seatCount': 4, 'transmission': 'Matic', 'year': '2023', 'rating': 4.8, 'status': 'Available'
        });
        await db.insert('cars', {
          'name': 'Toyota Innova', 'brand': 'Toyota', 'price': 600000,
          'imageUrl': 'https://png.pngtree.com/png-vector/20240905/ourmid/pngtree-white-mpv-car-side-view-png-image_13759312.png',
          'seatCount': 7, 'transmission': 'Manual', 'year': '2022', 'rating': 4.7, 'status': 'Available'
        });
      },
    );
  }

  // --- USER AUTH ---
  Future<int> registerUser(String name, String email, String password, String role) async {
    final db = await database;
    var res = await db.query("users", where: "email = ?", whereArgs: [email]);
    if (res.isNotEmpty) return -1;
    return await db.insert('users', {'name': name, 'email': email, 'password': password, 'role': role});
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    var res = await db.query("users", where: "email = ? AND password = ?", whereArgs: [email, password]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // --- FITUR MOBIL (ADMIN & USER) ---
  
  // Ambil semua mobil (bisa difilter nama buat search)
  Future<List<Map<String, dynamic>>> getCars({String? query}) async {
    final db = await database;
    if (query != null && query.isNotEmpty) {
      return await db.query('cars', where: 'name LIKE ?', whereArgs: ['%$query%']);
    }
    return await db.query('cars');
  }

  // Tambah Mobil (Admin)
  Future<int> addCar(Map<String, dynamic> carData) async {
    final db = await database;
    return await db.insert('cars', carData);
  }

  // --- FITUR TRANSAKSI (BOOKING) ---

  // Buat Booking Baru (User)
  Future<int> createTransaction(Map<String, dynamic> trxData) async {
    final db = await database;
    return await db.insert('transactions', trxData);
  }

  // Ambil Transaksi (Admin History)
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: "id DESC");
  }

  // Update Status Transaksi (Admin Konfirmasi Selesai)
  Future<int> updateTransactionStatus(int id, String status) async {
    final db = await database;
    return await db.update('transactions', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }
}

// Helper Format Rupiah
String formatRupiah(int number) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);