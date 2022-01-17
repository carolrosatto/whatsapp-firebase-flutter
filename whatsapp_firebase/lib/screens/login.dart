// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_firebase/utils/color_pallet.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _userRegister = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _selectedImageArchive;

  _selectImage() async {
    //Seleciona o arquivo:
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    //Recupera o arquivo:
    setState(() {
      _selectedImageArchive = result?.files.single.bytes;
    });
  }

  _uploadImage(String userId) {
    Uint8List? selectedArchive = _selectedImageArchive;
    if (selectedArchive != null) {
      Reference profileImageRef = _storage.ref("images/profile/$userId.jpg");
      UploadTask uploadTask = profileImageRef.putData(selectedArchive);

      uploadTask.whenComplete(() async {
        String linkImage = await uploadTask.snapshot.ref.getDownloadURL();
        print("$linkImage");
      });
    }
  }

  _inputValidation() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (password.isNotEmpty && password.length >= 6) {
        if (_userRegister) {
          if (_selectedImageArchive != null) {
            if (name.isNotEmpty && name.length > 3) {
              await _auth
                  .createUserWithEmailAndPassword(
                      email: email, password: password)
                  .then((auth) {
                //Após criar o usuário, vamos fazer o upload da imagem:
                String? userId = auth.user?.uid;
                if (userId != null) {
                  _uploadImage(userId);
                }
              });
            } else {
              print("Usuário inválido");
            }
          } else {
            print("Selecione uma imagem");
          }
        } else {
          await _auth
              .signInWithEmailAndPassword(email: email, password: password)
              .then((auth) {
            String? email = auth.user?.email;
            print("Email cadastrado: $email");
          });
        }
      } else {
        print("Senha inválida");
      }
    } else {
      print("E-mail inválido");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: ColorPalette.backgroundLogin,
          width: screenWidth,
          height: screenHight,
          child: Stack(children: [
            Positioned(
              child: Container(
                width: screenWidth,
                height: screenHight * 0.4,
                color: ColorPalette.primaryColor,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Container(
                      padding: EdgeInsets.all(40),
                      width: 600,
                      child: Column(children: [
                        Visibility(
                          visible: _userRegister,
                          child: ClipOval(
                            child: _selectedImageArchive != null
                                ? Image.memory(
                                    _selectedImageArchive!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "images/perfil.png",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Visibility(
                          visible: _userRegister,
                          child: OutlinedButton(
                            onPressed: () => _selectImage(),
                            child: Text("Selecionar foto",
                                style: TextStyle(
                                    color: ColorPalette.primaryColor)),
                          ),
                        ),
                        SizedBox(height: 8),
                        Visibility(
                          visible: _userRegister,
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: "Nome",
                                labelText: "Nome",
                                suffixIcon: Icon(Icons.person_outline)),
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "email@email.com",
                            labelText: "E-mail",
                            suffixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                              hintText: "Senha",
                              labelText: "Senha",
                              suffixIcon: Icon(Icons.lock_outline)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _inputValidation(),
                            style: ElevatedButton.styleFrom(
                                primary: ColorPalette.primaryColor),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _userRegister ? "Cadastrar" : "Login",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        Row(children: [
                          Text("Login"),
                          Switch(
                              activeColor: ColorPalette.primaryColor,
                              value: _userRegister,
                              onChanged: (bool value) {
                                setState(() {
                                  _userRegister = value;
                                });
                              }),
                          Text("Cadastro"),
                        ])
                      ]),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
