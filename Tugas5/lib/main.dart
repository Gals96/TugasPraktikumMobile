import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Berita',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NewsListPage(),
    );
  }
}

class NewsListPage extends StatelessWidget {
  final List<Map<String, String>> berita = [
    {
      "judul": "Khabib Nurmagomedov",
      "deskripsi": "Legend of Lightweight",
      "gambar": "https://akcdn.detik.net.id/visual/2020/10/27/khabib-nurmagomedov-3_169.jpeg?w=650&q=90",
    },
    {
      "judul": "Khamzat Chimaef",
      "deskripsi": "New Middleweight Champion!",
      "gambar": "https://pict.sindonews.net/webp/732/pena/news/2025/02/11/50/1528223/biodata-dan-agama-khamzat-chimaev-petarung-ufc-yang-tak-terkalahkan-bpf.webp",
    },
    {
      "judul": "GSP",
      "deskripsi": "Ex double champ comeback?",
      "gambar": "https://variety.com/wp-content/uploads/2021/02/Georges-St-Pierre.jpg?w=1000&h=563&crop=1",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Artikel Hgaf")),
      body: ListView.builder(
        itemCount: berita.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              berita[index]["gambar"]!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(berita[index]["judul"]!),
            subtitle: Text(berita[index]["deskripsi"]!),
            trailing: Icon(Icons.bookmark_border),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Mengalihkan ke halaman berita"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
