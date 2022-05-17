import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scim/src/common/dialog_widget.dart';
import 'package:scim/src/worker/bloc/worker_bloc.dart';
import 'package:scim/src/worker/views/views.dart';

import '../../../splash/view/splash_page.dart';
import '../models/models.dart';
import '../worker_repository.dart';
class AddWorkView extends StatefulWidget {
  const AddWorkView({Key? key}) : super(key: key);

  @override
  _AddWorkViewState createState() => _AddWorkViewState();
}

class _AddWorkViewState extends State<AddWorkView> {
  List<XFile>? _imageFileList;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  final TextEditingController _controller = TextEditingController();
  final WorkerBloc _workerBloc = WorkerBloc();
  Set<String> kinds = {'선택하세요'};
  String? tag1;
  String? tag2;
  String? tag3;
  String? tag4;
  String? tag5;
  Set<String> tags = {};
  String? address;
  PostLocation? postLocation;
  String? title;
  String? content;

  @override
  void initState() {
    super.initState();
    _workerBloc.add(const WorkerGetAllTags());
  }

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  _showDialog(BuildContext context, List<PostLocation> addresses, WorkerState state){
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
                      _controller.text = item.roadLocation ?? '';
                      postLocation = item;
                      Navigator.pop(contextDialog);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(item.roadLocation ?? '', style: const TextStyle(fontSize: 15),),
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

  Future<void> _setupPickImage(BuildContext context, OnPickImageCallback onPick) async {
    final double? width = maxWidthController.text.isNotEmpty
        ? double.parse(maxWidthController.text)
        : null;
    final double? height = maxHeightController.text.isNotEmpty
        ? double.parse(maxHeightController.text)
        : null;
    final int? quality = qualityController.text.isNotEmpty
        ? int.parse(qualityController.text)
        : null;
    onPick(width, height, quality);
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
          child: ListView.builder(
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int index) {
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              return Semantics(
                label: '',
                child: kIsWeb
                    ? Image.network(_imageFileList![index].path)
                    : Image.file(File(_imageFileList![index].path)),
              );
            },
            itemCount: _imageFileList!.length,
          ),
          label: '');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Image.asset('assets/images/none.png');
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = true}) async {
    if (isMultiImage) {
      await _setupPickImage(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final List<XFile>? pickedFileList = await _picker.pickMultiImage(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            if(pickedFileList != null && pickedFileList.length > 4){
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
                      content: const Text("최대 4개까지 사진을 업로드 할 수 있습니다."),
                      actions: <Widget>[
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            child: const Text("확인"),
                            onPressed: () {
                              Navigator.pop(contextDialog);
                            },
                          ),
                        ),
                      ],
                    );
                  }
              );
            }else{
              _imageFileList = pickedFileList;
            }
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
        setState(() {
          _imageFile = response.file;
          _imageFileList = response.files;
        });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title:  const Text("등록"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              {
                Navigator.pop(context);
              }
            },
          )
      ),
      body: BlocConsumer<WorkerBloc, WorkerState>(
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
            if(curr.status == WorkerStatus.created){
              return true;
            }
            return false;
          },
          listener: (context, state){
            if(state.status == WorkerStatus.created){
              DialogWidget.flutterDialog(context,content: "등록하였습니다.");
              Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(builder: (BuildContext context) => WorkListView()),
                (Route<dynamic> route) => false,
              );
            }
          },
          builder: (context, state){
            switch (state.status) {
              case WorkerStatus.created:
              case WorkerStatus.failure:
              case WorkerStatus.success:
                return Stack(
                  children: [
                    Card(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            ),
                                            hintText: "제목",
                                            labelText: "제목",
                                          ),
                                          onChanged: (String? value){
                                            setState(() {
                                              title = value ?? '제목';
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 10.0)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          minLines: 8,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            ),
                                            hintText: "내용",
                                            labelText: "내용",
                                          ),
                                          onChanged: (String? value){
                                            setState(() {
                                              content = value ?? "내용";
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 10)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          textAlign: TextAlign.left,
                                          controller: _controller,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            ),
                                            hintText: "가산",
                                            labelText: "도로명",
                                            suffixIcon: IconButton(
                                              onPressed: () async{
                                                List<PostLocation>? addresses = await WorkerRepository.getRoadInfo(address ?? '');
                                                if(addresses != null){
                                                  _showDialog(context, addresses, state);
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
                                  const Padding(padding: EdgeInsets.only(top: 10)),
                                  Row(
                                    children: [
                                      const Text("사진 업로드: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                      const Padding(padding: EdgeInsets.only(top: 10)),
                                      IconButton(onPressed: (){
                                        _onImageButtonPressed(
                                          ImageSource.gallery,
                                          context: context,
                                          isMultiImage: true,
                                        );
                                      }, icon: const Icon(Icons.photo_library)),
                                      Expanded(
                                        child: SizedBox(
                                          width: size.width*0.5,
                                          height: size.width*0.5,
                                          child: _previewImages(),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 20)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("태그: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                      const Padding(padding: EdgeInsets.only(left: 30)),
                                      SizedBox(
                                        child: DropdownButton(
                                          value: tag1 ?? '선택하세요',
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          items: kinds.map((item) => DropdownMenuItem(
                                            value: item,
                                            child: SizedBox(
                                              child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                            ),
                                          )).toSet().toList(),
                                          onChanged: (String? newValue) {
                                            if(newValue != null && newValue != '선택하세요'){
                                              setState(() {
                                                tag1 = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.only(left: 20)),
                                      SizedBox(
                                        child: DropdownButton(
                                          value: tag2 ?? '선택하세요',
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          items: kinds.map((item) => DropdownMenuItem(
                                            value: item,
                                            child: SizedBox(
                                              child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                            ),
                                          )).toSet().toList(),
                                          onChanged: (String? newValue) {
                                            if(newValue != null && newValue != '선택하세요'){
                                              setState(() {
                                                tag2 = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      )

                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 10)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("태그: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                      const Padding(padding: EdgeInsets.only(left: 30)),
                                      SizedBox(
                                        child: DropdownButton(
                                          value: tag3 ?? '선택하세요',
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          items: kinds.map((item) => DropdownMenuItem(
                                            value: item,
                                            child: SizedBox(
                                              child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                            ),
                                          )).toSet().toList(),
                                          onChanged: (String? newValue) {
                                            if(newValue != null && newValue != '선택하세요'){
                                              setState(() {
                                                tag3 = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.only(left: 20)),
                                      SizedBox(
                                        child: DropdownButton(
                                          value: tag4 ?? '선택하세요',
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          items: kinds.map((item) => DropdownMenuItem(
                                            value: item,
                                            child: SizedBox(
                                              child: Text(item, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18),), //display item value
                                            ),
                                          )).toSet().toList(),
                                          onChanged: (String? newValue) {
                                            if(newValue != null && newValue != '선택하세요'){
                                              setState(() {
                                                tag4 = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      )

                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 10)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("다른 태그: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                      const Padding(padding: EdgeInsets.only(left: 30)),
                                      Expanded(
                                        child: TextFormField(
                                          minLines: 1,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            ),
                                            hintText: "노란색 , 80cm",
                                          ),
                                          onChanged: (String? value){
                                            if(value != null){
                                              setState(() {
                                                tag5 = value;
                                              });
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 5)),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: ElevatedButton(
                                        child: SizedBox(
                                          width: size.width*0.17,
                                          child: Row(
                                            children: const [
                                              Icon(Icons.add),
                                              Text(' 등록')
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          if(tag1 != null && tag1 != '선택하세요'){
                                            tags.add(tag1!);
                                          }
                                          if(tag2 != null && tag2 != '선택하세요'){
                                            tags.add(tag2!);
                                          }
                                          if(tag3 != null && tag3 != '선택하세요'){
                                            tags.add(tag3!);
                                          }
                                          if(tag4 != null && tag4 != '선택하세요'){
                                            tags.add(tag4!);
                                          }
                                          if(tag5 != null && tag5 != '선택하세요'){
                                            Set<String> splits = tag5!.split(",").toSet();
                                            tags.addAll(splits);
                                          }
                                          List<String> finalList = [];
                                          for(String item in tags){
                                            finalList.add(item);
                                          }
                                          if(title != null && content != null){
                                            _workerBloc.add(WorkerAddPost(finalList, _imageFileList ?? [], postLocation, title!, content!));
                                          }else{
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
                                                    content: const Text("제목과 내용이 필수항목입니다."),
                                                    actions: <Widget>[
                                                      Container(
                                                        alignment: Alignment.bottomRight,
                                                        child: ElevatedButton(
                                                          child: const Text("확인"),
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
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              default:
                return const SplashPage();
            }
          }
      )
    );
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
