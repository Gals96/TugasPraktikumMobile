import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  late TextEditingController titleController;
  late TextEditingController contentController;

  Note? note;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    note = ModalRoute.of(context)!.settings.arguments as Note?;

    titleController = TextEditingController(text: note?.title ?? "");
    contentController = TextEditingController(text: note?.content ?? "");
  }

  Future<void> _updateNote() async {
    if (_formKey.currentState!.validate() && note != null) {
      final updatedNote = Note(
        id: note!.id,
        title: titleController.text,
        content: contentController.text,
        createdAt: note!.createdAt, 
      );

      await dbHelper.updateNote(updatedNote);
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Catatan")),
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
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Isi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateNote,
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
