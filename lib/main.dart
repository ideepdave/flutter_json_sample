import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_json_sample/model/LoginDao.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Json Parsing Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(title: 'Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String title;

  LoginPage({this.title});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final pswdController = TextEditingController();
  final String _positiveToast = '#66BB6A';
  final String _negativeToast = '#FF5722';
  final String _textColorToast = '#FFFFFF';
  int _state = 0;

  @override
  void dispose() {
    emailController.dispose();
    pswdController.dispose();
    super.dispose();
  }

  //API Request
  Future<String> apiRequest(String url, Map jsonMap) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  @override
  Widget build(BuildContext context) {


    //Display Toast Method
    void displayMyToast({String msgToDisplay, bool isPositive}) {

      Fluttertoast.showToast(
          msg: msgToDisplay,
          toastLength: Toast.LENGTH_LONG,
          bgcolor: isPositive ? _positiveToast : _negativeToast,
          textcolor: _textColorToast);
    }

    void _showError() {
      displayMyToast(
          msgToDisplay: 'Please enter valid data', isPositive: false);
      setState(() {
        _state = 0;
      });
    }

    void _submitData() async {
      String url = 'http://192.168.1.203/xampp/Hired/global.php';

      Map map = {
        'mode': 'getLogin',
        'emailId': emailController.text,
        'password': pswdController.text
      };

      String jsonString = await apiRequest(url, map);
      final jsonResponse = json.decode(jsonString);

      //Dao is model class you will find inside model directory
      Dao dao = new Dao.fromJson(jsonResponse);
      print(dao.message);

      displayMyToast(
          msgToDisplay: dao.message,
          isPositive: dao.message == 'Success' ? true : false);

      setState(() {
        _state = 2;
      });
    }

    Widget email() {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      );
    }

    Widget password() {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: TextFormField(
          controller: pswdController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      );
    }

    Widget setUpButtonChild() {
      if (_state == 0) {
        return new Text(
          "Submit",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        );
      } else if (_state == 1) {
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else {
        return Icon(Icons.check, color: Colors.white);
      }
    }

    void animateButton() {
      setState(() {
        _state = 1;
      });
      emailController.text.length > 0 &&
              emailController.text.contains('@') &&
              pswdController.text.length > 3
          ? _submitData()
          : _showError();
    }

    Widget loginButton() {
      return new Padding(
        padding: const EdgeInsets.all(16.0),

        //Note : Here we took Raw widget to limit width of button wrapping text content
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.circular(10.0),
              child: new MaterialButton(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: setUpButtonChild(),
                onPressed: () {
                  setState(() {
                    if (_state == 0) {
                      animateButton();
                    }
                  });
                },
                elevation: 5.0,
                height: 48.0,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }

    Widget mySizedBox(double height) {
      return new SizedBox(
        height: height,
      );
    }

    return Scaffold(
      appBar: new AppBar(
        leading: Icon(
          Icons.person,
          color: Colors.white,
        ),
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            mySizedBox(50.0),
            new FlutterLogo(
              size: 100.0,
              colors: Colors.blue,
            ),
            mySizedBox(50.0),
            email(),
            mySizedBox(50.0),
            password(),
            mySizedBox(40.0),
            loginButton(),
          ],
        ),
      ),
    );
  }
}
