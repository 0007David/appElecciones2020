import 'dart:io';

import 'package:app_elecciones2020/src/models/acta_model.dart';
import 'package:app_elecciones2020/src/models/conteo_model.dart';
import 'package:app_elecciones2020/src/models/jurado_model.dart';
import 'package:app_elecciones2020/src/models/mesa_model.dart';
import 'package:app_elecciones2020/src/models/partido_model.dart';
import 'package:app_elecciones2020/src/models/ubicacion_model.dart';
import 'package:app_elecciones2020/src/providers/acta_provider.dart';
import 'package:app_elecciones2020/src/providers/conteo_provider.dart';
import 'package:app_elecciones2020/src/providers/mesa_provider.dart';
import 'package:app_elecciones2020/src/providers/partido_provider.dart';
import 'package:app_elecciones2020/src/providers/ubicacion_provider.dart';
export 'package:app_elecciones2020/src/models/acta_model.dart';
export 'package:app_elecciones2020/src/models/mesa_model.dart';
export 'package:app_elecciones2020/src/models/partido_model.dart';
export 'package:app_elecciones2020/src/models/ubicacion_model.dart';

class FacadeProvider {
  final partidos = {
    'C.C.': 'partido1',
    'FPV': 'partido2',
    'MTS': 'partido3',
    'UCS': 'partido4',
    'MAS-IPSP': 'partido5',
    '21F': 'partido6',
    'PDC': 'partido7',
    'MNR': 'partido8',
    'PAN-BOL': 'partido9',
  };

  /*
   * Metodos de Actas Electorales
   */
  Future<String> insertActa(ActaModel acta) async {
    ActaProvider actaProv = new ActaProvider();
    String salida = await actaProv.insert(acta);
    actaProv = null; // destroy Variable
    return salida;
  }

  Future<bool> actualizarActa(ActaModel acta) async {
    ActaProvider actaProv = new ActaProvider();
    bool salida = await actaProv.update(acta);
    actaProv = null; // destroy Variable
    return salida;
  }

  Future<ActaModel> getActa(ActaModel acta) async {
    ActaProvider actaProv = new ActaProvider();
    ActaModel salida = await actaProv.getActa(acta);
    actaProv = null; // destroy Variable
    return salida;
  }

  Future<List<ActaModel>> getActas() async {
    ActaProvider actaProv = new ActaProvider();
    List<ActaModel> salida = await actaProv.all();
    actaProv = null; // destroy Variable
    return salida;
  }

  Future<String> subirImagen(File imagen) async {
    ActaProvider actaProv = new ActaProvider();
    String salida = await actaProv.subirImagen(imagen);
    actaProv = null; // destroy Variable
    return salida;
  }

  /*
   * Metodos de Mesas Electorales
   */
  Future<String> insertMesa(MesaModel mesa) async {
    MesaProvider mesaProv = new MesaProvider();
    String salida = await mesaProv.insert(mesa);
    mesaProv = null; // destroy Variable
    return salida;
  }

  Future<String> insertJurado(JuradoModel jurado) async {
    MesaProvider juradoProv = new MesaProvider();
    String salida = await juradoProv.insertJurado(jurado);
    juradoProv = null; // destroy Variable
    return salida;
  }

  Future<String> getJurados(String mesaId) async {
    MesaProvider juradoProv = new MesaProvider();
    String salida = '';
    List<JuradoModel> jurados = await juradoProv.allJurado(mesaId);
    int i = 1;
    jurados.forEach((jurado) {
      print(jurado.toString());
      if (jurado.mesaId == mesaId) {
        salida = salida + 'Jurado $i\n';
        i++;
        salida = salida + jurado.toString();
      }
    });
    juradoProv = null; // destroy Variable
    return salida;
  }

  Future<bool> actualizarMesa(MesaModel acta) async {
    MesaProvider mesaProv = new MesaProvider();
    bool salida = await mesaProv.update(acta);
    mesaProv = null; // destroy Variable
    return salida;
  }

  Future<List<MesaModel>> getMesas() async {
    MesaProvider mesaProv = new MesaProvider();
    List<MesaModel> salida = await mesaProv.all();
    mesaProv = null; // destroy Variable
    return salida;
  }

  Future<MesaModel> getMesa(String idMesa) async {
    MesaProvider mesaProv = new MesaProvider();
    List<MesaModel> mesas = await mesaProv.all();
    MesaModel salida = new MesaModel();
    for (MesaModel mesa in mesas) {
      if (mesa.id == idMesa) {
        salida = mesa;
        break;
      }
    }
    mesaProv = null; // destroy Variable
    return salida;
  }

  /*
   * Metodos de Partidos Electorales
   */
  Future<List<PartidoModel>> getPartidos() async {
    PartidoProvider partidoProv = new PartidoProvider();
    List<PartidoModel> salida = await partidoProv.all();
    partidoProv = null; // destroy Variable
    return salida;
  }

  Future<PartidoModel> getPartido(String partidoId) async {
    PartidoProvider partidoProv = new PartidoProvider();
    PartidoModel salida = await partidoProv.getPartido(partidoId);
    partidoProv = null; // destroy Variable
    return salida;
  }

  /*
   * Metodos de Ubicacion de Mesas
   */
  Future<String> insertUbiacion(UbicacionModel ubi) async {
    UbicacionProvider ubicacionProv = new UbicacionProvider();
    String salida = await ubicacionProv.insert(ubi);
    ubicacionProv = null; // destroy Variable
    return salida;
  }

  Future<bool> actualizarUbiacion(UbicacionModel ubi) async {
    UbicacionProvider ubicacionProv = new UbicacionProvider();
    bool salida = await ubicacionProv.update(ubi);
    ubicacionProv = null; // destroy Variable
    return salida;
  }

  Future<List<UbicacionModel>> getUbiaciones() async {
    UbicacionProvider ubicacionProv = new UbicacionProvider();
    List<UbicacionModel> salida = await ubicacionProv.all();
    ubicacionProv = null; // destroy Variable
    return salida;
  }

  Future<UbicacionModel> getUbicacion(String idUbi) async {
    UbicacionProvider ubicacionProv = new UbicacionProvider();
    List<UbicacionModel> ubicaciones = await ubicacionProv.all();
    UbicacionModel salida = new UbicacionModel();
    for (UbicacionModel ubicacion in ubicaciones) {
      if (ubicacion.id == idUbi) {
        salida = ubicacion;
        break;
      }
    }

    ubicacionProv = null; // destroy Variable
    return salida;
  }

  /*
   * Metodos de Conteo de Votos
   */
  Future<String> insertConteo(ConteoModel conteo) async {
    ConteoProvider conteoProv = new ConteoProvider();
    String salida = await conteoProv.insert(conteo);
    conteoProv = null; // destroy Variable
    return salida;
  }

  Future<List<ConteoModel>> getConteoActa(String idActa) async {
    ConteoProvider conteoProv = new ConteoProvider();
    final conteos = await conteoProv.all();
    List<ConteoModel> salida = new List<ConteoModel>();

    for (ConteoModel item in conteos) {
      if (item.actaId == idActa) {
        if (item.partidoId != null) {
          final partido =
              await this.getPartido(this.getKeyPartido(item.partidoId));
          item.logoPartido = partido.fotoUrl;
        }
        salida.add(item);
      }
    }
    conteoProv = null; // destroy Variable
    return salida;
  }

  getKeyPartido(String nombre) {
    String salida = '';
    this.partidos.forEach((key, value) {
      if (key == nombre) {
        salida = value;
      }
    });
    return salida;
  }
}
