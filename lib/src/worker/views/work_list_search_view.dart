import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:scim/src/common/map_widget.dart';
import 'package:scim/src/worker/worker_repository.dart';

import '../../configs/base_config.dart';
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

  @override
  void initState() {
    super.initState();
    _workerBloc.add(const WorkerGetAllTags());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  BlocConsumer<WorkerBloc, WorkerState>(
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
                Flexible(child: FlutterMap(
                  options: MapOptions(
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
                )),
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
                                        hintText: "가산동",
                                        suffixIcon: IconButton(
                                          onPressed: () async{
                                            List<String>? addresses = await WorkerRepository.getRoadInfo(address ?? '');
                                            if(addresses != null && addresses.isNotEmpty){
                                              _showDialog(context, addresses, state);
                                            }
                                          },
                                          icon: const Icon(Icons.send_outlined),
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
                                  const Text("종류: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: size.width*0.6,
                                    child: DropdownButton(
                                      value: '선택하세요', //real value
                                      icon: const Icon(Icons.keyboard_arrow_down),
                                      items: kinds.map((item) => DropdownMenuItem(
                                        value: item,
                                        child: SizedBox(
                                          width: size.width*0.53,
                                          child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                        ),
                                      )).toSet().toList(),
                                      onChanged: (String? newValue) {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(padding: EdgeInsets.only(top: 5.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("기타: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: size.width*0.6,
                                    child: TextFormField(
                                      textAlign: TextAlign.left,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32.0)
                                        ),
                                        hintText: "색깔, 크기, 높이",
                                      ),
                                      onChanged: (String? value){
                                        setState(() {

                                        });
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
              ],
            ),
          );
        });
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