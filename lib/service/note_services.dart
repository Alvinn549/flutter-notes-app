import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notes_app/model/notes.dart';

class NoteService {
  final String _baseUrl = 'https://d678-202-67-40-15.ngrok-free.app';

  Future getAllNotes() async {
    final String apiUrl = '$_baseUrl/notes';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // print(response.body);
        return notesFromJson(response.body.toString());
      } else {
        throw Exception("Failed to load data Notes !");
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future postNote(String title, String body, String tags) async {
    final String apiUrl = '$_baseUrl/notes';

    List<String> tagsList =
        tags.split(',').map((String item) => item.trim()).toList();

    var note = {"title": title, "body": body, "tags": tagsList};
    // print(note);
    // print(jsonEncode(note));
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note),
      );

      if (response.statusCode == 201) {
        // print('success: ${response.statusCode}');
        // print(response.body);
        return true;
      } else {
        // print('Error: ${response.statusCode}');
        // print('Response Body: ${response.body}');
        return false;
      }
    } catch (error) {
      // print('Error: $error');
      throw Exception('Failed to load data Notes!');
    }
  }

  Future getNoteById(String id) async {
    final String apiUrl = '$_baseUrl/notes/$id';
    // print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // print(response.body.toString());
        return response.body;
      } else {
        // print('Error: ${response.statusCode}');
        // print('Response Body: ${response.body}');
        // print('Failed to load data Notes!');
        throw Exception("Failed to load data Notes !");
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future putNote(String id, String title, String body, String tags) async {
    final String apiUrl = '$_baseUrl/notes/$id';

    List<String> tagsList =
        tags.split(',').map((String item) => item.trim()).toList();

    var note = {"title": title, "body": body, "tags": tagsList};
    // print(note);
    // print(jsonEncode(note));
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note),
      );

      if (response.statusCode == 200) {
        // print('success: ${response.statusCode}');
        // print(response.body);
        return true;
      } else {
        // print('Error: ${response.statusCode}');
        // print('Response Body: ${response.body}');
        // print('Failed to load data Notes!');
        return false;
      }
    } catch (error) {
      // print('Error: $error');
      throw Exception('Failed to load data Notes!');
    }
  }

  Future deleteNoteById(String id) async {
    final String apiUrl = '$_baseUrl/notes/$id';
    // print(apiUrl);
    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // print(response.body.toString());
        return true;
      } else {
        // print('Error: ${response.statusCode}');
        // print('Response Body: ${response.body}');
        // print('Failed to load data Notes!');
        return false;
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
