
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Authenticate/Methods.dart';
import '../constants.dart';
import '../group_chats/group_chat_screen.dart';
import 'ChatRoom.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    if (_search.text.isEmpty) {
      AppSnackBar.show('Error', 'Please enter a valid email', Colors.red);
      return;
    }
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text.trim())
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        AppSnackBar.show('Successfully', 'User available', Colors.green);
      } else {
        setState(() {
          userMap = null;
          isLoading = false;
          AppSnackBar.show('Error', 'Please enter a valid email', Colors.red);
        });
      }
      print(userMap);
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: onSearch,
                  child: Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: ListTile(
                          onTap: () async {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName!,
                                userMap!['name']);
                            String? fcmToken = await FirebaseMessaging.instance.getToken();
                            print(fcmToken);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap!,
                                  fcmtoken: fcmToken,
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(child: Icon(Icons.person),),
                          title: Text(
                            userMap!['name'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(userMap!['email']),
                          trailing: Icon(Icons.chat, color: Colors.black),
                        ),
                    )
                    : Container(),

              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.group),
      //   onPressed: () => Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (_) => GroupChatHomeScreen(),
      //     ),
      //   ),
      // ),
    );
  }
}
