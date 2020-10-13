import 'dart:async';

import 'package:app_elecciones2020/src/bloc/validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators {
  final _emailController = new BehaviorSubject<String>();
  final _passwordController = new BehaviorSubject<String>();

  //Recuperar los datos del Stream
  Stream<String> get emailSteam =>
      _emailController.stream.transform(validarEmail);
  Stream<String> get passwordSteam =>
      _passwordController.stream.transform(validarPassword);

  Stream<bool> get formValidStream =>
      Observable.combineLatest2(emailSteam, passwordSteam, (e, p) => true);

  //Insertar valores al Stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  dispose() {
    _emailController?.close();
    _passwordController?.close();
  }

  //GET para obtener el ultimo valor del emailController (StreamController)
  String get email => _emailController.value;
  String get password => _passwordController.value;
}
