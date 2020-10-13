import 'dart:convert';
import 'package:app_elecciones2020/src/models/usuario_model.dart';
import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';
import 'package:http/http.dart' as http;

class UsuarioProvider {
  final String _url = 'https://identitytoolkit.googleapis.com/v1/accounts:';

  final String _apiKey = 'ApiKey';
  final _prefs = new PreferenciasUsuario();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final resp = await http.post('${_url}signInWithPassword?key=$_apiKey',
        body: json.encode(authData));

    Map<String, dynamic> decodedResp = json.decode(resp.body);

    print(decodedResp);

    if (decodedResp.containsKey('idToken')) {
      _prefs.token = decodedResp['idToken'];

      return {'ok': true, 'token': decodedResp['idToken']};
    } else {
      return {'ok': false, 'mensaje': decodedResp['error']['message']};
    }
  }

  Future<Map<String, dynamic>> nuevoUsuario(
      String email, String password) async {
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final resp = await http.post('${_url}signUp?key=$_apiKey',
        body: json.encode(authData));

    Map<String, dynamic> decodedResp = json.decode(resp.body);

    print(decodedResp);

    if (decodedResp.containsKey('idToken')) {
      _prefs.token = decodedResp['idToken'];

      return {'ok': true, 'token': decodedResp['idToken']};
    } else {
      return {'ok': false, 'mensaje': decodedResp['error']['message']};
    }
  }

  Future<bool> crearUsuario(UsuarioModel usuario) async {
    final url = '$_url/usuarios.json?auth=${_prefs.token}';

    final resp = await http.post(url, body: usuarioModelToJson(usuario));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<bool> editarUsuario(UsuarioModel usuario) async {
    final url = '$_url/usuarios/${usuario.id}.json?auth=${_prefs.token}';

    final resp = await http.put(url, body: usuarioModelToJson(usuario));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }
}
