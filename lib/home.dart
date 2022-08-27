

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:grocery/profile.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection("Products");

  final TextEditingController nameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  Future<void> createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "Update";
      nameController.text = documentSnapshot["name"];
      priceController.text = documentSnapshot["price"].toString();
    }
    await showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom:   MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: "Price",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      String name = nameController.text;
                      double price = double.parse(priceController.text);

                      if (name != null && price != null) {
                        if (action == 'create') {
                          await _products.add({"name": name, "price": price});
                        }
                        if (action == "update") {
                          await _products
                              .doc(documentSnapshot!.id)
                              .update({"name": name, "price": price});
                        }
                        nameController.text = "";
                        priceController.text = "";
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(action == "create" ? "Create" : "Update"))
              ],
            ),
          );
        });
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Product deleted successfully"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text("Products"),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ProfileView ();
              }));
            },
            icon: Icon(Icons.person,
            color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                            title: Text(documentSnapshot["name"]),
                            subtitle: Text(
                              documentSnapshot["price"].toString(
                                trailing: SizedBox(
                                  width:  100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            createOrUpdate(documentSnapshot);
                                          },
                                          icon: Icon(Icons.edit)),
                                      IconButton(
                                        onPressed: () {
                                          deleteProduct(documentSnapshot.id);
                                        },
                                        icon: Icon(Icons.delete),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )));
                  });
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createOrUpdate();
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}
