// To parse this JSON data, do
//
//     final productoModel = productoModelFromJson(jsonString);

import 'dart:convert';

UsuarioModel usuarioModelFromJson(String str) =>
    UsuarioModel.fromJson(json.decode(str));

String usuarioModelToJson(UsuarioModel data) => json.encode(data.toJson());

class UsuarioModel {
  String id;
  String email;
  String nombre;
  String partidoId;
  String fotoUrl;

  UsuarioModel({
    this.id,
    this.email = "",
    this.nombre = "",
    this.partidoId = "",
    this.fotoUrl,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json["id"],
        email: json["email"],
        nombre: json["nombre"],
        partidoId: json["partidoId"],
        fotoUrl: json["fotoUrl"],
      );
  factory UsuarioModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      UsuarioModel(
        id: id,
        email: json["email"],
        nombre: json["nombre"],
        partidoId: json["partidoId"],
        fotoUrl: json["fotoUrl"],
      );

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "email": email,
        "nombre": nombre,
        "partidoId": partidoId,
        "fotoUrl": fotoUrl,
      };
}
