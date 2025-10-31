import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';

class DeleteNoteScreen extends StatefulWidget {
  const DeleteNoteScreen({super.key});

  @override
  State<DeleteNoteScreen> createState() => _DeleteNoteScreenState();
}

class _DeleteNoteScreenState extends State<DeleteNoteScreen> {
  final dbHelper = DatabaseHelper();
  Note? note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    note = ModalRoute.of(context)!.settings.arguments as Note?;
  }

  Future<void> _deleteNote() async {
    if (note != null) {
      await dbHelper.deleteNote(note!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hapus Catatan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Yakin ingin menghapus catatan ini?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Text("Judul:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(note?.title ?? "-", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text("Isi Catatan:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(note?.content ?? "-", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _deleteNote,
                  child: const Text("Hapus"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
