import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:product_manager_with_map/widgets/products/address_tag.widget.dart';
import 'package:product_manager_with_map/widgets/products/price_tag.widget.dart';
import 'package:product_manager_with_map/widgets/ui_elements/title_default.widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // note: fit longer title in smaller width
            Flexible(
              child: TitleDefault(product.title),
              flex: 4,
            ),
            Flexible(
              child: SizedBox(
                width: 8.0,
              ),
              flex: 1,
            ),
            Flexible(
              child: PriceTag(product.price.toString()),
              flex: 2,
            ),
          ],
        ));
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.indigo,
            onPressed: () {
              model.selectProduct(product.id);
              Navigator.pushNamed<bool>(context, '/product/' + product.id);
              // note: solution for edit widget bug from lecture
              //              Navigator.pushNamed<bool>(
              //                  context, '/product/' + model.allProducts[productIndex].id)
              //                  .then((_)=>model.selectProduct(null)
              //              );
            },
          ),
          IconButton(
              // fixed: fav status is not reflected in fav list.
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Colors.redAccent,
              onPressed: () {
                model.selectProduct(product.id);
                // note: I added this arg (false) for fix edit widget bug
                model.toggleProductFavStatus(true);
              }),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            // note: animation between product_card and product
            tag: product.id,
            child: // for local image
                // Image.asset(product.image),
                FadeInImage(
              placeholder: AssetImage('assets/background.jpg'),
              height: 300.0,
              fit: BoxFit.cover,
              image: NetworkImage(product.image),
            ),
          ),
          _buildTitlePriceRow(),
          SizedBox(
            height: 8.0,
          ),
          AddressTag(product.location.address),
          // fixed: replace to product.location.address
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
