import 'dart:convert';

UbicacionModel ubicacionModelFromJson(String str) =>
    UbicacionModel.fromJson(json.decode(str));

String ubicacionModelToJson(UbicacionModel data) => json.encode(data.toJson());

class UbicacionModel {
  String id;
  String departamento;
  String provincia;
  String localidad;
  String municipio;
  String recinto;

  UbicacionModel({
    this.id,
    this.departamento = "",
    this.provincia = "",
    this.municipio = "",
    this.localidad = "",
    this.recinto,
  });

  factory UbicacionModel.fromJson(Map<String, dynamic> json) => UbicacionModel(
        id: json["id"],
        departamento: json["departamento"],
        provincia: json["provincia"],
        municipio: json["municipio"],
        localidad: json["localidad"],
        recinto: json["recinto"],
      );
  factory UbicacionModel.fromJsonWithId(Map<String, dynamic> json, String id) =>
      UbicacionModel(
        id: id,
        departamento: json["departamento"],
        provincia: json["provincia"],
        municipio: json["municipio"],
        localidad: json["localidad"],
        recinto: json["recinto"],
      );

  void setAtrr(int atrr, dynamic value) {
    switch (atrr) {
      case 0:
        this.departamento = value;
        break;
      case 1:
        this.provincia = value;
        break;
      case 2:
        this.municipio = value;
        break;
      case 3:
        this.localidad = value;
        break;
      case 4:
        this.recinto = value;
        break;
    }
  }

  String toString() {
    return '\n' +
        'Depatamento: ' +
        this.departamento +
        '\n' +
        'Provincia: ' +
        this.provincia +
        '\n' +
        'Municipio: ' +
        this.municipio +
        '\n' +
        'Localidad: ' +
        this.localidad +
        '\n' +
        'Reciento: ' +
        this.recinto +
        '\n';
  }

  Map<String, dynamic> toJson() => {
        // "id"         : id,
        "departamento": departamento,
        "provincia": provincia,
        "municipio": municipio,
        "localidad": localidad,
        "recinto": recinto,
      };
}
