import 'dart:io';

import 'package:app_elecciones2020/src/models/conteo_model.dart';
import 'package:app_elecciones2020/src/models/jurado_model.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:app_elecciones2020/src/utils/utils.dart' as utils;
import 'package:app_elecciones2020/src/bloc/facade_bloc.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';

class DetalleActaPage extends StatefulWidget {
  @override
  _DetalleActaPageState createState() => _DetalleActaPageState();
}

class _DetalleActaPageState extends State<DetalleActaPage> {
  FacadeBloc facadeBloc;
  ActaModel acta = new ActaModel();
  UbicacionModel ubicacion = new UbicacionModel();
  MesaModel mesa = new MesaModel();
  bool _inProcess = false;
  // File _fileActa;

  @override
  Widget build(BuildContext context) {
    facadeBloc = Provider.facadeBloc(context);
    final actaData = ModalRoute.of(context).settings.arguments;
    if (actaData != null) {
      acta = actaData;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Actas Electoral')),
      body: Stack(
        children: <Widget>[
          ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Form(
                    key: UniqueKey(),
                    child: Column(
                      children: <Widget>[
                        _mostrarFoto(acta),
                      ],
                    ),
                  ),
                ),
              ),
              _cardDescripcionMesaUbicacion(acta, facadeBloc),
              _cardDescripcionJurados(acta, facadeBloc),
              // _cardDescripcionConteo(facadeBloc),
              SizedBox(height: 10.0),
              _cardDescripcionConteo(acta, facadeBloc),
            ],
          ),
          Opacity(
              opacity: _inProcess ? 1.0 : 0,
              child: SimpleDialog(
                backgroundColor: Colors.transparent,
                elevation: 0.1,
                // title: new Text('Do you like Flutter?'),
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Cargando...',
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _cardFotoMesa() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: <Widget>[
          ListTile(
            // leading: Icon(Icons.photo_album, color: Colors.blue),
            title: Text('Seleccione la Mesa'),
            subtitle: Text(
              'Seleccione el area correcta',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          Image(
            // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
            // _foto
            image: AssetImage('assets/no-image.png'),
            height: 120.0,
            // width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Cancelar'),
                color: Colors.grey,
                onPressed: () {},
              ),
              FlatButton(
                child: Text('Ok'),
                color: Colors.blue,
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _mostrarFoto(ActaModel acta) {
    return Container(
        child: Column(
      children: [
        FadeInImage(
          image: NetworkImage(acta.fotoUrl),
          placeholder: AssetImage('assets/jar-loading.gif'),
          fadeInDuration: Duration(milliseconds: 200),
          height: 300.0,
          fit: BoxFit.cover,
        ),
        Container(
          padding: EdgeInsets.all(0.0),
          margin: EdgeInsets.all(0.0),
          child: ListTile(
            title: Text(
              acta.toString(),
            ),
            // subtitle: Text('21-09-2020'),
          ),
          color: Colors.grey.shade200,
        ),
      ],
    ));

    // }
  }

  Widget _cardDescripcionMesaUbicacion(ActaModel acta, FacadeBloc facadeBloc) {
    return FutureBuilder<MesaModel>(
      future: facadeBloc.getMesa(acta.mesaId),
      builder: (BuildContext context, AsyncSnapshot<MesaModel> snapshot) {
        if (snapshot.hasData) {
          this.mesa = snapshot.data;
          return FutureBuilder<UbicacionModel>(
            future: facadeBloc.getUbicacion(this.mesa.ubicacionId),
            builder:
                (BuildContext context, AsyncSnapshot<UbicacionModel> snapshot) {
              if (snapshot.hasData) {
                this.ubicacion = snapshot.data;
                return Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.account_balance,
                          color: Colors.blue,
                        ),
                        title: Text('Mesa de Votacion'),
                        subtitle: Text(
                            this.mesa.toString() + this.ubicacion.toString()),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  height: 400.0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
        } else {
          return Container(
            height: 400.0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _cardDescripcionJurados(ActaModel acta, FacadeBloc facadeBloc) {
    return FutureBuilder<String>(
      future: facadeBloc.getJurados(acta.mesaId),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.people,
                    color: Colors.blue,
                  ),
                  title: Text('Lista de Jurados'),
                  subtitle: Text(snapshot.data),
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: 200.0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _cardDescripcionConteo(ActaModel acta, FacadeBloc facadeBloc) {
    return FutureBuilder<List<ConteoModel>>(
      future: facadeBloc.getConteoActa(acta.id),
      initialData: [],
      builder:
          (BuildContext context, AsyncSnapshot<List<ConteoModel>> snapshot) {
        // print('DATA: ' + snapshot.data.toString());
        return Column(
          children: _listConteo(snapshot.data, context),
        );
      },
    );
  }

  List<Widget> _listConteo(List<ConteoModel> conteos, BuildContext context) {
    final List<Widget> listaConteo = [];
    conteos.forEach((conteo) {
      print('Conteo: ' + conteoModelToJson(conteo));
      final widgetTemp = ListTile(
        title: Text((conteo.partidoId != null
            ? conteo.partidoId + ': ' + (conteo.nroVoto.toString())
            : conteo.tipo + ': ' + conteo.nroVoto.toString())),
        subtitle: (conteo.partidoId != null) ? Text(conteo.tipo) : null,
        leading: (conteo.partidoId != null)
            ? CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(conteo.logoPartido),
              )
            : FadeInImage(
                image: AssetImage('assets/no-image.png'),
                placeholder: AssetImage('assets/jar-loading.gif'),
                height: 15.0,
                fit: BoxFit.cover,
              ),
        // trailing: Icon(
        //   Icons.keyboard_arrow_right,
        //   color: Colors.blue,
        // ),
        onTap: () {},
      );
      listaConteo.add(widgetTemp);
      listaConteo.add(Divider());
    });
    return listaConteo;
  }

  Widget _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.assignment_ind),
      backgroundColor: Colors.deepPurple,
      onPressed: _scanQR, //=> Navigator.pushNamed(context, 'producto'),
    );
  }

  _scanQR() async {
    // String futureString = '';
    String futureString;

    try {
      futureString = await BarcodeScanner.scan();
    } catch (e) {
      futureString = e.toString();
    }

    print(futureString);
    if (futureString != null) {
      // final scan = ScanModel(valor: futureString);
      // scansBloc.agregarScan(scan);
      var jurado = juradoModelFromJson(futureString.replaceAll('&#34;', '\"'));
      print(this.acta);
      jurado.mesaId = this.acta.mesaId;
      this.facadeBloc.insertarJurado(jurado);
      print(jurado.telefono +
          ' ' +
          jurado.ci +
          ' ' +
          jurado.nombre +
          'mesaId: ' +
          jurado.mesaId);
      // {"ci": "123288327", "nombre": "David Torrez", "telefono": "73266172"}
      if (Platform.isIOS) {
        Future.delayed(Duration(milliseconds: 750), () {
          // utils.abrirWeb();
        });
      } else {
        // utils.abrirWeb();
      }
    }
  }
}
