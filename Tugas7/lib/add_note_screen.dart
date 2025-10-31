import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        title: titleController.text,
        content: contentController.text,
        createdAt: DateTime.now(),
      );
      await dbHelper.insertNote(newNote);
      Navigator.pop(context); // kembali ke home setelah disimpan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Catatan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Isi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveNote, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}