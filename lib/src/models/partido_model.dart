import 'dart:convert';

PartidoModel partidoModelFromJson(String str) =>
    PartidoModel.fromJson(json.decode(str));

String partidoModelToJson(PartidoModel data) => json.encode(data.toJson());

class PartidoModel {
  String id;
  String nombre;
  String nombreCompleto;
  String ideologia;
  String fotoUrl;

  PartidoModel(
      {this.id,
      this.nombre = "",
      this.nombreCompleto = "",
      this.ideologia = "",
      this.fotoUrl});

  factory PartidoModel.fromJson(Map<String, dynamic> json) => PartidoModel(
        id: json["id"],
        nombre: json["nombre"],
        nombreCompleto: json["nombreCompleto"],
        ideologia: json["ideologia"],
        fotoUrl: json["fotoUrl"],
      );
  factory PartidoModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      PartidoModel(
        id: id,
        nombre: json["nombre"],
        nombreCompleto: json["nombreCompleto"],
        ideologia: json["ideologia"],
        fotoUrl: json["fotoUrl"],
      );

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "nombre": nombre,
        "ideologia": ideologia,
      };
}
