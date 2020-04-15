import 'package:product_manager_with_map/pages/product_edit.page.dart';
import 'package:product_manager_with_map/pages/product_list.page.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:product_manager_with_map/widgets/ui_elements/logout_list_tile.widget.dart';
import 'package:flutter/material.dart';

class ProductsAdminPage extends StatelessWidget {
  final MainModel model;

  ProductsAdminPage(this.model);

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          title: Text('Choose'),
        ),
        ListTile(
          leading: Icon(Icons.shopping_basket),
          title: Text('Return to All Products'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        Divider(),
        LogoutListTile()
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // have to match (1)
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(tabs: <Widget>[
            // number of tabs have to match (1)
            Tab(
              icon: Icon(Icons.create),
              text: 'Create Products',
            ),
            Tab(icon: Icon(Icons.list), text: 'My Products'),
          ]),
        ),
        body: TabBarView(children: <Widget>[
          // number of tabs have to match (1)
          ProductEditPage(), // ADD
          ProductListPage(model), // UPDATE
        ]),
      ),
    );
  }
}
