import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';

class Rescue extends StatefulWidget {
  const Rescue({Key? key}) : super(key: key);

  @override
  State<Rescue> createState() => _RescueState();
}

class _RescueState extends State<Rescue> {
  HereMapController? _controller;
  MapPolyline? _mapPolyline;

  @override
  void dispose() {
    _controller?.finalize();
    super.dispose();
  }

  Future<void> drawRedDot(HereMapController hereMapController, int drawOrder,
      GeoCoordinates geoCoordinates) async {
    ByteData fileData = await rootBundle.load('assets/images/circle.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);

    Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawPin(HereMapController hereMapController, int drawOrder,
      GeoCoordinates geoCoordinates) async {
    ByteData fileData = await rootBundle.load('assets/images/poi.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);
    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, mapImage, anchor2D);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawRoute(GeoCoordinates start, GeoCoordinates end,
      HereMapController hereMapController) async {
    RoutingEngine routingEngine = RoutingEngine();

    Waypoint startWayPoint = Waypoint.withDefaults(start);
    Waypoint endWayPoint = Waypoint.withDefaults(end);
    List<Waypoint> wayPoints = [startWayPoint, endWayPoint];

    routingEngine.calculateCarRoute(wayPoints, CarOptions(),
        (routingError, routes) {
      if (routingError == null) {
        var route = routes!.first;

        GeoPolyline routeGeoPolyLine = route.geometry;

        double depth = 20;
        _mapPolyline = MapPolyline(routeGeoPolyLine, depth, Colors.blue);

        hereMapController.mapScene.addMapPolyline(_mapPolyline!);
      }
    });
  }

  void _onMapCreated(HereMapController hereMapController) {
    _controller = hereMapController;

    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      drawRedDot(hereMapController, 0, GeoCoordinates(1.1186256, 104.0485472));
      drawPin(hereMapController, 1, GeoCoordinates(1.1186256, 104.0485472));
      drawRoute(GeoCoordinates(1.1186256, 104.0485472),
          GeoCoordinates(1.109335, 104.0322086), hereMapController);

      const double distanceToEarthInMeters = 8000;
      MapMeasure mapMeasureZoom =
          MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
      hereMapController.camera.lookAtPointWithMeasure(
          GeoCoordinates(1.1186256, 104.0485472), mapMeasureZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 570,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: HereMap(
                  onMapCreated: _onMapCreated,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_mapPolyline != null) {
                  _controller!.mapScene.removeMapPolyline(_mapPolyline!);
                  _mapPolyline = null;
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              child: Text(
                "Clear Map",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
