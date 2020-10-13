import 'package:app_elecciones2020/src/models/jurado_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:app_elecciones2020/src/models/mesa_model.dart';

class MesaProvider {
  final String _url = 'https://appelecciones-8bc9a.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<String> insert(MesaModel mesa) async {
    final url = '$_url/mesas.json'; // ?auth=${_prefs.token}

    final resp = await http.post(url, body: mesaModelToJson(mesa));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return decodedData["name"];
  }

  Future<bool> update(MesaModel mesa) async {
    final url = '$_url/mesas/${mesa.id}.json'; // ?auth=${_prefs.token}

    final resp = await http.put(url, body: mesaModelToJson(mesa));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<List<MesaModel>> all() async {
    final url = '$_url/mesas.json'; // ?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<MesaModel> mesas = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, mesa) {
      final prodTemp = MesaModel.fromJson(mesa);
      prodTemp.id = id;
      mesas.add(prodTemp);
    });
    // print(mesas[0].id);
    return mesas;
  }

  /**
   * Metodos de Jurado 
   */
  Future<String> insertJurado(JuradoModel jurado) async {
    final url = '$_url/jurados.json'; // ?auth=${_prefs.token}

    final resp = await http.post(url, body: juradoModelToJson(jurado));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return decodedData["name"];
  }

  Future<List<JuradoModel>> allJurado(String mesaId) async {
    final url = '$_url/jurados.json'; // ?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<JuradoModel> jurados = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, mesa) {
      final prodTemp = JuradoModel.fromJson(mesa);
      prodTemp.id = id;
      if (prodTemp.mesaId == mesaId) {
        jurados.add(prodTemp);
      }
    });
    // print(mesas[0].id);
    return jurados;
  }
}
