// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/model/notes.dart';
import 'package:notes_app/service/note_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notes_app/view/detail_note.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future _getData;
  List<Notes> notes = [];

  getNotes() {
    _getData = NoteService().getAllNotes();

    _getData.then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  final _titleController = TextEditingController();
  final _bodyEditingController = TextEditingController();
  final _tagsEditingController = TextEditingController();

  void createNote() {
    NoteService()
        .postNote(
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
            title: "Success",
            desc: "Catatan berhasil disimpan!",
            buttons: [
              DialogButton(
                onPressed: () {
                  getNotes();
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
            desc: "Catatan gagal disimpan!",
            buttons: [
              DialogButton(
                onPressed: () {
                  getNotes();
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
    clearForm();
  }

  void clearForm() {
    _titleController.clear();
    _bodyEditingController.clear();
    _tagsEditingController.clear();
  }

  void onGoBack(dynamic value) {
    getNotes();
    setState(() {});
  }

  bool isLoading = true;
  void startTimer() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        isLoading = false;
        timer.cancel();
      });
    });
  }

  @override
  void initState() {
    getNotes();
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        centerTitle: true,
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () {
            _getData = NoteService().getAllNotes();
            return _getData.then((value) {
              setState(() {
                notes = value;
              });
            });
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return DetailNote(
                              id: notes[index].id,
                            );
                          }),
                        ).then(onGoBack);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Slidable(
                            key: Key(notes[index].toString()),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  onPressed: (_) async {
                                    bool? confirm =
                                        await confirmDelete(context);
                                    if (confirm != null && confirm) {
                                      if (await NoteService().deleteNoteById(
                                          notes[index].id.toString())) {
                                        setState(() {
                                          notes.removeAt(index);
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Catatan Berhasil Dihapus'),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Catatan Berhasil Dihapus'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ListTile(
                                title: Text(
                                  notes[index].title,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      notes[index].body,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 3,
                                      children: notes[index]
                                          .tags
                                          .map(
                                            (tag) => SizedBox(
                                              height: 23,
                                              child: Chip(
                                                label: SizedBox(
                                                  height: 23,
                                                  child: Text(
                                                    tag,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNotesDialog(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> addNotesDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Tambah Catatan", textAlign: TextAlign.center),
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
                    createNote();
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

  Future<bool?> confirmDelete(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          icon: const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 40,
          ),
          title: const Text('Warning', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Apakah anda yakin untuk menghapus catatan ini?',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
