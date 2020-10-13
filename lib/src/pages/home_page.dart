import 'package:app_elecciones2020/src/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:app_elecciones2020/src/bloc/productos_bloc.dart';
import 'package:app_elecciones2020/src/bloc/provider.dart';
import 'package:app_elecciones2020/src/models/producto_model.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productosBloc = Provider.productosBloc(context);
    productosBloc.cargarProductos();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.backspace),
            onPressed: () {
              Navigator.pushNamed(context, 'home2');
            },
          )
        ],
      ),
      drawer: MenuWidget(),
      body: _crearListado(productosBloc),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _crearListado(ProductosBloc productosBloc) {
    // productosBloc.cargarProductos();
    // initialData: Resource<String>.idle(),
    // builder:
    // (BuildContext context, AsyncSnapshot<Resource<String>> snapshot)
    return new StreamBuilder<List<ProductoModel>>(
        stream: productosBloc.productosStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductoModel>> snapshot) {
          if (snapshot.hasData) {
            final productos = snapshot.data;
            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (BuildContext context, int i) =>
                  _crearItem(context, productosBloc, productos[i]),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _crearItem(BuildContext context, ProductosBloc productosBloc,
      ProductoModel producto) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(color: Colors.red),
        onDismissed: (direccion) => productosBloc.borrarProducto(producto.id),
        child: Card(
          child: Column(
            children: <Widget>[
              (producto.fotoUrl == null)
                  ? Image(
                      image: AssetImage('assets/no-image.png'),
                    )
                  : FadeInImage(
                      image: NetworkImage(producto.fotoUrl),
                      placeholder: AssetImage('assets/jar-loading.gif'),
                      height: 300.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              ListTile(
                title: Text('${producto.titulo} - ${producto.valor}'),
                subtitle: Text(producto.id +
                    ' - Disponible: ' +
                    producto.disponible.toString()),
                onTap: () => Navigator.pushNamed(context, 'producto',
                    arguments: producto),
              ),
            ],
          ),
        ));
  }

  Widget _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.deepPurple,
      onPressed: () => Navigator.pushNamed(context, 'producto'),
    );
  }
}
