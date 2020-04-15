import 'package:product_manager_with_map/scoped-models/connected_products.scope.dart';
import 'package:scoped_model/scoped_model.dart';

// to marge two different scoped models
class MainModel extends Model
    with ConnectedProductsModel, UserModel, ProductsModel, UtilityModel {}
