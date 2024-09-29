import 'dart:convert';

import 'package:bike_route_app/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

//const apiUrl = "470d-89-171-58-3.ngrok-free.app";
const apiUrl = "localhost:8000";

void main() {
  runApp(const MyApp());
}

// Make MyApp a StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late MapController mapController;

  final FocusNode focusNodeLong1 = FocusNode();
  final FocusNode focusNodeLat1 = FocusNode();
  final FocusNode focusNodeLong2 = FocusNode();
  final FocusNode focusNodeLat2 = FocusNode();

  final TextEditingController textControllerLong1 = TextEditingController();
  final TextEditingController textControllerLat1 = TextEditingController();
  final TextEditingController textControllerLong2 = TextEditingController();
  final TextEditingController textControllerLat2 = TextEditingController();

  GeoPoint? lastPoint1;
  GeoPoint? lastPoint2;

  FocusNode? lastActiveFocusNode;

  String? lastKey;

  void inputDataToLastActiveField(String lat, String long) {
    if (lastActiveFocusNode == focusNodeLong1 ||
        lastActiveFocusNode == focusNodeLat1) {
      textControllerLong1.text = long;
      textControllerLat1.text = lat;
    } else if (lastActiveFocusNode == focusNodeLong2 ||
        lastActiveFocusNode == focusNodeLat2) {
      textControllerLong2.text = long;
      textControllerLat2.text = lat;
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController(
      initPosition: GeoPoint(latitude: 50.0496833, longitude: 19.944544),
    );

    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        var data = mapController.listenerMapSingleTapping.value!;

        if (lastKey != null) {
          mapController.removeRoad(roadKey: lastKey!);
        }

        if (lastActiveFocusNode == focusNodeLong1 ||
            lastActiveFocusNode == focusNodeLat1) {
          if (lastPoint1 == null) {
            mapController.addMarker(data,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ));
          } else {
            mapController.changeLocationMarker(
                oldLocation: lastPoint1!, newLocation: data);
          }
          inputDataToLastActiveField(
              data.latitude.toString(), data.longitude.toString());
          lastPoint1 = data;
        } else if (lastActiveFocusNode == focusNodeLong2 ||
            lastActiveFocusNode == focusNodeLat2) {
          if (lastPoint2 == null) {
            mapController.addMarker(data,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 50.0,
                  ),
                ));
          } else {
            mapController.changeLocationMarker(
                oldLocation: lastPoint2!, newLocation: data);
          }
          inputDataToLastActiveField(
              data.latitude.toString(), data.longitude.toString());
          lastPoint2 = data;
        }
      }
    });
  }

  @override
  void dispose() {
    textControllerLong1.dispose();
    textControllerLat1.dispose();
    textControllerLong2.dispose();
    textControllerLat2.dispose();
    focusNodeLong1.dispose();
    focusNodeLat1.dispose();
    focusNodeLong2.dispose();
    focusNodeLat2.dispose();
    super.dispose();
  }

  void submit() async {
    if (lastKey != null) {
      mapController.removeRoad(roadKey: lastKey!);
    }

    var client = http.Client();
    try {
      var response = await client.post(Uri.http(apiUrl, 'get_path'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "origin_lat": textControllerLat1.text,
            "origin_lon": textControllerLong1.text,
            "dest_lat": textControllerLat2.text,
            "dest_lon": textControllerLong2.text
          }));

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      List<GeoPoint> road =
          (decodedResponse["path"] as List<dynamic>).map((coords) {
        var latLng = coords as List<dynamic>;
        return GeoPoint(latitude: latLng[0], longitude: latLng[1]);
      }).toList();

      lastKey = await mapController.drawRoadManually(
          road, const RoadOption(roadColor: Colors.green));
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CycloSafe Navigator'),
        ),
        body: Row(
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    const Text("Origin"),
                    const SizedBox(height: 5),
                    TextField(
                      focusNode: focusNodeLat1,
                      controller: textControllerLat1,
                      onTap: () {
                        setState(() {
                          lastActiveFocusNode = focusNodeLat1;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      focusNode: focusNodeLong1,
                      controller: textControllerLong1,
                      onTap: () {
                        setState(() {
                          lastActiveFocusNode = focusNodeLong1;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16), // Space between inputs
                    const Text("Destination"),
                    const SizedBox(height: 5),
                    TextField(
                      focusNode: focusNodeLat2,
                      controller: textControllerLat2,
                      onTap: () {
                        setState(() {
                          lastActiveFocusNode = focusNodeLat2;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      focusNode: focusNodeLong2,
                      controller: textControllerLong2,
                      onTap: () {
                        setState(() {
                          lastActiveFocusNode = focusNodeLong2;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Button
                    ElevatedButton(
                      onPressed: submit,
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 32),
                    // Add SVG and text in the same column
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      color: Colors.transparent, // Background color for the SVG
                      child: SvgPicture.asset(
                        'assets/logo2_final.svg',
                        height: 250,
                        width: 250,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'made by: QuantumQuirks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: OSmap(mapController),
            ),
          ],
        ),
      ),
    );
  }
}
