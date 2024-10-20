import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
//import 'package:flutter_map_example/widgets/drawer.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

class CustomCrsPage extends StatefulWidget {
  static const String route = 'custom_crs';

  const CustomCrsPage({Key? key}) : super(key: key);

  @override
  _CustomCrsPageState createState() => _CustomCrsPageState();
}

class _CustomCrsPageState extends State<CustomCrsPage> {
  late final Proj4Crs epsg25832CRS;
  late final Proj4Crs epsg4326CRS; //tw

  double? maxZoom;

  // Define start center
  // TW proj4.Point KBHpoint = proj4.Point(x: 55.676098, y: 12.568337); // KBH
  // TW proj4.Point KBHpoint = proj4.Point(x: 51.22, y: 2.46);  // LeftBottom  ->
  // TW proj4.Point KBHpoint = proj4.Point(x: 58.47, y: 16.16); // TopRight    ->
  // TW proj4.Point KBHpoint = proj4.Point(x: 51.22, y: 16.16); // BottomRight ->
  // TW proj4.Point KBHpoint = proj4.Point(x: 58.47 , y: 2.46); // TopLeft     ->
  proj4.Point KBHpoint = proj4.Point(x: 0  , y: 0);  // 0,0      ->
  // TW proj4.Point KBHpoint = proj4.Point(x: 54.6  , y: 9.2);  // Center      ->



  late proj4.Point currentlyUsedPoint = KBHpoint;

  String initText = 'Map centered to';

  late final proj4.Projection epsg4326;

  late final proj4.Projection epsg25832; //used to be 3413

  @override
  void initState() {
    super.initState();

    // EPSG:4326 is a predefined projection ships with proj4dart
    epsg4326 = proj4.Projection.get('EPSG:4326')!;

    // EPSG:3413 is a user-defined projection from a valid Proj4 definition string
    // From: http://epsg.io/3413, proj definition: http://epsg.io/3413.proj4
    // Find Projection by name or define it if not exists

    epsg25832 = proj4.Projection.add('EPSG:25832', '+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs +axis=end');

    // 9 example zoom level resolutions
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
    ];

    // final resolutions = <double>[
    //   // 3276.8,
    //   1638.4,
    //   819.2,
    //   409.6,
    //   204.8,
    //   102.4,
    //   51.2,
    //   12.8,
    //   6.4,
    //   3.2,
    //   1.6,
    //   0.8,
    //   0.4,
    //   0.2,
    // ];

    // final resolutions = <double>[
    //   0.2,
    //   0.4,
    //   0.8,
    //   1.6,
    //   3.2,
    //   6.4,
    //   12.8,
    //   51.2,
    //   102.4,
    //   204.8,
    //   409.6,
    //   819.2,
    //   1638.4,
    // ];

    // final scales = <double>[
    //   5851428.57142857182770967484,
    //   2925714.28571428591385483742,
    //   1462857.14285714295692741871,
    //   731428.57142857147846370935,
    //   365714.28571428573923185468,
    //   182857.14285714286961592734,
    //   91428.57142857143480796367,
    //   45714.28571428571740398183,
    //   22857.14285714285870199092,
    // ];

    // https://pub.dev/documentation/universe/latest/universe/Bounds-class.html
    final epsg25832Bounds = Bounds<double>(
      const CustomPoint<double>(120000.0, 5600000.0),
      const CustomPoint<double>(1000000.0, 6500000.0),
      // const CustomPoint<double>(905000.0, 6025000.0),
      // const CustomPoint<double>(420000.0, 6450000.0),
    );
    final epsg4326Bounds = Bounds<double>(
      // TW const CustomPoint<double>(2.48, 51.22),  // (Long, Lat) LeftBottom
      // TW const CustomPoint<double>(16.16, 58.47), // (Long, Lat) RightTop
      const CustomPoint<double>(2.48, 58.47),  // (Long, Lat) LeftTop (Min)
      const CustomPoint<double>(16.16, 51.22), // (Long, Lat) RightBottom (Max)
    );

    print("bottom left: " + epsg25832Bounds.bottomLeft.toString());
    print("bottom right: " + epsg25832Bounds.bottomRight.toString());
    print("center: " + epsg25832Bounds.center.toString());
    print("top left: " + epsg25832Bounds.topLeft.toString());
    print("top right: " + epsg25832Bounds.topRight.toString());
    print("size: " + epsg25832Bounds.size.toString());
    maxZoom = (resolutions.length - 1).toDouble();

