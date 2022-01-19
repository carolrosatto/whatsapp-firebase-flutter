// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/models/model.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _loggedUserId;

  Future<List<LoggedUser>> _getContacts() async {
    final userRef = _firestore.collection("users");
    QuerySnapshot querySnapshot = await userRef.get();
    List<LoggedUser> usersList = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      String userId = item["userId"];
      if (userId == _loggedUserId) continue;
      String name = item["name"];
      String email = item["email"];
      String imageUrl = item["imageUrl"];

      LoggedUser loggedUser =
          LoggedUser(userId, name, email, imageUrl: imageUrl);
      usersList.add(loggedUser);
    }
    return usersList;
  }

  _getLoggedUserData() async {
    User? currentLoggedUser = await _auth.currentUser;
    if (currentLoggedUser != null) {
      _loggedUserId = currentLoggedUser.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _getLoggedUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoggedUser>>(
        future: _getContacts(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando contatos"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar os contatos"),
                );
              } else {
                List<LoggedUser>? usersList = snapshot.data;
                if (usersList != null) {
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      LoggedUser user = usersList[index];

                      return ListTile(
                        onTap: () {},
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(user.imageUrl),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(fontSize: 18),
                        ),
                        contentPadding: EdgeInsets.all(8),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey,
                        thickness: 0.2,
                      );
                    },
                    itemCount: usersList.length,
                  );
                }

                return Center(
                  child: Text("Nenhum contato encontrado"),
                );
              }
          }
        });
  }
}
