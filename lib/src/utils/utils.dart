import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_elecciones2020/src/models/mesa_model.dart';

bool isNumeric(String s) {
  if (s.isEmpty) return false;

  final n = num.tryParse(s);

  return (n == null) ? false : true;
}

bool isStringNumero(String s) {
  //1 11
  if (s.isEmpty) return false;
  var pos = s.split(' ');
  bool salida;
  for (var item in pos) {
    final n = num.tryParse(item);
    salida = (n == null) ? false : true;
    if (!salida) {
      break;
    }
  }

  return salida;
}

int convertToInt(String s) {
  if (s.isEmpty) return 0;
  var pos = s.split(' ');
  bool salida;
  String numero = '';
  for (var item in pos) {
    salida = isNumeric(item);
    if (!salida) {
      return 0;
    }
    numero = numero + item;
  }

  return num.tryParse(numero); //num.tryParse(numero);
}

void mostrarAlerta(BuildContext context, String title, String mensaje) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(mensaje),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
}

abrirWeb() async {
  if (await canLaunch('https://elecciones2020.herokuapp.com/')) {
    await launch('https://elecciones2020.herokuapp.com/');
  } else {
    throw 'Could not launch https://elecciones2020.herokuapp.com/';
  }
}
