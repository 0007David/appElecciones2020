import 'dart:convert';

ConteoModel conteoModelFromJson(String str) =>
    ConteoModel.fromJson(json.decode(str));

String conteoModelToJson(ConteoModel data) => json.encode(data.toJson());

class ConteoModel {
  String id;
  String actaId;
  String partidoId;
  int nroVoto;
  String tipo;
  String logoPartido;

  ConteoModel(
      {this.id,
      this.actaId = "",
      this.partidoId,
      this.nroVoto = 0,
      this.tipo = "",
      this.logoPartido});

  factory ConteoModel.fromJson(Map<String, dynamic> json) => ConteoModel(
        id: json["id"],
        actaId: json["actaId"],
        partidoId: json["partidoId"],
        nroVoto: json["nroVoto"],
        tipo: json["tipo"],
        logoPartido: json["logoPartido"],
      );
  factory ConteoModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      ConteoModel(
        id: id,
        actaId: json["actaId"],
        partidoId: json["partidoId"],
        nroVoto: json["nroVoto"],
        tipo: json["tipo"],
        logoPartido: json["logoPartido"],
      );

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "actaId": actaId,
        "partidoId": partidoId,
        "nroVoto": nroVoto,
        "tipo": tipo,
        "logoPartido": logoPartido,
      };
}
