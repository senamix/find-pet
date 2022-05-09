import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scim/src/common/dialog_widget.dart';
import 'package:scim/src/worker/worker_repository.dart';

class UploadDelayImages{
  static Future<bool?> upload(BuildContext context)async {
    WorkerRepository workerRepository = WorkerRepository();
    bool? uploaded = await  workerRepository.uploadPlanPhoto();
    if(uploaded != null && uploaded){
      DialogWidget.flutterDialog(context, title: "작업 사진 업로드", content: "작업 사진 업로드하였습니다.");
      return true;
    }else if (uploaded != null && !uploaded){
      // DialogWidget.flutterDialog(context, title: "작업 사진 업로드", content: "일괄 작업 사진이 없습니다.");
      return true;
    }
    return null;
  }
}
