import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_takingapp/sqflite/sql_functions.dart';

class NoteTakingApp extends StatefulWidget {
  const NoteTakingApp({super.key});

  @override
  State<NoteTakingApp> createState() => _NoteTakingAppState();
}

class _NoteTakingAppState extends State<NoteTakingApp> {
  List<Map<String, dynamic>> Notes = [];
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        backgroundColor: Colors.greenAccent,
      ),
      body: isLoading
      ?Text("Add new note",
      style: GoogleFonts.actor(fontSize: 25),)
        : ListView.builder(
    itemCount: Notes.length,
    itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
            backgroundColor:
            Colors.primaries[index % Colors.primaries.length],
              child: const Icon(Icons.date_range_sharp),
          ),
            title: Text(Notes[index]['ndate']),
            subtitle: Text(Notes[index]['nnotes']),            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () => showSheet(Notes[index]['id']),
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () =>
                        deleteNotes(Notes[index]['id']),
                    icon: const Icon(Icons.delete))
              ],
            ),
          ),
        );
    }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSheet(null),
        child: const Icon(Icons.note_add),
      ),
    );
  }

  final date_controller = TextEditingController();
  final notes_controller = TextEditingController();
  void showSheet(int? id) {
    if (id != null) {
      final existingnote =
      Notes.firstWhere((element) => element['id'] == id);
      date_controller.text = existingnote['ndate'];
      notes_controller.text = existingnote['nnotes'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextField(
                    controller: date_controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Date",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: notes_controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Notes",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (id == null) {
                        createNote(
                            date_controller.text, notes_controller.text);
                      }
                      if (id != null) {
                        updateNote(id);
                      }
                      date_controller.text = "";
                      notes_controller.text = "";
                    },
                    child:
                    Text(id == null ? "Create Note" : "Update Note"))
              ],
            ),
          );
        });
  }

  Future<void> createNote(String date, String notes) async {
    await SQL_Functions.addnewnotes(date, notes);
    readNotes_and_refresh_Ui();
  }

  @override
  void initState() {
    super.initState();
    readNotes_and_refresh_Ui();
  }

  Future<void> readNotes_and_refresh_Ui() async {
    final mynotes = await SQL_Functions.readNotes();
    setState(() {
      Notes = mynotes;
      isLoading = false;
    });
  }

  Future<void> updateNote(int id) async {
    await SQL_Functions.updateNote(
        id, date_controller.text, notes_controller.text);
    readNotes_and_refresh_Ui(); //to update the list after editing
  }

  Future<void> deleteNotes(int id) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Notes?'),
        content: const Text('Do you want to delete the Note!!!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await SQL_Functions.removeNote(id);
              readNotes_and_refresh_Ui();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully Deleted')));
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
