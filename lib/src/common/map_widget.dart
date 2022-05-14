import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:scim/src/configs/base_config.dart';

class MapView extends StatefulWidget {
  MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: const Text("위치"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: (){
            }
        ),
      ),
      body: Stack(
        children: [
          Flexible(child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              // plugins: [WFSPlugin()],
              enableScrollWheel: false,
              enableMultiFingerGestureRace: false,
              minZoom: 9,
              maxZoom: 18,
              zoom: 14.5,
              center: LatLng(37.38641126582192,126.64640378847251),
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            layers: [
              // FlutterMap 에서 로딩할 Map Layer 정의
              TileLayerOptions(
                minZoom: 9,
                maxZoom: 19,
                backgroundColor: const Color(0x00FFFFFF), //배경 투명하게
                urlTemplate: BaseConfig.vWorldUrl,
              ),
            ],
          ))
        ],
      ),
    );
  }
}