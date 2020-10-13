import 'package:flutter/material.dart';
import 'package:app_elecciones2020/src/bloc/login_bloc.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';
import 'package:app_elecciones2020/src/providers/usuario_provider.dart';
import 'package:app_elecciones2020/src/utils/utils.dart' as utils;

class RegistroPage extends StatelessWidget {
  final usuarioProvider = new UsuarioProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _crearFondo(context),
        _loginForm(context),
      ],
    ));
  }

  Widget _crearFondo(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final fondoMorado = Container(
      height: size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
        Color.fromRGBO(63, 63, 156, 1.0),
        Color.fromRGBO(90, 70, 178, 1.0),
      ])),
    );

    final circulo = Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Color.fromRGBO(255, 255, 255, 0.05),
      ),
    );

    return Stack(
      children: <Widget>[
        fondoMorado,
        Positioned(
          top: 90.0,
          left: 30.0,
          child: circulo,
        ),
        Positioned(
          top: -40.0,
          right: -30.0,
          child: circulo,
        ),
        Positioned(
          bottom: -50.0,
          right: -10.0,
          child: circulo,
        ),
        Positioned(
          bottom: 120.0,
          right: 20.0,
          child: circulo,
        ),
        Positioned(
          bottom: -50.0,
          right: -20.0,
          child: circulo,
        ),
        Container(
          padding: EdgeInsets.only(top: 80.0),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.person_pin_circle,
                color: Colors.white,
                size: 100.0,
              ),
              SizedBox(
                height: 10.0,
                width: double.infinity,
              ),
              Text('David Torrez',
                  style: TextStyle(color: Colors.white, fontSize: 18.0)),
            ],
          ),
        )
      ],
    );
  }

  Widget _loginForm(BuildContext context) {
    final bloc = Provider.of(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
              height: 180.0,
            ),
          ),
          Container(
            width: size.width * 0.85,
            margin: EdgeInsets.symmetric(vertical: 30.0),
            padding: EdgeInsets.symmetric(vertical: 30.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0)
                ]),
            child: Column(
              children: <Widget>[
                Text(
                  'Registro de Usuario',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                _crearEmail(bloc),
                SizedBox(
                  height: 25.0,
                ),
                _crearPassword(bloc),
                SizedBox(
                  height: 25.0,
                ),
                _crearBoton(context, bloc),
              ],
            ),
          ),
          FlatButton(
            child: Text('¿Ya tienes cuenta? Login'),
            onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
          ),
          SizedBox(
            height: 50.0,
          )
        ],
      ),
    );
  }

  Widget _crearEmail(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailSteam,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // print(snapshot.data);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.alternate_email,
                  color: Colors.deepPurple,
                ),
                hintText: 'ejemplo@correo.com',
                labelText: 'Correo electronico',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeEmail,
            // onChanged: (value) => bloc.changeEmail(value),
          ),
        );
      },
    );
  }

  Widget _crearPassword(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordSteam,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot.data);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            // keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.lock_outline,
                  color: Colors.deepPurple,
                ),
                // hintText: 'ejemplo@correo.com',
                labelText: 'password',
                counterText: snapshot.data,
                errorText: snapshot.error),
            // onChanged: bloc.changePassword,
            onChanged: (value) => bloc.changePassword(value),
          ),
        );
      },
    );
  }

  Widget _crearBoton(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
        stream: bloc.formValidStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return RaisedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
              child: Text('Registrar'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 0.0,
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: snapshot.hasData ? () => _register(context, bloc) : null,
          );
        });
  }

  _register(BuildContext context, LoginBloc bloc) async {
    print('====================');
    print('Email: ${bloc.email}');
    print('Password: ${bloc.password}');
    print('====================');
    Map info = await usuarioProvider.nuevoUsuario(bloc.email, bloc.password);
    print('Map ${info.toString()}');
    if (info['ok']) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      utils.mostrarAlerta(context, 'Información incorrecta', info['mensaje']);
    }
  }
}
