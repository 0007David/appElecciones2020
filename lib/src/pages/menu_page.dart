import 'package:flutter/material.dart';
import 'package:app_elecciones2020/src/utils/utils.dart' as utils;

class MenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/menu-img.jpg'), fit: BoxFit.cover),
            ),
            child: Container(),
          ),
          ListTile(
            leading: Icon(
              Icons.pages,
              color: Colors.blue,
            ),
            title: Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, 'home'),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            title: Text('Perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.insert_chart,
              color: Colors.blue,
            ),
            title: Text('Web Estadisticas'),
            onTap: utils.abrirWeb,
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
            title: Text('Ajustes'),
            onTap: () {
              // Navigator.pop(context);
              // Navigator.pushNamed(context, SettingsPage.routeName);
              Navigator.pushReplacementNamed(context, 'home2');
            },
          ),
        ],
      ),
    );
  }
}
