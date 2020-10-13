import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:app_elecciones2020/src/models/conteo_model.dart';

class ConteoProvider {
  final String _url = 'https://appelecciones-8bc9a.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<String> insert(ConteoModel conteo) async {
    final url = '$_url/conteos.json'; //?auth=${_prefs.token}

    final resp = await http.post(url, body: conteoModelToJson(conteo));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return decodedData["name"];
  }

  Future<bool> update(ConteoModel conteo) async {
    final url = '$_url/conteos/${conteo.id}.json'; //?auth=${_prefs.token}

    final resp = await http.put(url, body: conteoModelToJson(conteo));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<List<ConteoModel>> all() async {
    final url = '$_url/conteos.json'; //?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<ConteoModel> conteos = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, conteo) {
      final prodTemp = ConteoModel.fromJson(conteo);
      prodTemp.id = id;
      conteos.add(prodTemp);
    });
    print(conteos.toString());
    return conteos;
  }
}
