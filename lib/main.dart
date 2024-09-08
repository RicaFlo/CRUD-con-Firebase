import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final CollectionReference _notesCollection = FirebaseFirestore.instance.collection('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas CRUD'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Escribe una nota',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: Text('Agregar Nota'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notesCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    var note = notes[index];
                    return ListTile(
                      title: Text(note['content']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _updateNoteDialog(note),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    if (_noteController.text.isNotEmpty) {
      await _notesCollection.add({'content': _noteController.text});
      _noteController.clear();
    }
  }

  Future<void> _updateNoteDialog(DocumentSnapshot note) async {
    _noteController.text = note['content'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Nota'),
        content: TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: 'Editar nota',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateNote(note.id);
              Navigator.of(context).pop();
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNote(String noteId) async {
    if (_noteController.text.isNotEmpty) {
      await _notesCollection.doc(noteId).update({'content': _noteController.text});
      _noteController.clear();
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }
}


