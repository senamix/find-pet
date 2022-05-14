import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/src/worker/bloc/worker_bloc.dart';
import 'package:scim/src/worker/views/views.dart';
import 'package:scim/src/worker/views/work_list_search_view.dart';

class WorkListView extends StatelessWidget {
  WorkListView({Key? key}) : super(key: key);
  static const routeName = '/worker';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: BlocProvider<WorkerBloc>(
          create: (context) => WorkerBloc(),
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: const Text("홈"),
                actions: [
                  IconButton(
                    onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WorkerListInfoItemSearch()));
                    },icon: const Icon(Icons.search)
                  ),
                  IconButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => WorkerListInfoItemSearch()));
                      },icon: const Icon(Icons.add_alert_rounded)
                  )
                ],
              ),
              body: const WorkListDoingView(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddWorkView())
                  );
                },
                child: const Icon(Icons.add),
              ),
            )
          ),
      onWillPop: (){
        return Future(() => true);
      },
    );
  }
}
