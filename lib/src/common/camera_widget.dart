// A screen that allows users to take a picture using a given camera.

import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/splash/view/splash_page.dart';
import 'package:scim/src/worker/worker_repository.dart';

import '../worker/bloc/worker_bloc.dart';
import '../worker/models/models.dart';
import '../worker/views/work_list_detail_view.dart';

class TakePictureScreen extends StatefulWidget {
  TakePictureScreen({Key? key, required this.camera,
  this.post}) : super(key: key);

  Post? post;
  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final WorkerRepository _workerRepository = WorkerRepository();
  bool takeCamera = true;
  final  WorkerBloc _workerBloc =  WorkerBloc();

  @override
  void initState() {
    
   super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    _workerBloc.add(const WorkerChangeToSuccessStatus());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 사진 촬영'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),

      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: SizedBox(
          width: size.width,
          height: size.height,
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
      ),
      floatingActionButton: _renderCameraButtonForWorker(context),
    );
  }

  Row _renderCameraButtonForWorker(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(left: 30),
            child:  BlocConsumer<WorkerBloc, WorkerState>(
                bloc: _workerBloc,
                listener: (context, state){
                },
                builder: (context, state) {
                  switch (state.status) {
                    case WorkerStatus.failure:
                    case WorkerStatus.success:
                      return FloatingActionButton(
                        // Provide an onPressed callback.
                        onPressed: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Attempt to take a picture and get the file `image`
                            // where it was saved.
                            final image = await _controller.takePicture();
                            _workerBloc.add(const WorkerChangeToLoadStatus());

                            //If the picture was taken, display it on a new screen.
                            bool? saved = await _workerRepository.savePlanPhoto(
                                image.path, true, widget.post!.id!);
                            if (saved == true) {
                              Navigator.pushAndRemoveUntil<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        WorkListDetailView(post: widget.post!,)),
                                ModalRoute.withName('/'),
                              );
                            }
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            log(e.toString());
                          }
                        },
                        child: const Icon(Icons.camera_alt),
                      );
                    default:
                      return Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text('작업 사진을 저장 중 ...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SplashPage()
                          ],
                        ),
                      );
                  }
                }
            )
        )
      ],
    );
  }
}
