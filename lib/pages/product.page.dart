import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/pages/fullscreen_map.page.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:product_manager_with_map/widgets/products/address_tag.widget.dart';
import 'package:product_manager_with_map/widgets/ui_elements/title_default.widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:product_manager_with_map/widgets/products/product_fav.widget.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  Widget _buildAddressPriceRow(
      String address, double price, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: AddressTag(address),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return FullscreenMapPage(product);
                },
              ),
            );
          },
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              '|',
              style: TextStyle(color: Colors.black87),
            )),
        Text(
          '\$' + price.toString(),
          style: TextStyle(fontFamily: 'Oswald', color: Colors.black87),
        )
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(product.title),
//      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 256.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.title),
              background: Hero(
                // note: animation between product_card and product
                tag: product.id,
                child: FadeInImage(
                  placeholder: AssetImage('assets/background.jpg'),
                  height: 300.0,
                  fit: BoxFit.cover,
                  image: NetworkImage(product.image),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: TitleDefault(product.title),
              ),
              _buildAddressPriceRow(
                  product.location.address, product.price, context),
              // fixed: replace to product.location.address, product.price
              Container(
                margin: EdgeInsets.only(top: 10.0),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: ProductFav(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
        onWillPop: () {
          print('Back button pressed');
          // fixed: when you go to detail page -> press back button -> go edit page, edit widget shows up
          // I added this line below for fix above
          model.selectProduct(null);
          Navigator.pop(context, false);
          return Future.value(false); // 'true' makes app crushes
        },
        child: _buildPage(context),
      );
    });

    // THE CODE WAS BELOW BUT solved BY MYSELF DUE TO THE EDIT PRODUCT WIDGET ISSUE
    //		return WillPopScope(
    //      onWillPop: () {
    //        print('Back button pressed');
    //        Navigator.pop(context, false);
    //        return Future.value(false); // 'true' makes app crushes
    //      },
    //      child: _buildPage(),
    //    );
  }
}
