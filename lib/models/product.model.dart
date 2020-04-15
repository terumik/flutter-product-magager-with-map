import 'package:product_manager_with_map/models/location_data.model.dart';
import 'package:flutter/material.dart';

// this is just a data model
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String imagePath;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final LocationData location;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.image,
    @required this.imagePath,
    @required this.userEmail,
    @required this.userId,
    @required this.location,
    this.isFavorite = false,
  });
}
