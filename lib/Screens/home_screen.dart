import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hutangku/Components/remainder.dart';
import 'package:hutangku/utils/database.dart';
import 'package:hutangku/constants.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  String? _setDate;
  DateTime selectedDate = DateTime.now();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(
            'Hutangku App',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTextColor),
          ),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Remainder(
                  title: 'Hutang Paling Lama',
                  nama: 'Andrianto',
                  jumlah: '20000',
                  tanggal: '10 Juli 2021'),
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: Database.readItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    } else if (snapshot.hasData || snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];
                          String docID = snapshot.data!.docs[index].id;
                          var tanggal = documentSnapshot['tanggal'].toDate();
                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.15,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
                              padding: EdgeInsets.fromLTRB(5, 13, 5, 13),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    DateFormat('dd MMM yyyy').format(tanggal),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Container(
                                    width: 180,
                                    child: Text(
                                      documentSnapshot['nama'],
                                      style: TextStyle(
                                          color: CustomColors.TextHeader,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text("Rp." +
                                      documentSnapshot["jumlah"].toString()),
                                ],
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  stops: [0.015, 0.015],
                                  colors: [
                                    ((documentSnapshot["completed"] == true)
                                        ? CustomColors.GreenIcon
                                        : CustomColors.YellowIcon),
                                    Colors.white
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomColors.GreyBorder,
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                    offset: Offset(0.0, 0.0),
                                  ),
                                ],
                              ),
                            ),
                            secondaryActions: <Widget>[
                              SlideAction(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: CustomColors.GreenBackground),
                                      child: Icon(
                                        Icons.check,
                                        color: CustomColors.GreenIcon,
                                      )),
                                ),
                                onTap: () => {_setComplete(docID)},
                              ),
                              SlideAction(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: CustomColors.BlueBackground),
                                      child: Icon(
                                        Icons.drive_file_rename_outline,
                                        color: CustomColors.BlueIcon,
                                      )),
                                ),
                                onTap: () =>
                                    {_createOrUpdate(documentSnapshot)},
                              ),
                              SlideAction(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color:
                                              CustomColors.TrashRedBackground),
                                      child: Icon(
                                        Icons.delete,
                                        color: CustomColors.TrashRed,
                                      )),
                                ),
                                onTap: () {
                                  _deleteData(docID);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {_createOrUpdate()},
          child: Icon(Icons.add),
        ));
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _tanggalController.text = DateFormat.yMd().format(selectedDate);
      });
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';

      DateTime tanggal = documentSnapshot['tanggal'].toDate();

      _namaController.text = documentSnapshot['nama'];
      _jumlahController.text = documentSnapshot['jumlah'].toString();
      _tanggalController.text = DateFormat.yMd().format(tanggal);
    }

    await showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: _jumlahController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                  ),
                ),
                TextField(
                    // style: TextStyle(fontSize: 40),
                    // textAlign: TextAlign.center,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    controller: _tanggalController,
                    onChanged: (String val) {
                      _setDate = val;
                    },
                    onTap: () {
                      _selectDate(context);
                    },
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                    )),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String nama = _namaController.text;
                    final double? jumlah =
                        double.tryParse(_jumlahController.text);
                    if (nama != "" && jumlah != null) {
                      setState(() {
                        _isProcessing = true;
                      });

                      if (documentSnapshot != null) {
                        await Database.updateItem(
                            docId: documentSnapshot.id,
                            nama: nama,
                            jumlah: jumlah.toDouble(),
                            tanggal: selectedDate,
                            completed: documentSnapshot['completed']);
                      } else {
                        await Database.addItem(
                            nama: nama,
                            jumlah: jumlah.toDouble(),
                            tanggal: selectedDate,
                            completed: false);
                      }

                      setState(() {
                        _isProcessing = false;
                      });

                      _namaController.text = "";
                      _jumlahController.text = "";
                      _tanggalController.text = "";

                      Navigator.of(context).pop();
                    } else {
                      print("invalid form");
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _setComplete(String docID) async {
    setState(() {
      _isProcessing = true;
    });

    await Database.setComplete(
      docId: docID,
    );

    setState(() {
      _isProcessing = false;
    });

    // Show a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Yeeey... Hutang Berkurang')));
  }

  Future<void> _deleteData(String docID) async {
    setState(() {
      _isProcessing = true;
    });

    await Database.deleteItem(
      docId: docID,
    );

    setState(() {
      _isProcessing = false;
    });

    // Show a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Data Berhasil Dihapus')));
  }
}
