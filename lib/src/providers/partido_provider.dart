import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:app_elecciones2020/src/models/partido_model.dart';

class PartidoProvider {
  final String _url = 'https://appelecciones-8bc9a.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<List<PartidoModel>> all() async {
    final url = '$_url/partidos.json'; // ?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<PartidoModel> partidos = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, partido) {
      final prodTemp = partidoModelFromJson(partido);
      prodTemp.id = id;
      partidos.add(prodTemp);
    });
    // print(Partidos[0].id);
    return partidos;
  }

  Future<PartidoModel> getPartido(String partidoId) async {
    final url = '$_url/partidos/${partidoId}.json'; //?auth=${_prefs.token}

    final resp = await http.get(url);

    final decodedData = json.decode(resp.body);

    // print(decodedData);
    final prodTemp = PartidoModel.fromJson(decodedData);
    prodTemp.id = partidoId;

    return prodTemp;
  }
}
