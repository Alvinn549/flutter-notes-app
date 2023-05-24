import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes_app/service/note_services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DetailNote extends StatefulWidget {
  final String id;

  const DetailNote({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<DetailNote> createState() => _DetailNoteState();
}

class _DetailNoteState extends State<DetailNote> {
  late Future _getNoteById;
  late Map<String, dynamic> note = {};

  final _titleController = TextEditingController();
  final _bodyEditingController = TextEditingController();
  final _tagsEditingController = TextEditingController();

  int count = 0;

  getNoteById() {
    _getNoteById = NoteService().getNoteById(widget.id);
    _getNoteById.then((value) {
      setState(() {
        note = json.decode(value);
        _titleController.text = note['title'].toString();
        _bodyEditingController.text = note['body'].toString();
        _tagsEditingController.text = note['tags'].join(", ");
      });
    });
  }

  void editNote() {
    NoteService()
        .putNote(
      widget.id,
      _titleController.text,
      _bodyEditingController.text,
      _tagsEditingController.text,
    )
        .then((value) {
      setState(() {
        if (value) {
          Alert(
            context: context,
            type: AlertType.success,
            style: const AlertStyle(
              animationType: AnimationType.fromTop,
              isCloseButton: false,
              isOverlayTapDismiss: false,
              animationDuration: Duration(milliseconds: 350),
              titleStyle: TextStyle(
                color: Colors.green,
              ),
            ),
            title: "Succcess",
            desc: "Catatan berhasil disimpan !",
            buttons: [
              DialogButton(
                onPressed: () {
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                },
                width: 120,
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ],
          ).show();
        } else {
          Alert(
            context: context,
            type: AlertType.error,
            style: const AlertStyle(
              animationType: AnimationType.fromTop,
              isCloseButton: false,
              isOverlayTapDismiss: false,
              animationDuration: Duration(milliseconds: 350),
              titleStyle: TextStyle(
                color: Colors.red,
              ),
            ),
            title: "Fail",
            desc: "Catatan gagal disimpaan !",
            buttons: [
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                width: 120,
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ],
          ).show();
        }
      });
    });
  }

  @override
  void initState() {
    getNoteById();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Note'),
      ),
      body: note.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            note['title'].toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            note['body'].toString(),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            spacing: 3,
                            children: (note['tags'] as List<dynamic>)
                                .map(
                                  (tag) => SizedBox(
                                    height: 23,
                                    child: Chip(
                                      label: SizedBox(
                                        height: 23,
                                        child: Text(
                                          tag.toString(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Dibuat pada : ${note['createdAt']}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editNoteDialog(context);
        },
        tooltip: 'Edit Notes',
        child: const Icon(Icons.edit),
      ), // Conditionally render Text or CircularProgressIndicator
    );
  }

  Future<dynamic> editNoteDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Edit Catatan", textAlign: TextAlign.center),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey, // Assign the GlobalKey to the Form
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Judul",
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Judul harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bodyEditingController,
                    decoration: const InputDecoration(
                      labelText: "Isi",
                    ),
                    maxLines: null,
                    // keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Body harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _tagsEditingController,
                    decoration: const InputDecoration(
                      labelText: "Tags",
                      hintText: "Pisahkan tag dengan tanda koma (,)",
                      hintStyle: TextStyle(fontSize: 11),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Tags harus diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                child: const Text("Submit"),
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    editNote();
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
