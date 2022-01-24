// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/models/model.dart';
import 'package:whatsapp_firebase/utils/color_pallet.dart';

class MessagesList extends StatefulWidget {
  final LoggedUser addresseeUser;
  final LoggedUser senderUser;

  const MessagesList({
    Key? key,
    required this.addresseeUser,
    required this.senderUser,
  }) : super(key: key);

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late LoggedUser _addresseeUser;
  late LoggedUser _senderUser;

  StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMessages;

  _sendMessage() {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      String idSenderUSer = _senderUser.userId;

      Message message = Message(
        idSenderUSer,
        messageText,
        Timestamp.now().toString(),
      );

      //Salvar a mensagem para o remetente
      String idAddresseeUser = _addresseeUser.userId;
      _saveMessage(idSenderUSer, idAddresseeUser, message);
      Chat senderChat = Chat(
        idSenderUSer,
        idAddresseeUser,
        message.text,
        _addresseeUser.name,
        _addresseeUser.email,
        _addresseeUser.imageUrl,
      );
      _saveChat(senderChat);

      //Salvar a mensagem para o destinatário
      _saveMessage(idAddresseeUser, idSenderUSer, message);
      Chat addresseeChat = Chat(
        idAddresseeUser,
        idSenderUSer,
        message.text,
        _senderUser.name,
        _senderUser.email,
        _senderUser.imageUrl,
      );
      _saveChat(addresseeChat);
    }
  }

  _saveChat(Chat chat) {
    _firestore
        .collection("chats")
        .doc(chat.senderId)
        .collection("last messages")
        .doc(chat.addresseeId)
        .set(chat.toMap());
  }

  _saveMessage(String idSender, String idAddressee, Message message) {
    _firestore
        .collection("messages")
        .doc(idSender)
        .collection(idAddressee)
        .add(message.toMap());

    _messageController.clear();
  }

  _getInitialData() {
    _addresseeUser = widget.addresseeUser;
    _senderUser = widget.senderUser;
    _addMessagesListener();
  }

  _addMessagesListener() {
    final stream = _firestore
        .collection("messages")
        .doc(_senderUser.userId)
        .collection(_addresseeUser.userId)
        .orderBy("date", descending: false)
        .snapshots();

    _streamMessages = stream.listen((data) {
      _streamController.add(data);
      Timer(
          Duration(seconds: 1),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamMessages.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(children: [
        //Lista de mensagens
        StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Expanded(
                    child: Center(
                      child: Column(children: [
                        Text("Carregando mensagens"),
                        CircularProgressIndicator()
                      ]),
                    ),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro ao carregar mensagens"),
                    );
                  } else {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    List<DocumentSnapshot> messagesList =
                        querySnapshot.docs.toList();
                    return Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot message = messagesList[index];
                            Alignment messageAlignment = Alignment.bottomLeft;
                            Color messageColor = Colors.white;
                            Size messageWidth =
                                MediaQuery.of(context).size * 0.8;

                            if (_senderUser.userId == message["userId"]) {
                              messageAlignment = Alignment.bottomRight;
                              messageColor =
                                  ColorPalette.messageBackgroundGreen;
                            }

                            return Align(
                              alignment: messageAlignment,
                              child: Container(
                                constraints: BoxConstraints.loose(messageWidth),
                                decoration: BoxDecoration(
                                    color: messageColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(6),
                                child: Text(message["text"]),
                              ),
                            );
                          }),
                    );
                  }
              }
            }),
        //Caixa de texto
        Container(
          padding: EdgeInsets.all(8),
          color: ColorPalette.chatInputBackground,
          child: Row(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_emoticon),
                    SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                            hintText: "Digite uma mensagem",
                            border: InputBorder.none),
                      ),
                    ),
                    Icon(Icons.attach_file),
                    Icon(Icons.camera_alt),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              backgroundColor: ColorPalette.primaryColor,
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            )
          ]),
        )
      ]),
    );
  }
}
