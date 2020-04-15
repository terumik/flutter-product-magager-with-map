// 2. for inherit StatelessWidget
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/pages/auth.page.dart';
import 'package:product_manager_with_map/pages/product.page.dart';
import 'package:product_manager_with_map/pages/products.page.dart';
import 'package:product_manager_with_map/pages/products_admin.page.dart';
import 'package:product_manager_with_map/scoped-models/main.scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:product_manager_with_map/widgets/ui_elements/adaptive_theme_data.widget.dart';
import 'package:scoped_model/scoped_model.dart';
import 'widgets/helpers/custom_route.dart';

// flutter runs main() when it runs the app
void main() {
  //    * Debug Styling
  //    debugPaintSizeEnabled = true;
  //    debugPaintBaselinesEnabled = true;
  //    debugPaintPointersEnabled = true;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // HERE we instantiate ProductsModel ONLY ONCE, because main.dart encloses all widgets we need
    return ScopedModel<MainModel>(
      model: _model, // ScopedModel
      child: MaterialApp(
        title: 'ProductManager',
        //    * Debug Styling
        //  debugShowMaterialGrid: true,
        // note: get custom theme depend on hte platform
        theme: getAdaptiveThemeData(context),
        // home: AuthPage(),

        routes: {
          // you cant use home:... and '/' together
          '/': (BuildContext context) =>
              _isAuthenticated ? ProductsPage(_model) : AuthPage(),
          '/admin': (BuildContext context) {
            return _isAuthenticated ? ProductsAdminPage(_model) : AuthPage();
          },
        },

        // this code will run when the route is not registered in above routes{}
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }

          // settings hold the name we want to navigate to
          final List<String> pathElements = settings.name.split('/');
          // '/products/1' will be split like '', 'product'. '1'
          if (pathElements[0] != '') {
            // if no param (=invalid path)
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            _model.selectProduct(productId);

            // note: without custom animation
//						return MaterialPageRoute<bool>(
//							builder: (BuildContext context) =>
//								_isAuthenticated ? ProductPage(product) : AuthPage(),
//						);
            // note: with custom animation (fadein)
            return CustomRoute<bool>(
              builder: (BuildContext context) =>
                  _isAuthenticated ? ProductPage(product) : AuthPage(),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          // this will run when onGenerateRoute fails or return null
          return MaterialPageRoute(
            builder: (BuildContext context) =>
                _isAuthenticated ? ProductsPage(_model) : AuthPage(),
          );
        },
      ),
    );
  }
}
