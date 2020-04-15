import 'dart:async';
import 'dart:convert';

import 'package:product_manager_with_map/models/location_data.model.dart';
import 'package:product_manager_with_map/models/product.model.dart';
import 'package:product_manager_with_map/widgets/helpers/ensure_visible.widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as geoloc;
import 'package:product_manager_with_map/shared/global_config.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;

  final Product product;
  final TextEditingController _addressInputController = TextEditingController();

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  LocationData _locationData;

  GoogleMap _googleMap;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      print(widget.product);

      _getStaticMap(widget.product.location.address, geocode: false);
    }

    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    // GEOCODE from user entered val
    if (address.isEmpty) {
      setState(() {
        _googleMap = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      // todo: map(geocode) currently does not work because of OVER_QUERY LIMIT. enable those 6 lines when for the real project
//       final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
//           {'address': address, 'key': googleMapApiKey});
//       final http.Response res = await http.get(uri);
//       final decodedRes = json.decode(res.body);
//       final formattedAddress = decodedRes['results'][0]['formatted_address'];
//       final coordinates = decodedRes['results'][0]['geometry']['location'];

      final formattedAddress = "Tokyo Station, Japan";
      final coordinates = {'lat': 35.675163, 'lng': 139.766830};
      _locationData = LocationData(
          address: formattedAddress,
          latitude: coordinates['lat'],
          longitude: coordinates['lng']);
    } else if (lat == null && lng == null) {
      _locationData = widget.product.location;
    } else {
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    }

    // STATIC MAP
    // fixed: get static map somehow with another dart package
    if (mounted) {
      Map<MarkerId, Marker> markers =
          <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
      CameraPosition initialCameraPosition = CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 15,
      );

      final MarkerId markerId = MarkerId('somehowGenerateUniqueId');
      final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(_locationData.latitude, _locationData.longitude));

      widget.setLocation(_locationData);

      setState(() {
        _addressInputController.text = _locationData.address;
        // adding a new marker to map
        markers[markerId] = marker;
      });

      final googleMap = GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        markers: Set<Marker>.of(markers.values),
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      );

      _googleMap = googleMap;
    }
  }

  // fixed: update camera when tap the button.
  // todo: may have better way to do this?
  Future<void> _moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 15)));
  }

  Future<String> _getAddress(double lat, double lng) async {
    // todo: map(geocode) currently does not work because of OVER_QUERY LIMIT. enable those 6 lines when for the real project
//        final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
//          'latlng': '${lat.toString()},${lng.toString()}',
//          'key': googleMapApiKey
//        });
//
//        final http.Response res = await http.get(uri);
//        final decodesRes = json.decode(res.body);
//        final formattedAddress = decodesRes['results'][0]['formatted_address'];
    final formattedAddress = 'Chiba, Japan';
    return formattedAddress;
  }

  void _getUserLocation() async {
    // fixed: implement "use current location"
    final location = geoloc.Location();
    final currentLocation = await location.getLocation();
    final address =
        await _getAddress(currentLocation.latitude, currentLocation.longitude);
    _getStaticMap(address,
        geocode: false,
        lat: currentLocation.latitude,
        lng: currentLocation.longitude);
  }

  // call _getStaticMap when blur
  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      print('updateLocation() had lost focus');
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            decoration: InputDecoration(labelText: 'Address'),
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlineButton(
                  child: Text('Use My Current Location'),
                  textColor: Theme.of(context).accentColor,
                  borderSide: BorderSide(
                      color: Theme.of(context).accentColor, width: 2.0),
                  onPressed: _getUserLocation),
            ),
            SizedBox(
              width: 5
            ),
            Expanded(
              child: OutlineButton(
                  child: Text('Show Address in Map'),
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                  onPressed: _moveCamera),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        _googleMap == null
            ? Text('No map to display.')
            : Container(
                child: _googleMap,
                width: 400,
                height: 400,
              ),
      ],
    );
  }
}
