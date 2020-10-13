import 'package:app_elecciones2020/src/bloc/facade_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_elecciones2020/src/bloc/productos_bloc.dart';
export 'package:app_elecciones2020/src/bloc/login_bloc.dart';
import 'package:app_elecciones2020/src/bloc/login_bloc.dart';
export 'package:app_elecciones2020/src/bloc/login_bloc.dart';

class Provider extends InheritedWidget {
  static Provider _instancia;

  final loginBloc = new LoginBloc();

  final _productosBloc = new ProductosBloc();

  final _facadeBloc = new FacadeBloc();

  factory Provider({Key key, Widget child}) {
    if (_instancia == null) {
      _instancia = new Provider._internal(key: key, child: child);
    }

    return _instancia;
  }

  Provider._internal({Key key, Widget child}) : super(key: key, child: child);

  // Provider({Key key, Widget child})
  // : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LoginBloc of(BuildContext context) {
    // del contexto (arbol de widget) busca un widget con el mismo tipo (provider).
    // return (context.inheritFromWidgetOfExactType(Provider) as Provider).loginBloc;
    return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }

  static ProductosBloc productosBloc(BuildContext context) {
    // del contexto (arbol de widget) busca un widget con el mismo tipo (provider).
    // return (context.inheritFromWidgetOfExactType(Provider) as Provider).loginBloc;
    return context
        .dependOnInheritedWidgetOfExactType<Provider>()
        ._productosBloc;
  }

  static FacadeBloc facadeBloc(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>()._facadeBloc;
  }
}
