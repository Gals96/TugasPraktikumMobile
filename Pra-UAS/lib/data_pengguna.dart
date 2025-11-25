import 'dart:convert';
import 'package:http/http.dart' as http;

class DataPengguna {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data pengguna');
    }
  }
}
