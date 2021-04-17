import 'dart:convert';
import 'package:sk_alert_dialog/sk_alert_dialog.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secilenSehir = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/back.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 90),
                child: TextField(
                  controller: secilenSehir,
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Şehir seçiniz.',
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  var a = secilenSehir.text;
                  print(a);
                  var response = await http.get(
                      'https://www.metaweather.com/api/location/search/?query=$a');
                  jsonDecode(response.body).isEmpty
                      ? SKAlertDialog.show(
                          context: context,
                          type: SKAlertType.info,
                          title: 'Hatalı bir işlem yapıldı',
                          message: 'Şehir ismini yanlış girdiniz...',
                          onOkBtnTap: (value) {
                            print('hahaha');
                          },
                        )
                      : Navigator.pop(context, secilenSehir.text);
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Ara',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 25,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.search,
                        size: 30,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
