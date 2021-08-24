import 'dart:convert';

class Position {
  int id;
  int? parentId;
  String position;
  int level;
  int orgUnit;

  Position(
      {required this.id,
      required this.parentId,
      required this.position,
      required this.level,
      required this.orgUnit});

  factory Position.fromJson(Map<String, dynamic> map) {
    return Position(
        id: map['id'],
        parentId: map['parent_id'],
        position: map['position'],
        level: map['level'],
        orgUnit: map['org_unit']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "parent_id": parentId,
      "position": position,
      "level": level,
      "org_unit": orgUnit
    };
  }
}

String positionToJson(Position data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

Position positionFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return Position.fromJson(data);
}
