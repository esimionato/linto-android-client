import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/dialogs.dart' show showScopeDialog;
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';


class Applications extends StatefulWidget {
  final MainController mainController;

  Applications({Key key, this.mainController}) : super(key: key);

  @override
  _Applications createState() => new _Applications();
}

class _Applications extends State<Applications> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MainController _mainController;
  bool isActiveView = true;
  List<ApplicationScope> availableApplication;

  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    availableApplication = _mainController.client.scopes;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Applications"),
            leading: IconButton(
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => refreshList(),
              )
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ListView(
                padding: const EdgeInsets.all(20),
                primary: false,
                children: [
                  ...createTiles(_mainController.client.scopes, _mainController.client.currentScope)
                ],
              ),
            ),
          ),
        )
    );
  }

  List<Widget> createTiles(List<ApplicationScope> applications, ApplicationScope currentApp) {
    List<Widget> applicationWidgets = List<Widget>();
    if (applications.length == 0) {
      return [Text("No application available")];
    }

    for (ApplicationScope app in applications) {
      applicationWidgets.add(
        GestureDetector(
          child: Card(
            color: app == currentApp ? Colors.greenAccent : Colors.cyan[200],
            child: ListTile(
                title: Text(app.name, textAlign: TextAlign.center,),
                subtitle: Text(app.description, maxLines: 3,),
            ),
          ),
          onLongPress: () => onApplicationSelected(app),
          onTap: () => onApplicationClicked(app),
        )
      );

    }
    return applicationWidgets;
  }

  void onApplicationSelected(ApplicationScope app) async {
    _mainController.client.setScope(app);
    _mainController.userPreferences.setValue("cred_app", app.topic);
    await Navigator.pushNamed(context, '/main');
    setState(() {});
  }

  void onApplicationClicked(ApplicationScope app) async {
    bool res = await showScopeDialog(context, app);
    if(res ?? false){
      _mainController.client.setScope(app);
     await  Navigator.pushNamed(context, '/main');
     setState(() {});
    }
  }

  void refreshList() {
    _mainController.client.requestScopes();
    setState(() {});
  }
}
