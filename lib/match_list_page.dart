import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MatchlistPage extends StatefulWidget {
  MatchlistPage({Key key, this.userId}) : super(key: key);
  final String userId;
  _MatchlistPageState createState() => _MatchlistPageState();
}

class _MatchlistPageState extends State<MatchlistPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("matches").where("santa_id", isEqualTo: widget.userId).snapshots(),
      builder: (BuildContext context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.data.documents.isEmpty){
              return Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 250,),
                    Text("No matches set yet"),
                  ],
                ),
              );
            }
            else {
              return Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: snapshot.data.documents
                          .map((DocumentSnapshot document){
                            return Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: CustomCard(
                                      groupName: document["group_name"],
                                      recipient: document["recipient_id"],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }
        }
      },
    );
  }
}

class CustomCard extends StatefulWidget {
  CustomCard({Key key, this.groupName, this.recipient}) : super(key: key);
  final groupName;
  final recipient;

  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document(widget.recipient).snapshots(),
      builder: (BuildContext context, snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            return InkWell(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Here are some gift ideas for " + snapshot.data["name"]),
                      content: Column(
                        children: <Widget>[
                          Text(snapshot.data["wishlist"][0]),
                          SizedBox(height: 25,),
                          Text(snapshot.data["wishlist"][1]),
                          SizedBox(height: 25,),
                          Text(snapshot.data["wishlist"][2]),
                          SizedBox(height: 25,),
                          Text(snapshot.data["wishlist"][3]),
                          SizedBox(height: 25,),
                          Text(snapshot.data["wishlist"][4]),
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Ok"),
                          onPressed: (){Navigator.pop(context);},
                        ),
                      ],
                    );
                  }
                );
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Text(widget.groupName, style: TextStyle(fontSize: 20),),
                      SizedBox(height: 5,),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(snapshot.data["avatar"]),
                      ),
                      SizedBox(height: 5,),
                      Text(snapshot.data["name"]),
                      SizedBox(height: 5,),
                    ],
                  ),
                ),
              ),
            );
          }
        },
    );
  }
}
