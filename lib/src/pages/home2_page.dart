import 'package:app_elecciones2020/src/models/acta_model.dart';
import 'package:app_elecciones2020/src/models/conteo_model.dart';
import 'package:app_elecciones2020/src/models/mesa_model.dart';
import 'package:app_elecciones2020/src/models/ubicacion_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:app_elecciones2020/src/providers/ml_vision_provider.dart';
import 'package:app_elecciones2020/src/utils/utils.dart' as utils;
import 'package:app_elecciones2020/src/bloc/facade_bloc.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gallery_saver/gallery_saver.dart';

class Home2Page extends StatefulWidget {
  @override
  _Home2PageState createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  File _fileActa;
  File _fileUbicacion;
  File _fileConteo;
  File _fileMesa;
  File _fileTotalVotos;
  bool _inProcess = false;
  bool _validateActa;
  bool _validateUbicacion;
  bool _validateMesa;
  bool _validateConteo;
  bool _validateTotalVotos;
  List<ConteoModel> conteos;
  ActaModel acta;
  MesaModel mesa;
  UbicacionModel ubicacion;

  MLVisionProvider mlVisionProvider = new MLVisionProvider();
  FacadeBloc facadeBloc;

  @override
  Widget build(BuildContext context) {
    facadeBloc = Provider.facadeBloc(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cargar Actas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(icon: Icon(Icons.camera_alt), onPressed: _tomarFoto),
        ],
      ),
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
                        _mostrarFoto(),
                      ],
                    ),
                  ),
                ),
              ),
              (_fileActa != null) ? _cardFotoMesa() : Container(),
              (_fileActa != null) ? _cardFotoUbicacion() : Container(),
              (_fileActa != null) ? _cardFotoConteo() : Container(),
              (_fileActa != null) ? _cardFotoTotalVotos() : Container(),
              // getImageWidget(),
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

  void readText() async {
    String salida = await mlVisionProvider.readText(_fileActa);
    utils.mostrarAlerta(context, 'Información ReadText', salida);
  }

  void decodeBar() async {
    await mlVisionProvider.decode(_fileActa);
  }

  void _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  void _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  void _procesarImagen(ImageSource tipoSource) async {
    setState(() => _inProcess = true);
    final picker = ImagePicker();
    final image = await picker.getImage(source: tipoSource);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          compressQuality: 100,
          androidUiSettings: AndroidUiSettings(
            // showCropGrid: false,
            lockAspectRatio: false, // recuadro de recorte activo
            hideBottomControls: true,
            toolbarColor: Colors.deepPurple,
            toolbarTitle: "Foto Selecta",
            statusBarColor: Colors.blue,
            initAspectRatio: CropAspectRatioPreset.original,
            backgroundColor: Colors.white,
          ));
      if (cropped != null) {
        String salida = await mlVisionProvider.readText(cropped, 'acta');
        _validateActa = false;
        if (salida != "") {
          this.acta = actaModelFromJson(salida);
          _validateActa = true; //mlVisionProvider.validarActa(value);
        }
      }
      setState(() {
        _fileActa = cropped;
        _inProcess = false;
      });
    } else {
      setState(() => _inProcess = false);
    }
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
            subtitle: (_validateMesa != null && !_validateMesa)
                ? Text(
                    'Seleccione el area correcta',
                    style: TextStyle(color: Colors.redAccent),
                  )
                : null,
          ),
          Image(
            // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
            // _foto
            image: _fileMesa != null
                ? FileImage(_fileMesa)
                : AssetImage('assets/no-image.png'),
            height: 120.0,
            // width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('ver'),
                color: Colors.blue,
                onPressed: () {
                  print(this.acta);
                  print(this.mesa);
                  print(this.ubicacion);
                  for (var item in this.conteos) {
                    print(item);
                  }
                },
              ),
              FlatButton(
                child: Text('Cargar imagen'),
                color: Colors.blue,
                onPressed: _procesarFotoMesa,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _cardFotoConteo() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: <Widget>[
          ListTile(
            // leading: Icon(Icons.photo_album, color: Colors.blue),
            title: Text('Seleccione el Conteo'),
            subtitle: (_validateConteo != null && !_validateConteo)
                ? Text('Seleccione el area correcta',
                    style: TextStyle(color: Colors.red))
                : null,
          ),
          Image(
            // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
            // _foto
            image: _fileConteo != null
                ? FileImage(_fileConteo)
                : AssetImage('assets/no-image.png'),
            height: 120.0,
            // width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Cargar imagen'),
                color: Colors.blue,
                onPressed: _procesarFotoConteo,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _cardFotoUbicacion() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: <Widget>[
          ListTile(
            // leading: Icon(Icons.photo_album, color: Colors.blue),
            title: Text('Seleccione la Ubicacion'),
            subtitle: (_validateUbicacion != null && !_validateUbicacion)
                ? Text(
                    'Seleccione el area correcta',
                    style: TextStyle(color: Colors.red),
                  )
                : null,
          ),
          Image(
            // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
            // _foto
            image: _fileUbicacion != null
                ? FileImage(_fileUbicacion)
                : AssetImage('assets/no-image.png'),
            height: 120.0,
            // width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Cargar imagen'),
                color: Colors.blue,
                onPressed: _procesarFotoUbicacion,
              )
            ],
          )
        ],
      ),
    );
  }

  void _procesarFotoUbicacion() async {
    this.setState(() {
      _inProcess = true;
    });
    File cropped = await ImageCropper.cropImage(
        sourcePath: _fileActa.path,
        // compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
          // showCropGrid: false,
          lockAspectRatio: false, // recuadro de recorte activo
          hideBottomControls: true,
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "RPS Cropper",
          statusBarColor: Colors.deepOrange.shade900,
          initAspectRatio: CropAspectRatioPreset.original,
          backgroundColor: Colors.white,
        ));
    if (cropped != null) {
      String salida = await mlVisionProvider.readText(cropped, 'ubicacion');
      this._validateUbicacion =
          false; //mlVisionProvider.validarUbicacion(salida);
      if (salida != "") {
        this.ubicacion = ubicacionModelFromJson(salida);
        this._validateUbicacion = true;
      }
    }
    this.setState(() {
      _fileUbicacion = cropped;
      _inProcess = false;
    });
  }

  Widget _cardFotoTotalVotos() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: <Widget>[
          ListTile(
            // leading: Icon(Icons.photo_album, color: Colors.blue),
            title: Text('Seleccione Votos Totales'),
            subtitle: (_validateTotalVotos != null && !_validateTotalVotos)
                ? Text(
                    'Seleccione el area correcta',
                    style: TextStyle(color: Colors.red),
                  )
                : null,
          ),
          Image(
            // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
            // _foto
            image: _fileTotalVotos != null
                ? FileImage(_fileTotalVotos)
                : AssetImage('assets/no-image.png'),
            height: 120.0,
            // width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Cargar imagen'),
                color: Colors.blue,
                onPressed: _procesarFotoTotalVotos,
              )
            ],
          )
        ],
      ),
    );
  }

  void _procesarFotoTotalVotos() async {
    this.setState(() {
      _inProcess = true;
    });
    File cropped = await ImageCropper.cropImage(
        sourcePath: _fileActa.path,
        // compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
          // showCropGrid: false,
          lockAspectRatio: false, // recuadro de recorte activo
          hideBottomControls: true,
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "RPS Cropper",
          statusBarColor: Colors.deepOrange.shade900,
          initAspectRatio: CropAspectRatioPreset.original,
          backgroundColor: Colors.white,
        ));
    if (cropped != null) {
      // String salida = await mlVisionProvider.readText(cropped, 'votosTotales');
      // this._validateTotalVotos =
      //     false; //mlVisionProvider.validarUbicacion(salida);
      // if (salida != "") {
      //   var cont = salida.split(',\n');
      //   for (var item in cont) {
      //     ConteoModel c = conteoModelFromJson(item);
      //     this.conteos.add(c);
      //   }
      // }
    }
    this._validateTotalVotos = true;
    this.setState(() {
      _fileTotalVotos = cropped;
      _inProcess = false;
    });
  }

  void _procesarFotoConteo() async {
    this.setState(() {
      _inProcess = true;
    });
    File cropped = await ImageCropper.cropImage(
        sourcePath: _fileActa.path,
        // compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
          // showCropGrid: false,
          lockAspectRatio: false, // recuadro de recorte activo
          hideBottomControls: true,
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "RPS Cropper",
          statusBarColor: Colors.deepOrange.shade900,
          initAspectRatio: CropAspectRatioPreset.original,
          backgroundColor: Colors.white,
        ));
    if (cropped != null) {
      String value = await mlVisionProvider.readText(cropped);
      _validateConteo = mlVisionProvider.validarConteo(value);
    }
    if (cropped != null) {
      String salida = await mlVisionProvider.readText(cropped, 'conteo');
      this._validateConteo = false; //mlVisionProvider.validarUbicacion(salida);
      if (salida != "") {
        print('Salida: ' + salida);
        var cont = salida.split(',\n');
        this.conteos = List<ConteoModel>();
        for (var item in cont) {
          ConteoModel c = conteoModelFromJson(item);
          this.conteos.add(c);
        }
        this._validateConteo = true;
      }
    }
    this.setState(() {
      _fileConteo = cropped;
      _inProcess = false;
    });
  }

  void _procesarFotoMesa() async {
    this.setState(() {
      _inProcess = true;
    });
    File cropped = await ImageCropper.cropImage(
        sourcePath: _fileActa.path,
        compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
          lockAspectRatio: false, // recuadro de recorte activo
          hideBottomControls: true,
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "Captura Mesa",
          statusBarColor: Colors.deepOrange.shade900,
          initAspectRatio: CropAspectRatioPreset.original,
          backgroundColor: Colors.white,
        ));

    if (cropped != null) {
      String salida = await mlVisionProvider.readText(cropped, 'mesa');
      this._validateMesa = false; //mlVisionProvider.validarUbicacion(salida);
      if (salida != "") {
        this.mesa = mesaModelFromJson(salida);
        this._validateMesa = true;
      }
    }
    this.setState(() {
      _fileMesa = cropped;
      _inProcess = false;
    });
  }

  Widget _mostrarFoto() {
    return Container(
        child: Column(
      children: [
        Image(
          // si hay algo en Path (path!=null) muestra path caso contrario miestra 'assets/...'
          // _foto
          image: _fileActa != null
              ? FileImage(_fileActa)
              : AssetImage('assets/no-image.png'),
          height: 300.0,
          fit: BoxFit.cover,
        ),
        (_validateActa != null && !_validateActa)
            ? Container(
                padding: EdgeInsets.all(0.0),
                margin: EdgeInsets.all(0.0),
                child: ListTile(
                  title: Text(
                    'Seleccione una Acta',
                    style: TextStyle(color: Colors.red),
                  ),
                  // subtitle: Text('21-09-2020'),
                ),
                color: Colors.grey.shade200,
              )
            : Container(),
      ],
    ));

    // }
  }

  Widget _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.save),
      backgroundColor: Colors.deepPurple,
      onPressed: (_inProcess)
          ? null
          : _submit, //=> Navigator.pushNamed(context, 'producto'),
    );
  }

  bool validarDatos() {
    if (this._validateActa != null) {
      // salida = await mlVisionProvider.readText(this._fileActa, 'acta');
      // ActaModel acta = actaModelFromJson(salida);
      bool bandera = true; // existe acta en base de datos
    }
    return (this._validateConteo != null && this._validateConteo) &&
        (this._validateMesa != null && this._validateMesa) &&
        (this._validateActa != null && this._validateActa) &&
        (this._validateTotalVotos != null && this._validateTotalVotos) &&
        (this._validateUbicacion != null && this._validateUbicacion);
  }

  void _submit() async {
    //accion de guardar las actas
    if (!validarDatos()) {
      utils.mostrarAlerta(
          context, 'Mesaje Info.', 'Por favor Carge todas las Imagenes!');
    } else {
      setState(() {
        this._inProcess = true;
      });
      final acta = await this.facadeBloc.getActa(this.acta);
      print(acta);
      if (acta.fotoUrl == null) {
        // String salida = await mlVisionProvider.readText(this._fileUbicacion,
        //     'ubicacion'); // 'ubicacion', 'mesa', 'votosTotales', 'acta', 'conteo'
        // // // ubicaId = -MI5Di4s-5OPu8yZjZoa
        // UbicacionModel ubi = ubicacionModelFromJson(salida);
        String id = await this.facadeBloc.insertarUbicacion(this.ubicacion);
        this.ubicacion.id = id;
        // print('ubi: ' + ubicacionModelToJson(ubi));
        // // print('idUbi: ' + id);

        // salida = await mlVisionProvider.readText(this._fileMesa, 'mesa');
        // MesaModel mesa = mesaModelFromJson(salida);
        this.mesa.ubicacionId = id;
        id = await this.facadeBloc.insertarMesa(this.mesa);
        // print('mesa: ' + mesaModelToJson(mesa));
        // salida = await mlVisionProvider.readText(this._fileActa, 'acta');
        // ActaModel acta = actaModelFromJson(salida);
        this.acta.mesaId = id;
        final fileUrl =
            'https://res.cloudinary.com/dxfnjrouy/image/upload/v1602017179/hxrpdtrjjw6coaushtbd.jpg'; // await facadeBloc.subirFoto(this._fileActa);
        acta.fotoUrl = fileUrl;
        id = await facadeBloc.insertarActa(acta);
        this.acta.id = id;

        for (ConteoModel item in this.conteos) {
          item.actaId = '-MIMUt--yZo06VGtI1L5';
          await facadeBloc.insertarConteo(item);
        }
        _saveImageLocal();
      } else {
        utils.mostrarAlerta(
            context, 'Mesaje Info.', 'La acta ya fue registrado!');
      }

      setState(() {
        this._inProcess = false;
      });
    }
  }

  void _saveImageLocal() {
    GallerySaver.saveImage(this._fileConteo.path, albumName: 'appEleccion')
        .then((bool success) {
      print('Exito');
      print('bool: ' + success.toString());
      // setState(() {
      //   firstButtonText = 'image saved!';
      // });
    });
    GallerySaver.saveImage(this._fileMesa.path, albumName: 'appEleccion')
        .then((bool success) {
      print('Exito');
      print('bool: ' + success.toString());
      // setState(() {
      //   firstButtonText = 'image saved!';
      // });
    });
    GallerySaver.saveImage(this._fileUbicacion.path, albumName: 'appEleccion')
        .then((bool success) {
      print('Exito');
      print('bool: ' + success.toString());
      // setState(() {
      //   firstButtonText = 'image saved!';
      // });
    });

    GallerySaver.saveImage(this._fileTotalVotos.path, albumName: 'appEleccion')
        .then((bool success) {
      print('Exito');
      print('bool: ' + success.toString());
      // setState(() {
      //   firstButtonText = 'image saved!';
      // });
    });
  }
}
