import 'package:app_elecciones2020/src/bloc/facade_bloc.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';
import 'package:app_elecciones2020/src/models/acta_model.dart';
import 'package:app_elecciones2020/src/pages/menu_page.dart';
import 'package:flutter/material.dart';

class Home3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final facadeBloc = Provider.facadeBloc(context);
    facadeBloc.cargarActas();
    return Scaffold(
        appBar: AppBar(
          title: Text('Actas Registradas'),
        ),
        drawer: MenuWidget(),
        body: _crearListadoActas(facadeBloc),
        floatingActionButton: _crearBoton(context));
  }

  Widget _crearListadoActas(FacadeBloc facadeBloc) {
    return StreamBuilder<List<ActaModel>>(
        stream: facadeBloc.actasStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ActaModel>> snapshot) {
          if (snapshot.hasData) {
            final actas = snapshot.data;
            return ListView.builder(
                itemCount: actas.length,
                itemBuilder: (BuildContext context, int index) =>
                    _cardTipo2(context, actas[index]));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _cardTipo2(BuildContext context, ActaModel acta) {
    final card = Container(
      // clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(acta.fotoUrl),
            placeholder: AssetImage('assets/jar-loading.gif'),
            fadeInDuration: Duration(milliseconds: 200),
            height: 300.0,
            fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            //margin: EdgeInsets.all(0.0),
            child: ListTile(
              title: Text('Acta Elec. - Cod Ver: ' + acta.codigoVerificacion),
              subtitle: Text('Codigo Barra: ' + acta.codigoBarra),
              onTap: () {
                Navigator.pushNamed(context, 'detalleacta', arguments: acta);
              },
            ),
          ),
        ],
      ),
    );
    return Column(children: [
      Container(
        padding: EdgeInsets.only(bottom: 0, top: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  offset: Offset(2.0, 10.0))
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: card,
        ),
      ),
      SizedBox(height: 30.0),
    ]);
  }

  Widget _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add_photo_alternate),
      backgroundColor: Colors.deepPurple,
      onPressed: () => Navigator.pushNamed(context, 'home2'),
    );
  }
}
