import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';


//Flutter - Retrieving markers from Firestore

class MapaMarcadores extends StatefulWidget {
  @override
  _MapaMarcadoresState createState() => _MapaMarcadoresState();
}

class _MapaMarcadoresState extends State<MapaMarcadores> {

    List<Marker> allMarkers = [];
      setMarkers(){
        return allMarkers;
     }

     addToList() async {
        final query = "cuiabá, MT";
        var addresses = await Geocoder.local.findAddressesFromQuery(query);
        var first = addresses.first;
        setState(() {

            allMarkers.add(Marker(
                width: 45.0,
                height: 45.0,
                point:
                   LatLng(first.coordinates.latitude, first.coordinates.longitude),
                builder: (context) =>
                new Container(
                  child: IconButton(
                    icon: Icon(Icons.location_on),
                    color: Colors.blue,
                    iconSize: 45.0,
                    onPressed: () {
                      print(first.featureName);
                    },
                  ),
                )));

        },
        );
     }
      Future addMarker() async {
        await showDialog(
            context: context,
          barrierDismissible: true,
          builder: (BuildContext context){
              return new SimpleDialog(
                title: new Text(
                  'Adicionar Marcadores',
                  style: new TextStyle( fontSize: 17.0),
               ),
              children: <Widget>[
                new SimpleDialogOption(
                  child: new Text('Adicione',
                  style: new TextStyle(color:Colors.blue),),
                  onPressed: (){
                    addToList();
                    Navigator.of(context).pop();
                  },
                )

              ],
              );
          });
      }

 Widget loadMap(){
        return StreamBuilder(
            stream:  Firestore.instance.collection('equipamentos').snapshots(),
            builder: (context, snapshot){
            if (!snapshot.hasData) return Text('Carregando mapa..espere');
          for (int i=0;i<snapshot.data.documents.length;i++){
         allMarkers.add(Marker(
             width: 45.0,
             height: 45.0,
             point: LatLng(
             snapshot.data.documents[i]['latlong'].latitude,
             snapshot.data.documents[i]['latlong'].longitude),

              builder: (context) =>
              new Container(
              child: IconButton(
              icon: Icon(Icons.location_on),
              color: Colors.blue,
              iconSize: 45.0,
              onPressed: () {
              print(snapshot.data.documents[i]['cidade']);

              //snapshot.data.documents[i]['cidade'];
              },
              ),
              )));
       }
             return FlutterMap(
              options: new MapOptions(
                  center: LatLng(-15.557404, -56.037753),minZoom: 5.7),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a','b','c']),
                new MarkerLayerOptions(markers: allMarkers)
              ],);
      },
        );
    }


    @override
    Widget build(BuildContext context) {
        return new Scaffold(
          appBar: new AppBar(
            title: Text('Todos equipamentos MT'),
            leading: IconButton(
                icon: Icon(Icons.add),
                onPressed: addMarker,
            ),
            centerTitle: true,
            ),
          body: loadMap()
        );

  }
}
