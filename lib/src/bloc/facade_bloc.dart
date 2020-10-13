import 'dart:io';

import 'package:app_elecciones2020/src/models/conteo_model.dart';
import 'package:app_elecciones2020/src/models/jurado_model.dart';
import 'package:rxdart/rxdart.dart';

import 'package:app_elecciones2020/src/providers/facade_provider.dart';
export 'package:app_elecciones2020/src/providers/facade_provider.dart';

class FacadeBloc {
  final _actasController = new BehaviorSubject<List<ActaModel>>();
  final _cargandoController = new BehaviorSubject<bool>();

  final _facadeProvider = new FacadeProvider();

  Stream<List<ActaModel>> get actasStream => _actasController.stream;
  Stream<bool> get cargando => _cargandoController.stream;

  void cargarActas() async {
    final actas = await _facadeProvider.getActas();
    _actasController.sink.add(actas);
  }

  Future<String> insertarActa(ActaModel acta) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.insertActa(acta);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<ActaModel> getActa(ActaModel acta) async {
    _cargandoController.sink.add(true);
    final salida = await _facadeProvider.getActa(acta);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> insertarMesa(MesaModel mesa) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.insertMesa(mesa);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> insertarJurado(JuradoModel jurado) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.insertJurado(jurado);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> getJurados(String mesaId) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.getJurados(mesaId);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<MesaModel> getMesa(String idMesa) async {
    _cargandoController.sink.add(true);
    final salida = await _facadeProvider.getMesa(idMesa);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> insertarUbicacion(UbicacionModel ubicacion) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.insertUbiacion(ubicacion);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<UbicacionModel> getUbicacion(String idUbi) async {
    _cargandoController.sink.add(true);
    final salida = await _facadeProvider.getUbicacion(idUbi);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> insertarConteo(ConteoModel conteo) async {
    _cargandoController.sink.add(true);
    String salida = await _facadeProvider.insertConteo(conteo);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<List<ConteoModel>> getConteoActa(String idActa) async {
    _cargandoController.sink.add(true);
    final salida = await _facadeProvider.getConteoActa(idActa);
    _cargandoController.sink.add(false);
    return salida;
  }

  Future<String> subirFoto(File foto) async {
    _cargandoController.sink.add(true);
    final fotoUrl = await _facadeProvider.subirImagen(foto);
    _cargandoController.sink.add(false);
    return fotoUrl;
  }

  dispose() {
    _actasController?.close();
    _cargandoController?.close();
  }
}