    // Define CRS
    epsg4326CRS = Proj4Crs.fromFactory(
      // CRS code
      code: 'EPSG:4326', //tw
      // your proj4 delegate
      proj4Projection: epsg4326,
      // Resolution factors (projection units per pixel, for example meters/pixel)
      // for zoom levels; specify either scales or resolutions, not both
      resolutions: resolutions,
      // Bounds of the CRS, in projected coordinates
      // (if not specified, the layer's which uses this CRS will be infinite)
      // TW bounds: epsg4326Bounds,
      bounds: null,
      // Tile origin, in projected coordinates, if set, this overrides the transformation option
      // Some goeserver changes origin based on zoom level
      // and some are not at all (use explicit/implicit null or use [CustomPoint(0, 0)])
      // @see https://github.com/kartena/Proj4Leaflet/pull/171
      // origins: KBHpoint,
      // TW origins: [const CustomPoint(0, 0)],  // Offset = 0
      origins: [const CustomPoint(12.568337, 55.676098)],  // CPH in longLat  -> hjørne
      // TW origins: [const CustomPoint(2.46, 51.22)],   // LeftBottom           -> gråt
      // TW origins: [const CustomPoint(16.16, 58.47)],  // RightTop             -> gråt
      // TW origins: [const CustomPoint(16.16, 51.22)],  // RightBottom          -> gråt
      // TW origins: [const CustomPoint(2.46, 58.47)],   // LeftTop              -> hjørne
      // TW origins: [const CustomPoint(9.2, 54.6)],     // Center               -> hjørne
      // Scale factors (pixels per projection unit, for example pixels/meter) for zoom levels;
      // specify either scales or resolutions, not both
      scales: null,
      // The transformation to use when transforming projected coordinates into pixel coordinates
      transformation: null,
    );


    // Define CRS
    epsg25832CRS = Proj4Crs.fromFactory(
    // epsg4326CRS = Proj4Crs.fromFactory(
      // CRS code
      code: 'EPSG:25832', //tw
      // your proj4 delegate
      proj4Projection: epsg25832,
      // Resolution factors (projection units per pixel, for example meters/pixel)
      // for zoom levels; specify either scales or resolutions, not both
      resolutions: resolutions,
      // Bounds of the CRS, in projected coordinates
      // (if not specified, the layer's which uses this CRS will be infinite)
      bounds: epsg25832Bounds,
      // Tile origin, in projected coordinates, if set, this overrides the transformation option
      // Some goeserver changes origin based on zoom level
      // and some are not at all (use explicit/implicit null or use [CustomPoint(0, 0)])
      // @see https://github.com/kartena/Proj4Leaflet/pull/171
      // origins: KBHpoint,
      origins: [const CustomPoint(540000, 6100000)],  // CPH (approximately ) in UTM32
      // Scale factors (pixels per projection unit, for example pixels/meter) for zoom levels;
      // specify either scales or resolutions, not both
      scales: null,
      // The transformation to use when transforming projected coordinates into pixel coordinates
      transformation: null,
    );

    //tw  print(epsg25832CRS.getProjectedBounds(0));
    print(epsg25832CRS.getProjectedBounds(1)); //tw
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom CRS')),
      //drawer: buildDrawer(context, CustomCrsPage.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                'This map is in EPSG:4326',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                '$initText (${currentlyUsedPoint.x.toStringAsFixed(5)}, ${currentlyUsedPoint.y.toStringAsFixed(5)}) in EPSG:4326.',
              ),
            ),
            //tw Padding(
            //tw  padding: const EdgeInsets.only(top: 2, bottom: 2),
            //tw  child: Text(
            //tw 'Which is (${epsg4326.transform(epsg25832, point).x.toStringAsFixed(2)}, ${epsg4326.transform(epsg25832, point).y.toStringAsFixed(2)}) in EPSG:25832.',
            //tw      ),
            //tw ),
            const Padding(
              padding: EdgeInsets.only(top: 2, bottom: 8),
              child: Text('Tap on map to get more coordinates!'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  // Set the default CRS
                  crs: epsg4326CRS, //tw
                  center: LatLng(currentlyUsedPoint.x, currentlyUsedPoint.y),
                  // center: proj4.Point(x: 716732.0, y: 6174422.0),
                  zoom: 0,
                  // Set maxZoom usually scales.length - 1 OR resolutions.length - 1
                  // but not greater
                  maxZoom: maxZoom,
                  slideOnBoundaries: true,
                  onTap: (tapPosition, p) => setState(() {
                    initText = 'You clicked at';
                    currentlyUsedPoint = proj4.Point(x: p.latitude, y: p.longitude);
                  }),
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(currentlyUsedPoint.x, currentlyUsedPoint.y),
                        width: 80,
                        height: 80,
                        builder: (context) => FlutterLogo(),
                      ),
                    ],
                  ),
                  TileLayer(
                    // tileSize: 256.0,
                    // minZoom: 0,
                    // maxZoom: 8,
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
          ],
        ),
      ),
    );
  }
}
