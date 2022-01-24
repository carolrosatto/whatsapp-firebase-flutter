// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/components/messages_list.dart';
import 'package:whatsapp_firebase/models/logged_user.dart';

class Message extends StatefulWidget {
  final LoggedUser addresseeUser;

  const Message(
    this.addresseeUser, {
    Key? key,
  }) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  late LoggedUser _addresseeUser;
  late LoggedUser _senderUser;
  FirebaseAuth _auth = FirebaseAuth.instance;

  _getInitialData() {
    _addresseeUser = widget.addresseeUser;
    User? loggedUser = _auth.currentUser;

    if (loggedUser != null) {
      String userId = loggedUser.uid;
      String? name = loggedUser.displayName ?? "";
      String? email = loggedUser.email ?? "";
      String? imageUrl = loggedUser.photoURL ?? "";

      _senderUser = LoggedUser(
        userId,
        name,
        email,
        imageUrl: imageUrl,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, "/home"),
                icon: Icon(Icons.arrow_back)),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:
                  CachedNetworkImageProvider(_addresseeUser.imageUrl),
            ),
            SizedBox(width: 8),
            Text(_addresseeUser.name),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      body: SafeArea(
        child: MessagesList(
          addresseeUser: _addresseeUser,
          senderUser: _senderUser,
        ),
      ),
    );
  }
}
