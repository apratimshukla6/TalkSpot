import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_spot/helper/constants.dart';
import 'package:talk_spot/helper/helperfunctions.dart';
import 'package:talk_spot/services/auth.dart';
import 'package:talk_spot/helper/authenticate.dart';
import 'package:talk_spot/services/database.dart';
import 'package:talk_spot/screens/conversation_screen.dart';
import 'package:talk_spot/screens/search.dart';
import 'package:talk_spot/widgets/widget.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatRoomsStream;

  @override
  void initState() {
    getUserInfo();
    databaseMethods.getChatRooms(Constants.myName).then((val) {
      setState(() {
        chatRoomsStream = val;
      });
    });
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions().getUserName();
    print(Constants.myName);
  }

  logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.clear();
    authMethods.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Authenticate()));
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.documents[index].data["chatRoomId"]
                        .toString()
                        .contains(Constants.myName)) {
                      return ChatRoomTile(
                          snapshot.data.documents[index].data["chatRoomId"]
                              .toString()
                              .replaceAll("_", "")
                              .replaceAll(Constants.myName, ""),
                          snapshot.data.documents[index].data["chatRoomId"]);
                    }
                    return Container();
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: chatRoomList(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          },
        ),
        appBar: AppBar(
          title: Text(
            'TalkSpot - ' + Constants.myName,
            style: TextStyle(fontSize: 22),
          ),
          backgroundColor: Color.fromRGBO(13, 35, 197, 80),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    backgroundColor: Colors.blue[900],
                    title: Text(
                      'Are you sure you want to logout?',
                      style: simpleTextFieldStyle(),
                    ),
                    content: Text(
                      'We hate to see you leave...',
                      style: simpleTextFieldStyle(),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('No'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          logoutUser();
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
        ));
  }
}

class ChatRoomTile extends StatelessWidget {
  final String chatRoomId;
  final String userName;
  ChatRoomTile(this.userName, this.chatRoomId);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(chatRoomId, userName)));
      },
      child: Container(
          //margin: EdgeInsets.only(bottom: 8),
          color: Colors.black54,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 22),
          child: Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100)),
                child: Text(
                  userName.substring(0, 1),
                  style: TextStyle(fontSize: 19),
                ),
              ),
              SizedBox(width: 10),
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          )),
    );
  }
}
