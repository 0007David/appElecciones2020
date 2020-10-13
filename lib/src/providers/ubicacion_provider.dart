import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:app_elecciones2020/src/models/ubicacion_model.dart';

class UbicacionProvider {
  final String _url = 'https://appelecciones-8bc9a.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<String> insert(UbicacionModel ubicacion) async {
    final url = '$_url/ubicacion.json'; //?auth=${_prefs.token}

    final resp = await http.post(url, body: ubicacionModelToJson(ubicacion));

    final decodedData = json.decode(resp.body);

    print(decodedData["name"]);

    return decodedData["name"];
  }

  Future<bool> update(UbicacionModel ubicacion) async {
    final url = '$_url/ubicacion/${ubicacion.id}.json'; //?auth=${_prefs.token}

    final resp = await http.put(url, body: ubicacionModelToJson(ubicacion));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<List<UbicacionModel>> all() async {
    final url = '$_url/ubicacion.json'; //?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<UbicacionModel> ubicacions = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, ubicacion) {
      final prodTemp = UbicacionModel.fromJson(ubicacion);
      prodTemp.id = id;
      ubicacions.add(prodTemp);
    });
    // print(Ubicacions[0].id);
    return ubicacions;
  }
}
