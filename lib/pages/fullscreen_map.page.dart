import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:product_manager_with_map/models/product.model.dart';

class FullscreenMapPage extends StatefulWidget {
	final Product product;
	FullscreenMapPage(this.product);
	@override
	_FullscreenMapPageState createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<FullscreenMapPage> {
	Completer<GoogleMapController> _googleMapController = Completer();

	@override
	Widget build(BuildContext context) {
		Set<Marker> _markers = {
		Marker(
			position: LatLng(
				widget.product.location.latitude,
				widget.product.location.longitude,
			),
			markerId: MarkerId('markerId'),
			infoWindow: InfoWindow(
				title: widget.product.title,
				snippet: widget.product.location.address),
		)
		};

		return Scaffold(
			appBar: AppBar(
				title: Text('Product Location'),
			),
			body: GoogleMap(
				markers: _markers,
				myLocationEnabled: true,
				initialCameraPosition: CameraPosition(
					target: LatLng(
						widget.product.location.latitude,
						widget.product.location.longitude,
					),
					zoom: 14),
				onMapCreated: _onMapCreated,
			),
		);
	}

	void _onMapCreated(GoogleMapController controller) {
		_googleMapController.complete(controller);
	}
}
