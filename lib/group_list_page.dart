import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GrouplistPage extends StatefulWidget {

  GrouplistPage({Key key, this.userId}) : super(key: key);

  final String userId;

  _GrouplistPageState createState() => _GrouplistPageState();
}

class _GrouplistPageState extends State<GrouplistPage> {
  final groupNameController = new TextEditingController();
  final groupTimeController = new TextEditingController();
  final groupPriceController = new TextEditingController();
  final userNameController = new TextEditingController();

  _inviteUsers(var docId) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text("Please enter user email to invite"),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: "User Email"),
            controller: userNameController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Done"),
              onPressed: (){
                var _invite = Firestore.instance.collection('users').where('email', isEqualTo: userNameController.text).limit(1);
                _invite.getDocuments().then((data){
                  if (data.documents.length > 0){
                    Firestore.instance.collection('groups').document(docId).updateData({
                      "users": FieldValue.arrayUnion([data.documents[0].documentID])
                    });
                  }
                });
                userNameController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          content: Column(
            children: <Widget>[
              Text("Please fill all fields to host group"),
              TextField(
                decoration: InputDecoration(labelText: 'Group Name'),
                controller: groupNameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Price Limit'),
                controller: groupPriceController,
                keyboardType: TextInputType.number,
              ),
              DateTimePickerFormField(
                inputType: InputType.both,
                format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                editable: true,
                decoration: InputDecoration(labelText: 'Date/Time'),
                controller: groupTimeController,
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                groupNameController.clear();
                groupTimeController.clear();
                groupPriceController.clear();
                Navigator.pop(context);
              }
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: (){
                if (groupNameController.text.isNotEmpty && groupTimeController.text.isNotEmpty){
                  Firestore.instance.collection('groups').add({
                    "group_name": groupNameController.text,
                    "group_date": groupTimeController.text,
                    "host": widget.userId,
                    "price": groupPriceController.text,
                    "users": [widget.userId],
                    "match_set": false
                  }).then((result) => {
                    groupNameController.clear(),
                    groupTimeController.clear(),
                    groupPriceController.clear(),
                    Navigator.pop(context)
                  });
                }
              },
            )
          ],
        );
      } 
    );
  }

  _deleteGroup(docID) async{
    await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          title: Text("Delete Group?"),
          content: Text("Are you sure you want to delete this group?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: (){
                Firestore.instance.collection("groups").document(docID).delete();
                Firestore.instance.collection("matches").where("group_id", isEqualTo: docID)
                .getDocuments().then((snapshot){
                  for(DocumentSnapshot ds in snapshot.documents){
                    ds.reference.delete();
                  }
                });
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("No"),
              onPressed: (){Navigator.pop(context);},
            ),
          ],
        );
      }
    );
  }

  _matchSantas(docID, groupName, groupArray) async{
     await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          title: Text("Match Santas?"),
          content: Text("Are you sure you want to close the group and match santas?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: (){
                Firestore.instance.collection("groups").document(docID).updateData({"match_set": true});
                groupArray.shuffle();
                var j;
                for(var i = 0; i < groupArray.length; i++){
                  if(i == groupArray.length-1){
                    j = 0;
                  }
                  else{
                    j = i + 1;
                  }
                  Firestore.instance.collection("matches").add({
                    "group_name": groupName,
                    "group_id": docID,
                    "santa_id": groupArray[i],
                    "recipient_id": groupArray[j]
                  });
                }
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("No"),
              onPressed: (){Navigator.pop(context);},
            ),
          ],
        );
      }
    );
  }

  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("groups").where("users", arrayContains: widget.userId).snapshots(),
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
                    Text("Not in any groups yet"),
                    SizedBox(height: 20,),
                    FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: (){_showDialog();},
                    )
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
                                  FlatButton(
                                    child: Icon(Icons.group_add),
                                    onPressed: (){
                                      if(!document["match_set"]){
                                        _inviteUsers(document.documentID);
                                      }
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              title: Text("Unable to invite users"),
                                              content: Text("Group is closed and santas have been matched."),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Ok"),
                                                  onPressed: (){Navigator.pop(context);},
                                                ),
                                              ],
                                            );
                                          }
                                        );
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      child: CustomCard(
                                        groupName: document["group_name"],
                                        groupDate: document["group_date"],
                                        groupCount: document["users"].length,
                                        groupPrice: document["price"]
                                      ),
                                      onTap: (){
                                        if(!document["match_set"]){
                                          _matchSantas(document.documentID, document["group_name"], document["users"]);
                                        }
                                        else{
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                content: Text("Matches have already been set! Check your matches tab."),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: (){Navigator.pop(context);},
                                                  ),
                                                ],
                                              );
                                            }
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  FlatButton(
                                    child: Icon(Icons.delete_forever),
                                    onPressed: (){
                                      if(document["host"] == widget.userId){
                                        _deleteGroup(document.documentID);
                                      }
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              content: Text("Sorry, only the host can delete this group"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Ok"),
                                                  onPressed: (){Navigator.pop(context);},
                                                ),
                                              ],
                                            );
                                          }
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: (){_showDialog();},
                      ),
                    )
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
  CustomCard({Key key, this.groupName, this.groupDate, this.groupCount, this.groupPrice}) : super(key: key);
  final groupName;
  final groupDate;
  final groupCount;
  final groupPrice;

  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text(widget.groupName, style: TextStyle(fontSize: 25, fontFamily: "Ewert",),),
            SizedBox(height: 5,),
            Text(widget.groupDate),
            SizedBox(height: 5,),
            (widget.groupCount==1)?
              Text(widget.groupCount.toString() + " user in the group"):
              Text(widget.groupCount.toString() + " users in the group"),
            SizedBox(height: 5,),
            Text("Limit: \$" + widget.groupPrice)
          ],
        ),
      ),
    );
  }
}