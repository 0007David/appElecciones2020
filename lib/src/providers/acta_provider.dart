import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:app_elecciones2020/src/models/acta_model.dart';

class ActaProvider {
  final String _url = 'https://appelecciones-8bc9a.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<String> insert(ActaModel acta) async {
    final url = '$_url/actas.json'; //?auth=${_prefs.token}

    final resp = await http.post(url, body: actaModelToJson(acta));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return decodedData["name"];
  }

  Future<bool> update(ActaModel acta) async {
    final url = '$_url/actas/${acta.id}.json'; //?auth=${_prefs.token}

    final resp = await http.put(url, body: actaModelToJson(acta));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  //https://appelecciones-8bc9a.firebaseio.com/actas/iasuwqudasq.json
  Future<ActaModel> getActa(ActaModel acta) async {
    final List<ActaModel> actas = await this.all();
    ActaModel salida;
    actas.forEach((res) {
      print('res: ' + res.toString());
      if (res.codigoBarra == acta.codigoBarra) {
        salida = res;
      }
      if (res.codigoVerificacion == acta.codigoVerificacion) {
        salida = res;
      }
    });
    return salida;
  }

  Future<List<ActaModel>> all() async {
    final url = '$_url/actas.json'; //?auth=${_prefs.token}

    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<ActaModel> actas = new List();
    if (decodedData == null) return [];
    // Si token expiro
    if (decodedData['error'] != null) return [];

    decodedData.forEach((id, acta) {
      final prodTemp = ActaModel.fromJson(acta);
      prodTemp.id = id;
      actas.add(prodTemp);
    });
    // print(Actas[0].id);
    return actas;
  }

  Future<String> subirImagen(File imagen) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dxfnjrouy/image/upload?upload_preset=t9kmou7m');
    final mimeType = mime(imagen.path).split('/'); // img/jpeg

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', imagen.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');
      print(resp.body);
      return null;
    }
    final respData = json.decode(resp.body);
    print(respData);
    return respData['secure_url'];
  }
}
