import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/splash/view/splash_page.dart';
import 'package:scim/src/worker/bloc/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:scim/src/worker/views/views.dart';
class AddWorkView extends StatefulWidget {
  const AddWorkView({Key? key}) : super(key: key);

  @override
  _AddWorkViewState createState() => _AddWorkViewState();
}

class _AddWorkViewState extends State<AddWorkView> {
  final  WorkerBloc _workerBloc =  WorkerBloc();

  @override
  void initState() {
    
    super.initState();
    _workerBloc.add(const WorkerLoadViewListWork());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue.shade900,
          centerTitle: true,
          title: const Text("작업등록"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        body: BlocProvider(
          create: (BuildContext context) => _workerBloc,
          child: BlocConsumer<WorkerBloc, WorkerState>(
            bloc: _workerBloc,
            listener:(context, state){
              if(state.status == WorkerStatus.created){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WorkListView()));
              }
            },
            builder: (context, state) {
              switch (state.status) {
                case WorkerStatus.failure:
                case WorkerStatus.success:
                  return Container();
                default:
                  return const SplashPage();
              }
            },
          ),
        )
    );
  }
}
