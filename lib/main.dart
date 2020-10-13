import 'package:app_elecciones2020/src/pages/detalle_acta_page.dart';
import 'package:app_elecciones2020/src/pages/home2_page.dart';
import 'package:app_elecciones2020/src/pages/home3_page.dart';
import 'package:flutter/material.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';
import 'package:app_elecciones2020/src/pages/home_page.dart';
import 'package:app_elecciones2020/src/pages/login_page.dart';
import 'package:app_elecciones2020/src/pages/producto_page.dart';
import 'package:app_elecciones2020/src/pages/registro_page.dart';
import 'package:app_elecciones2020/src/preferencias_usuario/preferencia_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = new PreferenciasUsuario();
    print(prefs.token);

    return Provider(
      // key: key,
      child: MaterialApp(
        title: 'Material App',
        initialRoute: 'login',
        routes: {
          'login': (conext) => LoginPage(),
          'registro': (context) => RegistroPage(),
          'home': (context) => HomePage(),
          'home2': (context) => Home2Page(),
          'detalleacta': (context) => DetalleActaPage(),
          'home3': (context) => Home3Page(),
          'producto': (context) => ProductoPage(),
        },
        theme: ThemeData(primaryColor: Colors.deepPurple),
      ),
    );
  }
}
