import 'package:smartrecord_app/src/model/route/route_point.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class RouteInfo {
  LatLng? northeast;
  LatLng? southwest;
  List<RoutePoint>? routePoints;

  RouteInfo({required this.northeast, required this.southwest, required this.routePoints});
}

Map<String, Object> lineTemplate(){
  return {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": []
        }
      }
    ]
  };
}