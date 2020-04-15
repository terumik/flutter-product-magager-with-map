import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:product_manager_with_map/widgets/products/product_card.widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {
  //  positional arg
  //  Products(this.products, {this.deleteProduct});

  //  default value for positional argument, use []
  //  Products([this.products = const []]);

  Widget _buildProductList(List<Product> products) {
    Widget productCards =
        Center(child: Text('No products found. Please add some.'));

    if (products.length > 0) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index]),
        itemCount: products.length,
      );
    }
    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        // executed whenever data in the scoped-model(<ProductsModel>) changes
        return _buildProductList(model.displayProducts);
      },
    );
  }
}
