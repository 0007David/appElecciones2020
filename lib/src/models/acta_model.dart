import 'dart:convert';

ActaModel actaModelFromJson(String str) => ActaModel.fromJson(json.decode(str));

String actaModelToJson(ActaModel data) => json.encode(data.toJson());

class ActaModel {
  String id;
  String codigoVerificacion;
  String codigoBarra;
  String tipo;
  String mesaId;
  String fotoUrl;

  ActaModel({
    this.id,
    this.codigoVerificacion = "",
    this.codigoBarra = "",
    this.mesaId,
    this.fotoUrl,
    this.tipo = "",
  });

  factory ActaModel.fromJson(Map<String, dynamic> json) => ActaModel(
        id: json["id"],
        codigoVerificacion: json["codigoVerificacion"],
        codigoBarra: json["codigoBarra"],
        mesaId: json["mesaId"],
        fotoUrl: json["fotoUrl"],
        tipo: json["tipo"],
      );
  factory ActaModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      ActaModel(
        id: id,
        codigoVerificacion: json["codigoVerificacion"],
        codigoBarra: json["codigoBarra"],
        mesaId: json["mesaId"],
        fotoUrl: json["fotoUrl"],
        tipo: json["tipo"],
      );

  void setAtrr(int atrr, dynamic value) {
    switch (atrr) {
      case 0:
        this.codigoBarra = value;
        break;
      case 1:
        this.codigoVerificacion = value;
        break;
      case 2:
        this.tipo = value;
        break;
    }
  }

  String toString() {
    return 'Acta Electoral 2020 \n' +
        'Codigo barra: ' +
        this.codigoBarra +
        '\n' +
        'Codigo Verificacion: ' +
        this.codigoVerificacion +
        '\n' +
        'Tipo: ' +
        this.tipo +
        '\n';
  }

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "codigoVerificacion": codigoVerificacion,
        "codigoBarra": codigoBarra,
        "mesaId": mesaId,
        "fotoUrl": fotoUrl,
        "tipo": tipo,
      };
}
