import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scim/src/worker/views/views.dart';
import 'package:scim/src/worker/views/work_image_widget.dart';
import 'package:scim/src/worker/worker_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/worker_bloc.dart';
import '../models/models.dart';

class WorkerAround extends StatefulWidget {
  WorkerAround({Key? key}) : super(key: key);

  @override
  _WorkerAroundState createState() => _WorkerAroundState();
}

class _WorkerAroundState extends State<WorkerAround> {
  final WorkerBloc _workerBloc = WorkerBloc();
  final WorkerRepository _workerRepository = WorkerRepository();

  late CameraPosition _kGooglePlex;
  final Completer<GoogleMapController> _controller = Completer();

  late Position _currentPosition;
  List<Marker> markers = [];

  Future<Position>? get currentPosition async{
    _currentPosition = await _workerRepository.determinePosition();
    _kGooglePlex = CameraPosition(
      target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      zoom: 14,
    );
    return _currentPosition;
  }

  Future<List<Marker>?> get makerList async{
    Map<String,PostLocation> postLocations = {};
    List<Post>? posts = await _workerRepository.getListPost();
    if(posts != null){
      for(Post post in posts){
        postLocations.addAll({post.id! : post.postLocation!});
      }
    }
    for(String id in postLocations.keys){
      markers.add(Marker(
          markerId: MarkerId(id.toString()),
          draggable: true,
          onTap: () async{
            Post? postById = await _workerRepository.getPostById(id);
            if(postById != null){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WorkerImageView(info: true,post: postById)));
            }
          },
          position: LatLng(postLocations[id]?.latitude ?? 37.38641126582192,postLocations[id]?.longitude ?? 126.64640378847251)
      ));
    }
    return markers;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<WorkerBloc, WorkerState>(
        bloc: _workerBloc,
        listener: (context, state){
        },
        builder: (context, state){
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title:  const Text("나의 근처"),
            ),
            body: FutureBuilder(
              future: currentPosition,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return FutureBuilder(
                    future: makerList,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        // If the Future is complete, display the preview.
                        return GoogleMap(
                          markers: Set.from(markers),
                          mapType: MapType.normal,
                          initialCameraPosition: _kGooglePlex,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        );
                      } else {
                        // Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        });
  }
}