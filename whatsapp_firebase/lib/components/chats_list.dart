import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/models/logged_user.dart';

class ChatsList extends StatefulWidget {
  const ChatsList({Key? key}) : super(key: key);

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late LoggedUser _senderUser;
  StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamChats;

  _addChatListener() {
    final stream = _firestore
        .collection("chats")
        .doc(_senderUser.userId)
        .collection("last messages")
        .snapshots();

    _streamChats = stream.listen((data) {
      _streamController.add(data);
    });
  }

  _getInitialData() {
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
    _addChatListener();
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  @override
  void dispose() {
    _streamChats.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(children: [
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ]),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar conversas"),
                );
              } else {
                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                List<DocumentSnapshot> chatList = querySnapshot.docs.toList();
                return ListView.separated(
                  separatorBuilder: (context, indice) {
                    return Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot chat = chatList[index];
                    String addresseeImageUrl = chat["addresseeImageUrl"];
                    String addresseeName = chat["addresseeName"];
                    String addresseeEmail = chat["addresseeEmail"];
                    String addresseeId = chat["addresseeId"];
                    String lastMessage = chat["lastMessage"];

                    LoggedUser addresseeUser = LoggedUser(
                      addresseeId,
                      addresseeName,
                      addresseeEmail,
                      imageUrl: addresseeImageUrl,
                    );

                    return ListTile(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/messages",
                            arguments: addresseeUser);
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          addresseeUser.imageUrl,
                        ),
                      ),
                      title: Text(
                        addresseeUser.name,
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: EdgeInsets.all(8),
                    );
                  },
                );
              }
          }
        });
  }
}
