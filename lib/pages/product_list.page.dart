import 'package:product_manager_with_map/pages/product_edit.page.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// this page is embedded to product admin page, so no scaffold but JUST body
class ProductListPage extends StatefulWidget {
  final MainModel model;
  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState(){
    widget.model.getAllProducts(onlyForUser: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.allProducts[index].id);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return ProductEditPage();
            }),
          ).then((_) {
            model.selectProduct(null);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(model.allProducts[index].title),
            background: Container(
              color: Colors.red[100],
            ),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                model.selectProduct(model.allProducts[index].id);
                model.deleteProduct();
              }
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image)),
                  title: Text(model.allProducts[index].title),
                  subtitle:
                      Text('\$${model.allProducts[index].price.toString()}'),
                  trailing: _buildEditButton(context, index, model),
                ),
                Divider(color: Colors.black87),
              ],
            ),
          );
        },
        itemCount: model.allProducts.length,
      );
    });
  }
}
