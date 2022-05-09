import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../worker/views/work_list_search_view.dart';

class InfoView extends StatefulWidget {
  const InfoView({Key? key}) : super(key: key);
  static const routeName = '/info';

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child:  Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("정보"),
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
        body: Container(
          // color: Colors.grey,
          child: buildListView(context),
        ),
      ),
      onWillPop: (){
        return Future(() => true);
      },
    );
  }

  //display list info method
  ListView buildListView(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8), children: <Widget>[
      buildCard(context,
          leading: 'assets/images/other/chuck.png',
          title: '애완동물원',
          namedPath:['market://details?id=kr.co.chukchuk&hl=ko','itms://itunes.apple.com/kr/app/apple-store/id806134531?mt=8']),
      buildCard(context,
          leading: 'assets/images/Icon/vital.png',
          title: '애완동물 음식',
          namedPath: ['https://band.us/@csms','https://band.us/@csms']),
      buildCard(context,
          leading: 'assets/images/Icon/public.png',
          title: '애완동물 유의사항',
          namedPath: ['http://www.molit.go.kr/USR/WPGE0201/m_122/DTL.jsp','http://www.molit.go.kr/USR/WPGE0201/m_122/DTL.jsp']),
      buildCard(context,
          leading: 'assets/images/Icon/help.png',
          title: '애완동물 정보',
          namedPath: ['Help','Help']),
    ]);
  }

  Card buildCard(BuildContext context,
      {required String leading,
      required String title,
      required List<String> namedPath}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ListTile(
            enableFeedback: true,
            leading: Image.asset(
              leading,
              width: 40,
              height: 40,
              fit: BoxFit.scaleDown,
            ),
            title: Text(title),
            trailing: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue,
              child: Icon(Icons.arrow_forward_ios, color: Colors.white,size: 15,)
            ),
            onTap: () {
              if (defaultTargetPlatform == TargetPlatform.android) {
                launch(namedPath[0]);
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                launch(namedPath[1]);
              }
            }
          ),
      ),
      shadowColor: Colors.black54,
      elevation: 4,
    );
  }
}
