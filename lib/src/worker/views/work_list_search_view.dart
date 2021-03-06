import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scim/src/common/dialog_widget.dart';
// import 'package:latlong2/latlong.dart';
import 'package:scim/src/worker/views/views.dart';
import 'package:scim/src/worker/worker_repository.dart';

import '../bloc/worker_bloc.dart';
import '../models/models.dart';

class WorkerListInfoItemSearch extends StatefulWidget {
  WorkerListInfoItemSearch({Key? key}) : super(key: key);

  @override
  _WorkerListInfoItemSearchState createState() => _WorkerListInfoItemSearchState();
}

class _WorkerListInfoItemSearchState extends State<WorkerListInfoItemSearch> {
  final TextEditingController _controller = TextEditingController();
  final WorkerBloc _workerBloc = WorkerBloc();
  Set<String> kinds = {'선택하세요'};
  String? address;
  String? tag1;
  String? otherTags;
  String? fromDate;
  String? toDate;
  List<Post> searchPosts = [];
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _workerBloc.add(const WorkerGetAllTags());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<WorkerBloc, WorkerState>(
        bloc: _workerBloc,
        listenWhen: (pre, curr){
          if(curr.tags != pre.tags && curr.tags != []){
            if(curr.tags.isNotEmpty){
              for(Tag tag in curr.tags){
                kinds.add(tag.tagName ?? '');
              }
            }
            return true;
          }
          return false;
        },
        listener: (context, state){
        },
        builder: (context, state){
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title:  const Text("애완동물 검색"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    {
                      Navigator.pop(context);
                    }
                  },
                )
            ),
            body: Stack(
              children: [
                Flexible(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(37.38641126582192,126.64640378847251),
                        zoom: 14,
                      ),
                    )
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("도로명: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: size.width*0.6,
                                          child: TextFormField(
                                            textAlign: TextAlign.left,
                                            controller: _controller,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(32.0)
                                              ),
                                              hintText: "도로명을 입력하세요...",
                                              suffixIcon: IconButton(
                                                onPressed: () async{
                                                  if(address == null || address == ''){
                                                      DialogWidget.flutterDialog(context, content: "도로명을 입력해야 해당 주소을 찾을 수 있습니다.");
                                                  }else{
                                                    List<PostLocation>? addresses = await WorkerRepository.getRoadInfo(address ?? '');
                                                    List<String> roads = [];
                                                    if(addresses != null){
                                                      for(PostLocation road in addresses){
                                                        roads.add(road.roadLocation ?? '');
                                                      }
                                                    }
                                                    if(addresses != null && addresses.isNotEmpty){
                                                      _showDialog(context, roads, state);
                                                    }
                                                  }
                                                },
                                                icon: const Icon(Icons.search_off),
                                              ),
                                            ),
                                            onChanged: (String? value){
                                              setState(() {
                                                address = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("시작: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: size.width*0.6,
                                          child: DateTimePicker(
                                            type: DateTimePickerType.date,
                                            dateMask: 'yyyy-MM-dd',
                                            initialValue: DateTime.now().toString(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2100),
                                            icon: const Icon(Icons.event),
                                            dateLabelText: '시작',
                                            onChanged: (val){
                                              setState(() {
                                                fromDate = val;
                                              });
                                            },
                                            validator: (val) {
                                              print(val);
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("종류: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: size.width*0.6,
                                          child: DateTimePicker(
                                            type: DateTimePickerType.date,
                                            dateMask: 'yyyy-MM-dd',
                                            initialValue: DateTime.now().toString(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2100),
                                            icon: const Icon(Icons.event),
                                            dateLabelText: '종류',
                                            onChanged: (val){
                                              toDate = val;
                                            },
                                            validator: (val) {
                                              print("validator -> ${val ?? ''}");
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("태그: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: size.width*0.6,
                                          child: DropdownButton(
                                            value: kinds.contains(tag1) ? tag1 : '선택하세요', //real value
                                            icon: const Icon(Icons.keyboard_arrow_down),
                                            items: kinds.map((item) => DropdownMenuItem(
                                              value: item,
                                              child: SizedBox(
                                                width: size.width*0.53,
                                                child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                              ),
                                            )).toSet().toList(),
                                            onChanged: (String? newValue) {
                                              if(newValue != null){
                                                setState(() {
                                                  tag1 = newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(padding: EdgeInsets.only(top: 5.0)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("다른 태그: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: size.width*0.6,
                                          child: TextFormField(
                                            textAlign: TextAlign.left,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(32.0)
                                              ),
                                              hintText: "예: 색깔, 크기, 높이, ...",
                                            ),
                                            onChanged: (String? value){
                                              if(value != null){
                                                setState(() {
                                                  otherTags = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                                      child: ElevatedButton(
                                          child: SizedBox(
                                            width: size.width*0.17,
                                            child: Row(
                                              children: const [
                                                Icon(Icons.search),
                                                Text(' 검색')
                                              ],
                                            ),
                                          ),
                                          onPressed: () {
                                            String tags = '';
                                            if(tag1 != null){
                                              tags = tag1!;
                                            }
                                            if(otherTags != null){
                                              tags = tags + otherTags!;
                                            }
                                            _workerBloc.add(WorkerSearchPostByConditions(tags: tags, roadLocation: address, fromDate: fromDate, toDate: toDate));
                                          }
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: state.searchPosts.isNotEmpty
                            ? state.searchPosts.map((e) => WorkerListItem(post: e)).toList()
                            : [Container()],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  _showDialog(BuildContext context, List<String> addresses, WorkerState state){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contextDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            title: Column(
              children: const [
                Text("알림")
              ],
            ),
            //
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: addresses.isNotEmpty
                    ? addresses.map((item) => Card(
                  elevation: 3,
                  child: InkWell(
                    onTap: (){
                      _controller.clear();
                      _controller.text = item;
                      setState(() {
                        address = item;
                      });
                      Navigator.pop(contextDialog);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(item, style: const TextStyle(fontSize: 15),),
                    ),
                  ),
                )).toList() : [const Text("결과 없음")],
              ),
            ),
            actions: <Widget>[
              Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  child: const Text("취소"),
                  onPressed: () {
                    Navigator.pop(contextDialog);
                  },
                ),
              ),
            ],
          );
        }
    );
  }
}