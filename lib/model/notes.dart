import 'dart:convert';

List<Notes> notesFromJson(String str) =>
    List<Notes>.from(json.decode(str).map((x) => Notes.fromJson(x)));

String notesToJson(List<Notes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Notes {
  String id;
  String title;
  String body;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;

  Notes({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
