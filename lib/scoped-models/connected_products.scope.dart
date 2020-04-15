import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:product_manager_with_map/models/auth.model.dart';
import 'package:product_manager_with_map/models/location_data.model.dart';
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/models/user.model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';

// this scoped model is connecting product info and user info
mixin ConnectedProductsModel on Model {
	List<Product> _products = [];
	String _selProductId;
	User _authenticatedUser;
	bool _isLoading = false;
} //ConnectedProductsModel

mixin ProductsModel on ConnectedProductsModel {
	bool _showFavs = false;

	// getter
	List<Product> get allProducts {
		// return copy of the list in order to prevent model._product.add() in any files
		// (because List is reference type)
		return List.from(_products);
	}

	List<Product> get displayProducts {
		if (_showFavs) {
			List<Product> favedProducts =
			_products.where((Product p) => p.isFavorite).toList();
			return favedProducts;
		}
		return List.from(_products);
	}

	String get selectedProductId {
		return _selProductId;
	}

	Product get selectedProduct {
		if (selectedProductId == null) {
			return null;
		}
		return _products.firstWhere((Product product) {
			return product.id == _selProductId;
		});
	}

	bool get displayFavsOnly {
		return _showFavs;
	}

	int get selectedProductIndex {
		// indexWhere returns -1 if no product found
		return _products.indexWhere((Product product) {
			return product.id == selectedProductId;
		});
	}

	void selectProduct(String productId) {
		_selProductId = productId;
		if (productId != null) {
			notifyListeners();
		}
	}

	// CRUD
	Future<Null> getAllProducts({onlyForUser = false}) {
		_isLoading = true;

		// clear the products in edit mode
		if(onlyForUser){
			_products = [];
		}

		notifyListeners();

		return http
			.get(
			'https://flutter-course-27b5a.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
			.then<Null>((http.Response res) {
			// print(json.decode(res.body));

			final List<Product> fetchedProductList = [];
			final Map<String, dynamic> productListData = json.decode(res.body);
			if (productListData == null) {
				_isLoading = false;
				notifyListeners();
				return;
			}
			productListData.forEach((String productId, dynamic productData) {
				final Product product = Product(
					id: productId,
					title: productData['title'],
					description: productData['description'],
					image: productData['imageUrl'],
					imagePath: productData['imagePath'],
					price: productData['price'],
					location: LocationData(
						address: productData['loc_address'],
						longitude: productData['loc_lng'],
						latitude: productData['loc_lat']),
					userEmail: productData['userEmail'],
					userId: productData['userId'],
					isFavorite: productData['wishlistUsers'] == null
						? false
						: (productData['wishlistUsers'] as Map<String, dynamic>)
						.containsKey(_authenticatedUser.id));

				fetchedProductList.add(product);
			});

			// replace locally stored list to fetched list
			// this .where statement is sorting product list LOCALLY. this should be done in backend generally
			_products = onlyForUser
				? fetchedProductList.where((Product p) {
				return p.userId == _authenticatedUser.id;
			}).toList()
				: fetchedProductList;
			_isLoading = false;
			notifyListeners();
			_selProductId = null;
		}).catchError((error) {
			_isLoading = false;
			notifyListeners();
			return;
		});
	}

	Future<Map<String, dynamic>> uploadImage(File image,
		{String imagePath}) async {
		final mimeTypeData = lookupMimeType(image.path).split('/');
		final imageUploadRequest = http.MultipartRequest(
			'POST',
			Uri.parse(
				'https://us-central1-flutter-course-27b5a.cloudfunctions.net/storeImage'));

		final file = await http.MultipartFile.fromPath(
			'image',
			image.path,
			contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
		);
		imageUploadRequest.files.add(file);
		if (imagePath != null) {
			imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
		}
		imageUploadRequest.headers['Authorization'] =
		'Bearer ${_authenticatedUser.token}';

		try {
			final streamedRes = await imageUploadRequest.send();
			final res = await http.Response.fromStream(streamedRes);
			if (res.statusCode != 200 && res.statusCode != 201) {
				print('something went wrong');
				print(res.statusCode);
				print(json.decode(res.body));
				return null;
			}
			final resData = json.decode(res.body);
			print(resData);
			return resData;
		} catch (error) {
			print(error);
			return null;
		}
	}

	Future<bool> addProduct(String title, String description, File image,
		double price, LocationData locData) async {
		_isLoading = true;
		notifyListeners();

		final uploadedData = await uploadImage(image);
		if (uploadedData == null) {
			print('Image upload failed');
			return false;
		}

		final Map<String, dynamic> productData = {
			'title': title,
			'description': description,
			'price': price,
			'userEmail': _authenticatedUser.email,
			'userId': _authenticatedUser.id,
			'imagePath': uploadedData['imagePath'],
			'imageUrl': uploadedData['imageUrl'],
			'loc_address': locData.address,
			'loc_lat': locData.latitude,
			'loc_lng': locData.longitude
		};

		try {
			final http.Response res = await http.post(
				'https://flutter-course-27b5a.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
				body: json.encode(productData));

			if (res.statusCode != 200 && res.statusCode != 201) {
				_isLoading = false;
				notifyListeners();
				return false;
			}

			final Map<String, dynamic> resData = json.decode(res.body);
			final newProduct = Product(
				id: resData['name'],
				// id created by server
				title: title,
				description: description,
				image: uploadedData['imageUrl'],
				imagePath: uploadedData['imagePath'],
				price: price,
				location: locData,
				userEmail: _authenticatedUser.email,
				userId: _authenticatedUser.id);
			_products.add(newProduct);
			_isLoading = false;
			notifyListeners();
			return true;
		} catch (error) {
			_isLoading = false;
			notifyListeners();
			return false;
		}
	}

	Future<bool> updateProduct(String title, String description, File image,
		double price, LocationData locData) async {
		_isLoading = true;
		notifyListeners();

		String imageUrl = selectedProduct.image;
		String imagePath = selectedProduct.imagePath;
		if (image != null) {
			final uploadData = await uploadImage(image);
			if(uploadData == null){
				print('Upload failed');
				return false;
			}

			imageUrl = uploadData['imageUrl'];
			imagePath = uploadData['imagePath'];
		}

		final Map<String, dynamic> updatedData = {
			'title': title,
			'description': description,
			'imageUrl': imageUrl,
			'imagePath': imagePath,
			'price': price,
			'userEmail': selectedProduct.userEmail,
			'userId': selectedProduct.userId,
			'loc_address': locData.address,
			'loc_lat': locData.latitude,
			'loc_lng': locData.longitude
		};

		try {
			await http.put(
				'https://flutter-course-27b5a.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
				body: json.encode(updatedData));
			_isLoading = false;
			final updatedProduct = Product(
				id: selectedProduct.id,
				title: title,
				description: description,
				image: imageUrl,
				imagePath: imagePath,
				price: price,
				location: locData,
				userEmail: selectedProduct.userEmail,
				userId: selectedProduct.userId,
				isFavorite: selectedProduct.isFavorite);
			final int selectedProductIndex = _products.indexWhere((Product product) {
				return product.id == selectedProductId;
			});

			_products[selectedProductIndex] = updatedProduct;
			notifyListeners();
			return true;
		} catch (error) {
			_isLoading = false;
			notifyListeners();
			return false;
		}
	}

	Future<bool> deleteProduct() {
		_isLoading = true;
		final deletedProductId = selectedProduct.id;

		_products.removeAt(selectedProductIndex);
		_selProductId = null;
		notifyListeners();
		return http
			.delete(
			'https://flutter-course-27b5a.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
			.then((http.Response res) {
			_isLoading = false;
			notifyListeners();
			return true;
		}).catchError((error) {
			_isLoading = false;
			notifyListeners();
			return false;
		});
	}

	// note: I added (bool setIdNull) arg for fixing edit widget bug
	void toggleProductFavStatus(bool setIdNull) async {
		final bool isCurrentlyFav = selectedProduct.isFavorite;
		final bool newFavStatus = !isCurrentlyFav;

		final Product updatedProduct = Product(
			id: selectedProduct.id,
			title: selectedProduct.title,
			description: selectedProduct.description,
			price: selectedProduct.price,
			image: selectedProduct.image,
			imagePath: selectedProduct.imagePath,
			location: selectedProduct.location,
			userId: selectedProduct.userId,
			userEmail: selectedProduct.userEmail,
			isFavorite: newFavStatus,
		);
		_products[selectedProductIndex] = updatedProduct;
		// for live update (for changes that visually affect to the page immediately)
		notifyListeners();
		http.Response res;
		if (newFavStatus) {
			res = await http.put(
				'https://flutter-course-27b5a.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
				body: jsonEncode(true));
		} else {
			res = await http.delete(
				'https://flutter-course-27b5a.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
		}
		if (res.statusCode != 200 && res.statusCode != 201) {
			final Product updatedProduct = Product(
				id: selectedProduct.id,
				title: selectedProduct.title,
				description: selectedProduct.description,
				price: selectedProduct.price,
				image: selectedProduct.image,
				imagePath: selectedProduct.imagePath,
				location: selectedProduct.location,
				userId: selectedProduct.userId,
				userEmail: selectedProduct.userEmail,
				isFavorite: !newFavStatus,
			);
			_products[selectedProductIndex] = updatedProduct;
			notifyListeners();
		}

		if(setIdNull){
			// note: I added this line in order to fix edit widget bug in create mode
			_selProductId = null;
		}

		notifyListeners();
	}

	void toggleDisplayMode() {
		_showFavs = !_showFavs;
		// note: I added this line in order to fix edit widget bug in create mode
		_selProductId = null;
		notifyListeners();
	}
} // ProductsModel

mixin UserModel on ConnectedProductsModel {
	Timer _authTimer;
	PublishSubject<bool> _userSubject =
	PublishSubject(); // to manually push the event

	User get user {
		return _authenticatedUser;
	}

	PublishSubject<bool> get userSubject {
		return _userSubject;
	}

	Future<Map<String, dynamic>> authenticate(String email, String password,
		[AuthMode mode = AuthMode.Login]) async {
		_isLoading = true;
		notifyListeners();

		final Map<String, dynamic> authData = {
			'email': email,
			'password': password,
			'returnSecureToken': true
		};
		http.Response res;

		if (mode == AuthMode.Login) {
			res = await http.post(
				'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAaLZCgHM23-tCqbBu0loDN-r_AbToMs2M',
				body: jsonEncode(authData),
				headers: {'Content-Type': 'application/json'});
		} else {
			res = await http.post(
				'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAaLZCgHM23-tCqbBu0loDN-r_AbToMs2M',
				body: jsonEncode(authData),
				headers: {'Content-Type': 'application/json'});
		}

		final Map<String, dynamic> resData = json.decode(res.body);
		bool hasError = true;
		String message = 'Something went wrong.';
		if (resData.containsKey('idToken')) {
			hasError = false;
			message = 'Authentication succeeded.';
			_authenticatedUser =
				User(id: resData['localId'], email: email, token: resData['idToken']);
			setAuthTimeout(int.parse(resData['expiresIn']));
			_userSubject.add(true);
			final DateTime now = DateTime.now();
			final DateTime expiryTime =
			now.add(Duration(seconds: int.parse(resData['expiresIn'])));

			final SharedPreferences prefs = await SharedPreferences.getInstance();
			prefs.setString('token', resData['idToken']);
			prefs.setString('userEmail', email);
			prefs.setString('userId', resData['localId']);
			prefs.setString('expiryTime', expiryTime.toIso8601String());
		} else if (resData['error']['message'] == 'EMAIL_NOT_FOUND') {
			message = 'This email does not exist.';
		}
		_isLoading = false;
		notifyListeners();
		return {'error': hasError, 'message': message};
	}

	void autoAuthenticate() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		final String token = prefs.getString('token');
		final String expiryTimeString = prefs.getString('expiryTime');
		if (token != null) {
			final DateTime now = DateTime.now();
			final parsedExpiryTime = DateTime.parse(expiryTimeString);
			if (parsedExpiryTime.isBefore(now)) {
				_authenticatedUser = null;
				notifyListeners();
				return;
			}
			final String userEmail = prefs.getString('userEmail');
			final String userId = prefs.getString('userId');
			final tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
			_authenticatedUser = User(id: userId, email: userEmail, token: token);
			_userSubject.add(true);
			setAuthTimeout(tokenLifespan);
			notifyListeners();
		}
	}

	void logout() async {
		print('Logged Out');
		_authenticatedUser = null;
		_authTimer.cancel();
		_userSubject.add(false);
		_selProductId = null;
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.remove('token');
		prefs.remove('userEmail');
		prefs.remove('userId');
	}

	void setAuthTimeout(int time) {
		_authTimer = Timer(Duration(seconds: time), logout);
	}
}

mixin UtilityModel on ConnectedProductsModel {
	bool get isLoading {
		return _isLoading;
	}
}
