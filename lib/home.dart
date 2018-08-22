import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils.dart' as utils;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool conn = false;
  String username = "";
  TextEditingController _controller = TextEditingController();

  getConnectionStatus() {
    Connectivity connectivity = Connectivity();

    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          conn = true;
        });
      } else {
        setState(() {
          conn = false;
        });
      }
    });
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        bgcolor: "#cccccc",
        textcolor: '#ffffff');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: conn
            ? Container(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black12,
                    ),
                    hintText: 'Enter username',
                    contentPadding: EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    fillColor: Colors.black12,
                  ),
                  controller: _controller,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                ),
              )
            : Text(
                'Github',
                style: textStyle,
              ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          conn
              ? IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (_controller.text != "") {
                      setState(() {
                        username = _controller.text;
                      });
                    } else {
                      showToast('Enter username');
                    }
                  })
              : Container()
        ],
      ),
      body: conn
          ? Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: FutureBuilder<Widget>(
                future: getGithubData(
                    _controller.text == "" ? utils.defaultUser : username),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          : msg('No Internet'),
    );
  }

  Widget msg(String msg) {
    return Container(
      child: Center(
        child: Text(
          msg,
          style: textStyle,
        ),
      ),
    );
  }

  Widget githubProfile(Map snapshot) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('${snapshot['avatar_url']}'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.circle),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '${snapshot['name']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              '${snapshot['bio']}',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Followers  ${snapshot['followers']}',
              style: textStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'following  ${snapshot['following']}',
              style: textStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Public Repository  ${snapshot['public_repos']}',
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  final textStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.black,
    fontStyle: FontStyle.normal,
  );

  Future<Widget> getGithubData(String user) async {
    String url = "https://api.github.com/users/$user";
    http.Response response = await http.get(url);

    if (response.statusCode == utils.profileFound) {
      Map map = json.decode(response.body);
      return githubProfile(map);
    } else if (response.statusCode == utils.profileNotFound) {
      return msg('Profile not found');
    } else {
      return null;
    }
  }
}
