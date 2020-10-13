import 'dart:convert';

MesaModel mesaModelFromJson(String str) => MesaModel.fromJson(json.decode(str));

String mesaModelToJson(MesaModel data) => json.encode(data.toJson());

class MesaModel {
  String id;
  String nro;
  String codigo;
  String horaInicio;
  String horaFin;
  String circunscripcion;
  int nroTototalVotantes;
  String ubicacionId;

  MesaModel({
    this.id,
    this.nro = "",
    this.codigo = "",
    this.horaFin = "16:00",
    this.horaInicio = "08:00",
    this.circunscripcion = "",
    this.nroTototalVotantes = 0,
    this.ubicacionId = "",
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
        id: json["id"],
        nro: json["nro"],
        codigo: json["codigo"],
        horaFin: json["horaFin"],
        horaInicio: json["horaInicio"],
        circunscripcion: json["circunscripcion"],
        nroTototalVotantes: json["nroTototalVotantes"],
        ubicacionId: json["ubicacionId"],
      );
  factory MesaModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      MesaModel(
        id: id,
        nro: json["nro"],
        codigo: json["codigo"],
        horaFin: json["horaFin"],
        horaInicio: json["horaInicio"],
        circunscripcion: json["circunscripcion"],
        nroTototalVotantes: json["nroTototalVotantes"],
        ubicacionId: json["ubicacionId"],
      );

  void setAtrr(int atrr, dynamic value) {
    switch (atrr) {
      case 0:
        this.codigo = value;
        break;
      case 1:
        this.nro = value;
        break;
      case 2:
        this.circunscripcion = value;
        break;
      case 3:
        this.nroTototalVotantes = value;
        break;
    }
  }

  String toString() {
    return 'Codigo Mesa: ' +
        this.codigo +
        '\n' +
        'Nro Mesa: ' +
        this.nro +
        '\n' +
        'Hora Inicio: ' +
        this.horaInicio +
        ' Hora Fin: ' +
        this.horaFin +
        '\n';
  }

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "nro": nro,
        "codigo": codigo,
        "horaFin": horaFin,
        "horaInicio": horaInicio,
        "nroTototalVotantes": nroTototalVotantes,
        "ubicacionId": ubicacionId,
      };
}
