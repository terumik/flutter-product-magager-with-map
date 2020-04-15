import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:product_manager_with_map/widgets/form_inputs/image.widget.dart';
import 'package:product_manager_with_map/widgets/form_inputs/location.widget.dart';
import 'package:product_manager_with_map/widgets/helpers/ensure_visible.widget.dart';
import 'package:flutter/material.dart';
import 'package:product_manager_with_map/widgets/ui_elements/adaptive_progress_indicators.wodget.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:product_manager_with_map/models/location_data.model.dart';

// this page is embedded to product admin page, so no scaffold but JUST body
class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

// note: there are two solutions for fixing scrolling bug for TextField

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  // this is for solution 2 (scrolling bug for TextField)
  //  final _titleTextController = TextEditingController();

  Widget _buildTitleTextField(Product product) {
    // those conditions are for solution 2
    //    if (product == null && _titleTextController.text.trim() == '') {
    //      _titleTextController.text = '';
    //    } else if (product != null && _titleTextController.text.trim() == '') {
    //      _titleTextController.text = product.title;
    //    }

    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        //  controller: _titleTextController,
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
          labelText: 'Product Title',
        ),
        // you need to remove the line below for solution 2
        initialValue: product == null ? '' : product.title,
        validator: (String value) {
          if (value.isEmpty || value.length < 3) {
            return 'Title is required, should be more than 3 charactors.';
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        decoration: InputDecoration(labelText: 'Product Description'),
        maxLines: 3,
        initialValue: product == null ? '' : product.description,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Description is required, should be more than 5 charactors.';
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildPriceTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        decoration: InputDecoration(labelText: 'Price'),
        keyboardType: TextInputType.number,
        initialValue: product == null ? '' : product.price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'Price is required, should be a number.';
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          _formData['price'] = double.parse(value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(
                // note: platform specific
                child: AdaptiveProgressIndicators(),
              )
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.9;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
        onTap: () {
          // to close keyboard
          FocusScope.of(context).requestFocus(FocusNode());
        },
        // fixed: bug for form fields loose data when scrolled out of view
        // Solution 1: use SingleChildScrollView instead of ListView
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: new Column(
              children: <Widget>[
                _buildTitleTextField(product),
                _buildDescriptionTextField(product),
                _buildPriceTextField(product),
                SizedBox(
                  height: 10.0,
                ),
                LocationInput(_setLocation, product),
                SizedBox(
                  height: 10.0,
                ),
                ImageInput(_setImage, product),
                SizedBox(
                  height: 10.0,
                ),
                _buildSubmitButton(),
              ],
            )),
          ),
        ));
    // Solution 2: Use TextEditingController
    //      child: Container(
    //        margin: EdgeInsets.all(10.0),
    //        child: Form(
    //            key: _formKey,
    //            child: ListView(
    //              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
    //              children: <Widget>[
    //                _buildTitleTextField(product),
    //                _buildDescriptionTextField(product),
    //                _buildPriceTextField(product),
    //                SizedBox(
    //                  height: 10.0,
    //                ),
    //                // fixed: display static map by location.widget. disabled for compiling for now
    //                LocationInput(_setLocation, product),
    //                SizedBox(
    //                  height: 10.0,
    //                ),
    //                _buildSubmitButton(),
    //              ],
    //            )),
    //      ),
    //    );
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save(); // fire _buildTitleTextField.onSaved()
    // check create/edit
    if (selectedProductIndex == -1) {
      addProduct(
        _formData['title'],
        // solution 2
        // _titleTextController.text,
        _formData['description'],
        _formData['image'],
        _formData['price'],
        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again later'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateProduct(
        _formData['title'],
        // solution 2
        // _titleTextController.text,
        _formData['description'],
        _formData['image'],
        _formData['price'],
        _formData['location'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/products')
            .then((_) => setSelectedProduct(null));
      });
    }
  }

  // focus on UI in build method. outsource widget/methods above
  @override
  Widget build(BuildContext context) {
    // check create mode or edit mode
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
