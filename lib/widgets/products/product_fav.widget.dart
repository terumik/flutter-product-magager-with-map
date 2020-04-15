import 'package:flutter/material.dart';
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ProductFav extends StatefulWidget {
  final Product product;

  const ProductFav(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFavState();
  }
}

class _ProductFavState extends State<ProductFav> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 70,
            width: 56,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.0, 1.0, curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'contact',
                mini: true,
                onPressed: () async {
                  final url = 'mailto:${widget.product.userEmail}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch mailer';
                  }
                },
                child: Icon(
                  Icons.mail,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          Container(
            height: 70,
            width: 56,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.0, 0.4, curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'favorite',
                mini: true,
                onPressed: () {
                  // note: I added this arg (false) for fix edit widget bug
                  model.toggleProductFavStatus(false);
                },
                child: Icon(
                  model.selectedProduct.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          FloatingActionButton(
              heroTag: 'options',
              onPressed: () {
                if (_animationController.isDismissed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.rotationZ(
                          _animationController.value * 0.5 * math.pi),
                      child: Icon(_animationController.isDismissed
                          ? Icons.more_vert
                          : Icons.close),
                    );
                  }))
        ],
      );
    });
  }
}
