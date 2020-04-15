//import 'package:flutter/material.dart';
//
//class ProductControl extends StatelessWidget {
//  final Function addProduct;
//
//  ProductControl(this.addProduct);
//  // *** method _addProduct() passed from ProductManager
//  // pass data happened in child(pControl) to its parent(pManager),
//  // pass function DOWN to its child
//
//  @override
//  Widget build(BuildContext context) {
//    return RaisedButton(
//        color: Theme.of(context).buttonColor,
//        onPressed: () {
//          // event onPressed button
//          addProduct({'title': 'Curry', 'image': 'assets/curry.jpg'});
//        },
//        child: Text('Add Product'));
//  }
//}
