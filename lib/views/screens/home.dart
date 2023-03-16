import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({Key? key}) : super(key: key);

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  // Completer<GoogleMapController> _controller = Completer();

  // static const LatLng _center =
  //     const LatLng(21.219547458497296, 72.91069872018382);
  //
  // final Set<Marker> _markers = {};
  //
  // LatLng _lastMapPosition = _center;
  //
  // MapType _currentMapType = MapType.normal;
  //
  // void _onMapTypeButtonPressed() {
  //   setState(() {
  //     _currentMapType = _currentMapType == MapType.normal
  //         ? MapType.satellite
  //         : MapType.normal;
  //   });
  // }
  //
  // void _onAddMarkerButtonPressed() {
  //   setState(() {
  //     _markers.add(Marker(
  //       // This marker id can be anything that uniquely identifies each marker.
  //       markerId: MarkerId(_lastMapPosition.toString()),
  //       position: _lastMapPosition,
  //       infoWindow: const InfoWindow(
  //         title: 'Really cool place',
  //         snippet: '5 Star Rating',
  //       ),
  //       icon: BitmapDescriptor.defaultMarker,
  //     ));
  //   });
  // }
  //
  // void _onCameraMove(CameraPosition position) {
  //   _lastMapPosition = position.target;
  // }
  //
  // void _onMapCreated(GoogleMapController controller) {
  //   _controller.complete(controller);
  // }

  final Completer<GoogleMapController> _controller = Completer();
  static LatLng sourceLocation =
      const LatLng(21.23031654440756, 72.89855742590278);
  static LatLng destination =
      const LatLng(21.224914682083675, 72.88514856293271);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  Future<void> getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
          (location) {},
        );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        setState(() {
          currentLocation = newLoc;
        });

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  Future<void> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      "AIzaSyCllTzWtFACvqdjqLEdrWCwa1vBysiSP7k",
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isEmpty) {
      setState(() {
        result.points.forEach(
          (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          ),
        );
      });
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      /*"assets/images/source.png"*/
      AutofillHints.addressCity,
    ).then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/images/destination.png",
    ).then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/current.png")
        .then((icon) {
      currentLocationIcon = icon;
      super.initState();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getPolyPoints();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: (currentLocation != null)
                ? LatLng(
                    currentLocation!.latitude as double,
                    currentLocation!.longitude as double,
                  )
                : const LatLng(0, 0),
            zoom: 13.5,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.red,
              width: 6,
            ),
          },
          markers: {
            Marker(
              icon: currentLocationIcon,
              markerId: const MarkerId("current Location"),
              position: (currentLocation != null)
                  ? LatLng(
                      currentLocation!.latitude as double,
                      currentLocation!.longitude as double,
                    )
                  : const LatLng(0, 0),
            ),
            Marker(
              icon: sourceIcon,
              markerId: const MarkerId("source"),
              position: sourceLocation,
            ),
            Marker(
              icon: destinationIcon,
              markerId: const MarkerId("destination"),
              position: destination,
            ),
          },
          onMapCreated: (mapController) {
            _controller.complete(mapController);
          },
        ),
      ),
    );
  }
}

//   body: currentLocation == null
//       ? const Center(
//           child: CircularProgressIndicator(),
//         )
//       : Container(
//           height: 250,
//           width: 250,
//           decoration: BoxDecoration(
//             border: Border.all(),
//           ),
//           child:
//         ),
// );

// appBar: AppBar(
//   title: const Text("Location"),
// ),
// body: Stack(
//   children: <Widget>[
//     // GoogleMap(
//     //   onMapCreated: _onMapCreated,
//     //   initialCameraPosition: CameraPosition(
//     //     target: _center,
//     //     zoom: 11.0,
//     //   ),
//     //   mapType: _currentMapType,
//     //   markers: _markers,
//     //   onCameraMove: _onCameraMove,
//     // ),
//
//     Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Align(
//         alignment: Alignment.topRight,
//         child: Column(
//           children: <Widget>[
//             FloatingActionButton(
//               onPressed: _onMapTypeButtonPressed,
//               materialTapTargetSize: MaterialTapTargetSize.padded,
//               backgroundColor: Colors.green,
//               child: const Icon(Icons.map, size: 36.0),
//             ),
//             const SizedBox(height: 16.0),
//             FloatingActionButton(
//               onPressed: _onAddMarkerButtonPressed,
//               materialTapTargetSize: MaterialTapTargetSize.padded,
//               backgroundColor: Colors.green,
//               child: const Icon(Icons.add_location, size: 36.0),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ],
// ),
