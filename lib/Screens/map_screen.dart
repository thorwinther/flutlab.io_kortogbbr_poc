import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

//test

// SAMPLE URL:
// 'https://services.datafordeler.dk/DKskaermkort/topo_skaermkort_wmts/1.0.0/Wmts?USERNAME=MBAWETWOSQ&PASSWORD=HestPlastikMule!985&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&FORMAT=image%2Fjpeg&LAYER=topo_skaermkort&STYLE=default&TILEMATRIXSET=View1&TILEMATRIX=0&TILEROW=0&TILECOL=1',

class MapScreen extends StatefulWidget {
  const MapScreen({required this.title});
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var epsg25832CRS;
  var maxZoom;

  var point;
  var point_transformed;
  // EPSG:4326 is a predefined projection ships with proj4dart?
  var epsg3857 = proj4.Projection.get('EPSG:3857')!;

  @override
  void initState() {
    var epsg25832 = proj4.Projection.add(
        'EPSG:25832', '+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs');

    // zoom level resolutions
    final resolutions = <double>[
      32768,
      16384,
      8192,
      4096,
      2048,
      1024,
      512,
      256,
      128,
      64,
      32,
      16,
      8,
      4
    ];

    final epsg3413Bounds = Bounds<double>(
      const CustomPoint<double>(-4511619.0, -4511336.0),
      const CustomPoint<double>(4510883.0, 4510996.0),
    );

    maxZoom = (resolutions.length - 1).toDouble();

    epsg25832CRS = Proj4Crs.fromFactory(
      code: 'EPSG:25832',
      proj4Projection: epsg25832,
      resolutions: resolutions,
      origins: [CustomPoint(0, 0)],
      bounds: epsg3413Bounds,
      scales: null,
      transformation: null,
    );

    // Define start point
    doTransformationStuff(epsg25832);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 800,
            child: FlutterMap(
              options: MapOptions(
                crs: epsg25832CRS,
                center: LatLng(-15.343678, 88.97539), // Center of Copenhagen???
                zoom: 10,
                maxZoom: maxZoom,
                onTap: (tapPosition, point) => {
                  print(point.toString()),
                },
              ),
              children: [
                TileLayer(
                  tileSize: 256.0,
                  minZoom: 2,
                  maxZoom: 13,
                  //tms: true,
                  additionalOptions: {
                    // 'username': 'MBAWETWOSQ',
                    // 'password': 'HestPlastikMule!985',
                    'username': 'VTWHJCRUWO',
                    'password': 'FiskMenneskeGlad200!',
                    'service': 'WMTS',
                    'request': 'GetTile',
                    'version': '1.0.0',
                    'format': 'image%2Fjpeg',
                    'layer': 'topo_skaermkort',
                    'style': 'default',
                    'tilematrixset': 'View1',
                    'uri':
                        'https://services.datafordeler.dk/DKskaermkort/topo_skaermkort_wmts/1.0.0/Wmts',
                  },
                  urlTemplate:
                      '{uri}?USERNAME={username}&PASSWORD={password}&SERVICE={service}&VERSION={version}&REQUEST={request}&FORMAT={format}&LAYER={layer}&STYLE={style}&TILEMATRIXSET={tilematrixset}&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}',

                  // urlTemplate: '{uri}?USERNAME={username}&PASSWORD={password}&SERVICE={service}&VERSION={version}&REQUEST={request}&FORMAT={format}&LAYER={layer}&STYLE={style}&TILEMATRIXSET={tilematrixset}&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void doTransformationStuff(proj4.Projection epsg25832) {
    // Define start point
    // point = proj4.Point(x: 6178892.29, y: 722125.86); // In epsg25832
    point = proj4.Point(x: 55.68, y: 12.59); // In epsg25832
    print('point: $point');

    // EPSG:3857 is a predefined projection ships with proj4dart?
    epsg3857 = proj4.Projection.get('EPSG:3857')!;

    print(
        'Which is (${epsg25832.transform(epsg3857, point).x.toStringAsFixed(2)}, ${epsg25832.transform(epsg3857, point).y.toStringAsFixed(2)}) in EPSG:3857.');
    print(epsg25832.transform(epsg3857, point));
    //epsg3857.transform(epsg25832CRS, point);

    point_transformed = epsg25832.transform(epsg3857, point);
    print('epsg3857: $point_transformed');
  }
}
