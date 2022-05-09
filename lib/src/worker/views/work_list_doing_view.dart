import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scim/splash/view/splash_page.dart';
import 'package:scim/src/worker/bloc/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:scim/src/worker/views/views.dart';

import '../../common/dialog_widget.dart';
import '../../common/empty_data_widget.dart';

class WorkListDoingView extends StatefulWidget {
  const WorkListDoingView({Key? key}) : super(key: key);

  @override
  _WorkListDoingViewState createState() => _WorkListDoingViewState();
}

class _WorkListDoingViewState extends State<WorkListDoingView> {
  final  WorkerBloc _workerBloc =  WorkerBloc();
  final RefreshController _refreshController =  RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _workerBloc.add(WorkerGetListPost(page: 1));
  }

  void _onRefresh() async{
    _workerBloc.add(WorkerGetListPost(page: 1));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    _refreshController.loadComplete();
    _workerBloc.add(WorkerGetListPost());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkerBloc, WorkerState>(
      bloc: _workerBloc,
      listener:(context, state){
        if (state.status == WorkerStatus.failure) {
          DialogWidget.flutterSnackBar(context,content: "API 반환 오류");
        }
      },
      buildWhen: (previous, current) => previous.doingPlans != current.doingPlans,
      builder: (context, state) {
        switch (state.status) {
          case WorkerStatus.failure:
          case WorkerStatus.success:
            return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            physics: const BouncingScrollPhysics(),
            footer: const ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              completeDuration: Duration(milliseconds: 500),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if(state.doingPlans.isEmpty){
                  return const EmptyDataView();
                }
                return index >= state.doingPlans.length
                    ? Container()
                    : WorkerListItem(post: state.doingPlans[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.doingPlans.length
                  : state.doingPlans.length + 1,
            ),
          );
          default:
            return const SplashPage();
        }
      },
    );
  }

}
