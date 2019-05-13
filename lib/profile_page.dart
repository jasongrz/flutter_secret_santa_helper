import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({Key key, this.userId}) : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final imageUrlController = new TextEditingController();
  final nameController = new TextEditingController();
  final wishOneController = new TextEditingController();
  final wishTwoController = new TextEditingController();
  final wishThreeController = new TextEditingController();
  final wishFourController = new TextEditingController();
  final wishFiveController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('users').document(widget.userId).snapshots(),
          builder: (BuildContext context, snapshot){
            switch (snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return new Column(
                  children: <Widget>[
                    InkWell(
                      child: CircleAvatar(
                        radius: 125,
                        backgroundImage: NetworkImage(snapshot.data['avatar']),
                      ),
                      onLongPress: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("Update your avatar image url"),
                              content: TextField(
                                decoration: InputDecoration(labelText: "Image url"),
                                controller: imageUrlController,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: (){
                                    imageUrlController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Submit"),
                                  onPressed: (){
                                    Firestore.instance.collection('users').document(widget.userId).updateData({"avatar": imageUrlController.text});
                                    imageUrlController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                    SizedBox(height: 20,),
                    Text(snapshot.data['email']),
                    SizedBox(height: 10,),
                    InkWell(
                      child:  Text(snapshot.data['name']),
                      onLongPress: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("Update your name"),
                              content: TextField(
                                decoration: InputDecoration(labelText: "Name"),
                                controller: nameController,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: (){
                                    nameController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Submit"),
                                  onPressed: (){
                                    Firestore.instance.collection('users').document(widget.userId).updateData({"name": nameController.text});
                                    nameController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                    RaisedButton(
                      child: Text("Wishlist"),
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("Update Wishlist"),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: wishOneController,
                                      decoration: InputDecoration(
                                        labelText: "Wish #1",
                                        hintText: snapshot.data['wishlist'][0],
                                      ),
                                    ),
                                    TextField(
                                      controller: wishTwoController,
                                      decoration: InputDecoration(
                                        labelText: "Wish #2",
                                        hintText: snapshot.data['wishlist'][1],
                                      ),
                                    ),
                                    TextField(
                                      controller: wishThreeController,
                                      decoration: InputDecoration(
                                        labelText: "Wish #3",
                                        hintText: snapshot.data['wishlist'][2],
                                      ),
                                    ),
                                    TextField(
                                      controller: wishFourController,
                                      decoration: InputDecoration(
                                        labelText: "Wish #4",
                                        hintText: snapshot.data['wishlist'][3],
                                      ),
                                    ),
                                    TextField(
                                      controller: wishFiveController,
                                      decoration: InputDecoration(
                                        labelText: "Wish #5",
                                        hintText: snapshot.data['wishlist'][4],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: (){
                                    wishOneController.clear();
                                    wishTwoController.clear();
                                    wishThreeController.clear();
                                    wishFourController.clear();
                                    wishFiveController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Submit"),
                                  onPressed: (){
                                    Firestore.instance.collection('users').document(widget.userId)
                                    .updateData({"wishlist": [wishOneController.text, wishTwoController.text, wishThreeController.text, wishFourController.text, wishFiveController.text]});
                                    wishOneController.clear();
                                    wishTwoController.clear();
                                    wishThreeController.clear();
                                    wishFourController.clear();
                                    wishFiveController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    ),
                  ],
                );
              }
            },
        ),
      ),
    );
  }
}