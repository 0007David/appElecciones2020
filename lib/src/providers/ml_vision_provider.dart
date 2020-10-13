import 'dart:io';

import 'package:app_elecciones2020/src/models/acta_model.dart';
import 'package:app_elecciones2020/src/models/conteo_model.dart';
import 'package:app_elecciones2020/src/models/mesa_model.dart';
import 'package:app_elecciones2020/src/models/ubicacion_model.dart';
import 'package:app_elecciones2020/src/utils/utils.dart' as utils;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class MLVisionProvider {
  /*
   * Metodo que reconoce letras de una Imagen
   */
  Future<String> readText(File _selectedFile,
      [String method = '', String actaId = '']) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_selectedFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    String salida = "";
    //method = 'acta';
    switch (method) {
      case 'acta':
        String linea = '', antLinea = '';
        ActaModel acta = new ActaModel();
        int contador = 0;
        if (this.validarActa(readText.text)) {
          for (TextBlock block in readText.blocks) {
            if (contador == 3) {
              break;
            }
            for (TextLine line in block.lines) {
              linea = line.text.trim();
              // print('l: ' + linea);
              if (antLinea == 'cODIGO VERIFICACIÓN'.toLowerCase() ||
                  antLinea == 'CODIGO VERIFICACION'.toLowerCase()) {
                print('Codigo: ' + linea);
                acta.setAtrr(contador, linea);
                contador++;
              } else if (antLinea == 'po' ||
                  antLinea == 'tlpo' ||
                  antLinea == 'tipo') {
                print('Codigo Ver: ' + linea);
                acta.setAtrr(contador, linea);
                contador++;
              } else if (antLinea == 'oep') {
                print('Tipo: ' + linea);
                acta.setAtrr(contador, linea);
                contador++;
              }

              antLinea = linea.toLowerCase();
            }
            salida = actaModelToJson(acta);
          }
        }
        break;
      case 'ubicacion': // Ubicacion de la Mesa

        final ubi = new UbicacionModel();
        var datos = [
          'cOMPUTO DE VOTOS OBTENIDOS POR LAS',
          'UBICACIÓN DE LA MESA',
          'UBICACION DE LA MESA',
          'Departamento:',
          'Provincia:',
          'Provincia',
          'Municipio:',
          'Municipio',
          'Localidad:',
          'Localidad',
          'Recinto:',
          'Recinto'
        ];
        String linea = '', atributos = '';
        int contador = 0;
        if (this.validarUbicacion(readText.text)) {
          for (TextBlock block in readText.blocks) {
            for (TextLine line in block.lines) {
              linea = line.text.trim();
              if (!datos.contains(linea) && !utils.isNumeric(linea)) {
                atributos = atributos + linea + '\n';
                ubi.setAtrr(contador, linea);
                // print('l: ' + line.text);
                contador++;
                break;
              }
            }
          }
          // print('Action ' + ubicacionModelToJson(ubi));
          salida = ubicacionModelToJson(ubi);
        }
        break;
      case 'mesa':
        MesaModel mesa = new MesaModel();
        String linea = '', nroHabilitados = '';
        bool bandera = false;
        if (this.validarMesa(readText.text)) {
          for (TextBlock block in readText.blocks) {
            for (TextLine line in block.lines) {
              linea = line.text.trim();
              if (utils.isNumeric(linea) ||
                  linea == 'habilitadas/os en mesa:') {
                if (linea == 'habilitadas/os en mesa:') {
                  bandera = true;
                }
                if (bandera && utils.isNumeric(linea)) {
                  nroHabilitados = nroHabilitados + linea;
                }
                if (!bandera && linea.length > 1) {
                  //codigo
                  mesa.setAtrr(0, linea);
                }
                break;
              } else if (linea.contains('MESA:') || linea.contains('Diputado')
                  //|| linea.contains('ánfora:')
                  ) {
                if (linea.contains('MESA:')) {
                  var pos = linea.split(':');
                  //nro Mesa
                  mesa.setAtrr(1, pos[1].trim());
                } else if (linea.contains('Diputado')) {
                  // print('CIR: ' + linea);circunscripcion
                  mesa.setAtrr(2, linea);
                }
                if (linea == 'ánfora:') {
                  bandera = false;
                }
              }
            }
          }
          mesa.setAtrr(3, num.tryParse(nroHabilitados));
          // print('nroHabilitados: ' + nroHabilitados);
          salida = mesaModelToJson(mesa);
        }
        break;
      case 'votosTotales':
        String linea = '';
        bool bandera = true;
        int contador = 0;
        ConteoModel conteo = new ConteoModel();
        conteo.actaId = actaId;
        for (TextBlock block in readText.blocks) {
          for (TextLine line in block.lines) {
            linea = line.text.trim();
            if (utils.isNumeric(linea)) {
              if (!bandera) {
                print('pre: ' + linea);
                if (contador < 2) {
                  conteo.tipo = 'Votos Validos Presidente';
                } else if (contador >= 2 && contador < 4) {
                  conteo.tipo = 'Votos blancos Presidente';
                } else if (contador >= 4 && contador < 6) {
                  conteo.tipo = 'Votos nulos Presidente';
                }

                conteo.nroVoto = num.parse(linea);
                salida = salida + conteoModelToJson(conteo) + ',\n';
                bandera = !bandera;
                contador++;
              } else {
                print('Cir: ' + linea);
                if (contador < 2) {
                  conteo.tipo = 'Votos Validos Diputado';
                } else if (contador >= 2 && contador < 4) {
                  conteo.tipo = 'Votos blancos Diputado';
                } else if (contador >= 4 && contador < 6) {
                  conteo.tipo = 'Votos nulos Diputado';
                }

                conteo.nroVoto = num.parse(linea);
                salida = salida + conteoModelToJson(conteo) + ',\n';
                bandera = !bandera;
                contador++;
              }
            } else {
              var pos = linea.split(' ');
              if (utils.isNumeric(pos[0])) {
                if (pos.length > 1) {
                  if (!bandera) {
                    print('pre: ' + pos[0] + pos[1]);
                    if (contador < 2) {
                      conteo.tipo = 'Votos Validos Presidente';
                    } else if (contador >= 2 && contador < 4) {
                      conteo.tipo = 'Votos blancos Presidente';
                    } else if (contador >= 4 && contador < 6) {
                      conteo.tipo = 'Votos nulos Presidente';
                    }

                    conteo.nroVoto = num.parse(pos[0] + pos[1]);
                    salida = salida + conteoModelToJson(conteo) + ',\n';
                    bandera = !bandera;
                    contador++;
                  } else {
                    print('Cir ' + pos[0] + pos[1]);
                    if (contador < 2) {
                      conteo.tipo = 'Votos Validos Diputado';
                    } else if (contador >= 2 && contador < 4) {
                      conteo.tipo = 'Votos blancos Diputado';
                    } else if (contador >= 4 && contador < 6) {
                      conteo.tipo = 'Votos nulos Diputado';
                    }

                    conteo.nroVoto = num.parse(pos[0] + pos[1]);
                    salida = salida + conteoModelToJson(conteo) + ',\n';
                    bandera = !bandera;
                    contador++;
                  }
                } else {
                  if (!bandera) {
                    print('pre: ' + pos[0]);
                    if (contador < 2) {
                      conteo.tipo = 'Votos Validos Presidente';
                    } else if (contador >= 2 && contador < 4) {
                      conteo.tipo = 'Votos blancos Presidente';
                    } else if (contador >= 4 && contador < 6) {
                      conteo.tipo = 'Votos nulos Presidente';
                    }

                    conteo.nroVoto = num.parse(pos[0]);
                    salida = salida + conteoModelToJson(conteo) + ',\n';
                    bandera = !bandera;
                    contador++;
                  } else {
                    print('Cir ' + pos[0]);
                    if (contador < 2) {
                      conteo.tipo = 'Votos Validos Diputado';
                    } else if (contador >= 2 && contador < 4) {
                      conteo.tipo = 'Votos blancos Diputado';
                    } else if (contador >= 4 && contador < 6) {
                      conteo.tipo = 'Votos nulos Diputado';
                    }

                    conteo.nroVoto = num.parse(pos[0]);
                    salida = salida + conteoModelToJson(conteo) + ',\n';
                    bandera = !bandera;
                    contador++;
                  }
                }
              }
            }
          }
        }
        if (contador < 6) {
          if (contador == 5) {
            conteo.nroVoto = 0;
            conteo.tipo = 'Votos nulos Diputado';
            salida = salida + conteoModelToJson(conteo) + '';
          } else if (contador == 4) {
            conteo.nroVoto = 0;
            conteo.tipo = 'Votos blancos Presidente';
            conteo.tipo = 'Votos nulos Diputado';
            salida = salida + conteoModelToJson(conteo) + ',\n';
            conteo.tipo = 'Votos nulos Presidente';
            salida = salida + conteoModelToJson(conteo);
          }
        }
        break;
      case 'conteo':
        String linea = '', antLinea1 = '';
        salida = '';
        String list = '';
        ConteoModel conteoPre = new ConteoModel(),
            conteoCir = new ConteoModel();
        int contador = 0;
        int contadorInt = 0;
        bool bandera = false;
        if (this.validarConteo(readText.text)) {
          for (TextBlock block in readText.blocks) {
            for (TextLine line in block.lines) {
              linea = line.text.trim();
              // print('l: ' + linea);
              if ((antLinea1 == 'C.C.' || contador == 0)) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'C.C.'; //partido1
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'C.C.'; //partido1
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'FPV') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'C.C.'; //partido1
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'C.C.'; //partido1
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'C.C.'; //partido1
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'FPV' || contador == 1) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'FPV'; //partido2
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'FPV'; //partido2
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'MTS') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'FPV'; //partido2
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'FPV'; //partido2
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'FPV'; //partido2
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'MTS' || contador == 2) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'MTS'; // partido3
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'MTS'; // partido3
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'UCS') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'MTS'; // partido3
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'MTS'; // partido3
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'MTS'; // partido3
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'UCS' || contador == 3) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'UCS'; //partido4
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'UCS'; //partido4
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'MAS IPSP' ||
                    linea == 'MAS-IPSP' ||
                    linea == 'MAS -IPSP') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'UCS'; //partido4
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'UCS'; //partido4
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'UCS'; //partido4
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (linea == 'MAS IPSP' ||
                  linea == 'MAS-IPSP' ||
                  linea == 'MAS -IPSP' ||
                  contador == 4) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'MAS-IPSP'; //partido5
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'MAS-IPSP'; //partido5
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  if (contadorInt == 2) {
                    contador++;
                    contadorInt = 0;
                  }
                }
                if (linea == '21F') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'MAS-IPSP'; //partido5
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'MAS-IPSP'; //partido5
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'MAS-IPSP'; //partido5
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == '21F' || contador == 5) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = '21F'; //partido6
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = '21F'; //partido6
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'PDC') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = '21F'; //partido6
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = '21F'; //partido6
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = '21F'; //partido6
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'PDC' || contador == 6) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'PDC'; //partido7
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'PDC'; //partido7
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'MNR') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'PDC'; //partido7
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'PDC'; //partido7
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'PDC'; //partido7
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'MNR' || contador == 7) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'MNR'; //partido8
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'MNR'; //partido8
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'PAN-BOL' || linea == 'PAN-BODL') {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'MNR'; //partido8
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'MNR'; //partido8
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'MNR'; //partido8
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              } else if (antLinea1 == 'PAN-BOL' ||
                  antLinea1 == 'PAN-BODL' ||
                  contador == 8) {
                if (utils.isNumeric(linea) || utils.isStringNumero(linea)) {
                  if (!bandera) {
                    conteoPre.partidoId = 'PAN-BOL'; //partido9
                    conteoPre.nroVoto = utils.convertToInt(linea);
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                  } else {
                    conteoCir.partidoId = 'PAN-BOL'; //partido9
                    conteoCir.nroVoto = num.parse(linea);
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    bandera = !bandera;
                    contadorInt++;
                    list = list + conteoModelToJson(conteoCir) + ',\n';
                  }
                }
                if (linea == 'PAN-BOL' || linea == 'PAN-BODL' || bandera) {
                  if (contadorInt == 0) {
                    conteoPre.partidoId = 'PAN-BOL'; //partido9
                    conteoPre.nroVoto = 0;
                    conteoPre.tipo = 'Presidente';
                    conteoPre.actaId = actaId;
                    list = list + conteoModelToJson(conteoPre) + ',\n';
                    conteoCir.partidoId = 'PAN-BOL'; //partido9
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir);
                  } else if (contadorInt == 1) {
                    conteoCir.partidoId = 'PAN-BOL'; //partido9
                    conteoCir.nroVoto = 0;
                    conteoCir.tipo = 'Diputado';
                    conteoCir.actaId = actaId;
                    list = list + conteoModelToJson(conteoCir);
                  }
                  contadorInt = 0;
                  contador++;
                  bandera = false;
                  conteoCir = new ConteoModel();
                  conteoPre = new ConteoModel();
                }
              }
              // salida = salida + linea + '\n';
              //antLinea2 = antLinea1;
              antLinea1 = linea;
            }
          }
          // print('Salida');
          //list = list + ']';
          salida = list;
        }
        break;
      default:
        print('Action Default');
        String linea = '';
        for (TextBlock block in readText.blocks) {
          for (TextLine line in block.lines) {
            linea = line.text.trim();
            // print('l: ' + linea);
            salida = salida + linea + '\n';
          }
        }
        salida = readText.text;
    }
    // Case: Notos no Valido
    return salida;
  }

  Future decode(File _selectedFile) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_selectedFile);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(ourImage);

    for (Barcode readableCode in barCodes) {
      print(readableCode.displayValue);
    }
  }

  bool validarUbicacion(String value) {
    var datos = [
      'Departamento',
      'Provincia',
      'Municipio',
      'Localidad',
      'Recinto'
    ];
    var counter = 0;
    for (var item in datos) {
      if (value.contains(item)) {
        counter = counter + 1;
      }
    }
    return (counter == datos.length) ? true : false;
  }

  bool validarMesa(String value) {
    var datos = ['CODIGO', 'MESA', 'APERTURA', 'CIERRE'];
    var counter = 0;
    for (var item in datos) {
      if (value.contains(item)) {
        counter = counter + 1;
      }
    }
    print('validarMesa Counter: ' + counter.toString());
    return (counter == datos.length) ? true : false;
  }

  bool validarConteo(String value) {
    var datos = ['C.C.', 'FPV', 'MAS', 'UCS', '21F', 'PDC', 'MNR', 'PAN-B'];
    var counter = 0;
    for (var item in datos) {
      if (value.contains(item)) {
        counter = counter + 1;
      }
    }
    print('validarMesa Counter: ' + counter.toString());
    return (counter == datos.length) ? true : false;
  }

  bool validarTotalVotos(String value) {
    return true;
  }

  bool validarActa(String value) {
    return true;
  }
}
