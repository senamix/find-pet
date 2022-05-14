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
          namedPath:['https://www.google.com/search?client=firefox-b-lm&tbs=lf:1,lf_ui:1&tbm=lcl&sxsrf=ALiCzsaRp1ACJG5Hj0D5MQwQtL8-XHTTYg:1652456554793&q=%EC%9C%A0%EB%AA%85%ED%95%9C+%EC%95%A0%EC%99%84%EB%8F%99%EB%AC%BC%EC%9B%90&rflfq=1&num=10&sa=X&ved=2ahUKEwjv1dGv6Nz3AhVJqVYBHTWUD_oQjGp6BAghEAE&biw=2048&bih=984&dpr=1.25#rlfi=hd:;si:;mv:[[37.90600010000001,127.5722224],[35.7394549,126.7058045]];tbs:lrf:!1m4!1u3!2m2!3m1!1e1!1m4!1u2!2m2!2m1!1e1!2m1!1e2!2m1!1e3!3sIAE,lf:1,lf_ui:1']),
      buildCard(context,
          leading: 'assets/images/Icon/vital.png',
          title: '애완동물 음식',
          namedPath: ['https://www.google.com/search?q=%EC%95%A0%EC%99%84%EB%8F%99%EB%AC%BC+%EC%9D%8C%EC%8B%9D&client=firefox-b-lm&biw=2048&bih=984&tbm=lcl&sxsrf=ALiCzsYkTJ-byVpHz6zECrMtvniHws7kww%3A1652456684138&ei=7Hx-Ysn0B6232roP-5OB0AM&oq=%EC%95%A0%EC%99%84%EB%8F%99%EB%AC%BC+%EC%9D%8C%EC%8B%9D&gs_l=psy-ab.3..0i30k1j0i15i30k1j0i8i30k1.32038.36991.0.37256.9.8.0.0.0.0.181.786.0j5.5.0....0...1c.1j4.64.psy-ab..4.5.785...35i39k1j0i512i433k1j0i512k1.0.5OtrdCrySDk#rlfi=hd:;si:;mv:[[37.6256932,127.14793699999998],[37.2379033,126.76639929999997]];tbs:lrf:!1m4!1u3!2m2!3m1!1e1!1m4!1u2!2m2!2m1!1e1!2m1!1e2!2m1!1e3!3sIAE,lf:1,lf_ui:2']),
      buildCard(context,
          leading: 'assets/images/Icon/public.png',
          title: '애완동물 유의사항',
          namedPath: ['https://www.korea.kr/news/visualNewsView.do?newsId=148855120']),
      buildCard(context,
          leading: 'assets/images/Icon/help.png',
          title: '애완동물 보호정보',
          namedPath: ['https://www.animal.go.kr/front/index.do']),
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
                launch(namedPath[0]);
              }
            }
          ),
      ),
      shadowColor: Colors.black54,
      elevation: 4,
    );
  }
}
