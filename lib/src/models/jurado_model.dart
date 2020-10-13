import 'dart:convert';

JuradoModel juradoModelFromJson(String str) =>
    JuradoModel.fromJson(json.decode(str));

String juradoModelToJson(JuradoModel data) => json.encode(data.toJson());

class JuradoModel {
  String id;
  String ci;
  String nombre;
  String telefono;
  String mesaId;

  JuradoModel({
    this.id,
    this.ci = "",
    this.nombre = "",
    this.telefono = "",
    this.mesaId,
  });

  factory JuradoModel.fromJson(Map<String, dynamic> json) => JuradoModel(
        id: json["id"],
        ci: json["ci"],
        nombre: json["nombre"],
        telefono: json["telefono"],
        mesaId: json["mesaId"],
      );
  factory JuradoModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      JuradoModel(
        id: id,
        ci: json["ci"],
        nombre: json["nombre"],
        telefono: json["telefono"],
        mesaId: json["mesaId"],
      );

  String toString() {
    return 'CI: ' +
        this.ci +
        '\n' +
        'Nombre: ' +
        this.nombre +
        '\n' +
        'Celular: ' +
        this.telefono +
        '\n';
  }

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "ci": ci,
        "nombre": nombre,
        "telefono": telefono,
        "mesaId": mesaId,
      };
}
