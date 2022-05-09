import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:scim/src/common/dialog_widget.dart';
import 'package:scim/src/configs/base_config.dart';
import 'package:signalr_client/signalr_client.dart';

import '../../../splash/view/splash_page.dart';
import '../../common/camera_widget.dart';
import '../bloc/worker_bloc.dart';
import '../models/models.dart';

// If you want only to log out the message for the higer level hub protocol:
final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
final transportProtLogger = Logger("SignalR - transport");

// The location of the SignalR Server.
final serverUrl = BaseConfig.devServer;
const connectionOptions = HttpConnectionOptions;
final httpOptions = HttpConnectionOptions(logger: transportProtLogger);

// If you need to authorize the Hub connection than provide a an async callback function that returns
// the token string (see AccessTokenFactory typdef) and assigned it to the accessTokenFactory parameter:
// final httpOptions = new HttpConnectionOptions( .... accessTokenFactory: () async => await getAccessToken() );

// Creates the connection by using the HubConnectionBuilder.
final hubConnection = HubConnectionBuilder().withUrl(serverUrl, options: httpOptions).configureLogging(hubProtLogger).build();
// When the connection is closed, print out a message to the console.

class WorkerImageView extends StatefulWidget {
  WorkerImageView({Key? key,
    required this.info,
    required this.post,
    this.initTabView}) : super(key: key);

  late bool info;
  final Post post;
  int? initTabView;

  @override
  _WorkImageViewState createState() => _WorkImageViewState();
}

class _WorkImageViewState extends State<WorkerImageView> {
  final WorkerBloc _workerBloc = WorkerBloc();
  int _currentIndex = 0;
  String? comment;
  List<Object> comments = [];

  @override
  void initState() {
    super.initState();
    _workerBloc.add(WorkerGetListPhoto(widget.post));
    _workerBloc.add(WorkerGetFollowPost(widget.post));
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
    hubConnection.off("LoadComments");
    hubConnection.off("SendComment");
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider<WorkerBloc>(
        create: (context) => _workerBloc,
        child: BlocConsumer<WorkerBloc, WorkerState>(
            listener: (context, state){
              if (state.status == WorkerStatus.failure) {
                DialogWidget.flutterSnackBar(context,content: "API 반환 오류");
              }
            },
            builder: (context, state) {
              switch (state.status) {
                case WorkerStatus.failure:
                case WorkerStatus.success:
                  return Scaffold(
                      body: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                            children: [
                              SizedBox(
                                height: size.height*0.5,
                                child: Stack(
                                  children: [
                                    _determineBeforeTab(context,size,state),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.white,),
                                      onPressed: () {
                                        {
                                          Navigator.pop(context);
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                              _renderBasicInfo(context, size, state),
                              _renderComment(context, size, state),
                              Container(
                                alignment: Alignment.bottomCenter,
                                margin: const EdgeInsets.all(20),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '댓글',
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  onChanged: (value){
                                    comment = value;
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                margin: const EdgeInsets.only(right: 20, bottom: 20),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await hubConnection.start();
                                    await hubConnection.invoke("SendComment", args: <Object>[comment ?? '']);
                                  },
                                  child: const Text("확인"),
                                ),
                              )
                            ]
                        ),
                      )
                  );
                default:
                  return const SplashPage();
              }
            }
        )
    );
  }

  void _handleAClientProvidedFunction(List<Object> parameters) async {
    await hubConnection.start();
    comments = parameters;
  }

  Widget _renderComment(BuildContext context, Size size, WorkerState state){
    hubConnection.on("ReceiveComment", _handleAClientProvidedFunction);
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: comments.map((item) => Text(item.toString())).toList(),
        )
    );
  }

  Column _renderBasicInfo(BuildContext context, Size size, WorkerState state){
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10,left: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width*0.95,
                      child: Text(widget.post.title ?? '',
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  ]
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10,left: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width*0.95,
                      child: Text(widget.post.content ?? '',
                        textAlign: TextAlign.left,
                      ),
                    )
                  ]
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      _workerBloc.add(WorkerfollowPost(post: widget.post));
                    },
                    child: state.heart == true || state.follow == true
                        ? const Icon(FontAwesomeIcons.solidHeart,color: Colors.red)
                        : const Icon(FontAwesomeIcons.heart,color: Colors.black),
                  ),
                ]
            ),
            Container(
              margin: const EdgeInsets.only(right: 20.0),
              child: Text(widget.post.posterName ?? ''),
            ),
          ],
        ),
      ],
    );
  }

  CarouselSlider _renderImageElements(BuildContext context,Size size,List<Photo> photos){
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1,
        height: size.height,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          },
          );
        },
      ),
      items: photos.map(
            (item) => Padding(
          padding: const EdgeInsets.all(0),
          child: Card(
            margin: const EdgeInsets.only(
              top: 0,
              bottom: 0,
            ),
            elevation: 6.0,
            child: Center(
              child: Stack(
                children: [
                  _renderTabBarImage(context,item),
                  _renderMarkerImageIndex(context,size,photos)
                ],
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  Container _renderMarkerImageIndex(BuildContext context, Size size, List<Photo> photos){
    return Container(
      margin: EdgeInsets.only(top: size.height*0.46),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: photos.map((urlOfItem) {
          int index = photos.indexOf(urlOfItem);
          return Container(
            width: 10.0,
            height: 10.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.lightBlueAccent
                  : Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _determineBeforeTab(BuildContext context,Size size, WorkerState state){
    if(state.photos != null && state.photos!.isNotEmpty){
      return _renderImageElements(context,size, state.photos ?? []);
    }
    return _renderTabBarNoImage(context, true);
  }

  Future<void> takeCamera(BuildContext context, bool before, String? planId) async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera, post: widget.post)));
  }

  Stack _renderTabBarImage(BuildContext context, Photo? photo){
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: photo?.url,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Align(
            alignment: Alignment.center,
            child: Icon(Icons.error_outline),
          ),
        ),
      ],
    );
  }
  
  Stack _renderTabBarNoImage(BuildContext context, bool before){
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/none.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
    );
  }
}

