//import 'package:flutter/material.dart';
//
//import 'package:first_app/widgets/products/products.scope.dart';
//import 'package:first_app/product_control.dart';
//
//class ProductManager extends StatelessWidget {
////  final Map<String, String> startingProduct;
////
////  // to create a named argument, use {}
////  // (now if you instantiate ProductManager,
////  // you'll pass value by ProductManager(startingProduct: value))
//////  ProductManager({this.startingProduct = 'Default Tester'});
////    ProductManager({this.startingProduct});
////
////
////    @override
////  State<StatefulWidget> createState() {
////    return _ProductManagerState();
////  }
////}
////
////class _ProductManagerState extends State<ProductManager> {
////  // property
////  //  List<String> _products = ['Food Tester']; // string[]
////  List<Map<String, String>> _products = [];
////
////  @override
////  void initState() {
////    // like onInit()
////    super.initState();
////    if(widget.startingProduct != null) {
////        _products.add(widget.startingProduct);
////    }
////
////    // widget.prop can access to the properties belongs to the state
////  }
////
//
//  final List<Map<String, dynamic>> products;
//
//  ProductManager(this.products);
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(children: [
//      Expanded(
//        child: Products(products),
//      ) // re-construct the Product
//    ]);
//  }
//}
