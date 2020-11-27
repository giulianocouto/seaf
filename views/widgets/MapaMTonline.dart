// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// //import 'package:flutter_map/flutter_map.dart';
//
// // mapa para adicionar viagens/ visitas pelo estado( retornando posição geografica, usuario, local, data visita, guardada em banco de dados)
// class MapaMTonline extends StatefulWidget {
//   @override
//   _MapaMTonlineState createState() => _MapaMTonlineState();
// }
//
// class _MapaMTonlineState extends State<MapaMTonline> {
//   GoogleMapController _controller;
//   List<Marker> allMarkers = [];
//
//
//   TextEditingController _controllerEmail = TextEditingController();
//   Firestore _db = Firestore.instance;
//
//
//
//   _adicionarListenerLocalizacao() {
//     var geolocator = Geolocator();
//     var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);
//     geolocator.getPositionStream(locationOptions).listen((Position position) {
//
//
//     });
//   }
//
//   _verificarUsuarioLogado() async {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     FirebaseUser usuarioLogado = await auth.currentUser();
//     if (usuarioLogado != null) {
//       setState(() {
//         String email = usuarioLogado.email;
//         _controllerEmail.text = (email);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _verificarUsuarioLogado();
//     _exibirMarcadores;
//     _adicionarListenerLocalizacao();
//     Geolocator().getCurrentPosition().then((currloc) {
//       setState(() {
//         currentLocation = currloc;
//         mapToggle = true;
//         numEquipamentos();
//       });
//     });
//   }
//
//   numEquipamentos() {
//     equipamentos = [];
//     Firestore.instance.collection("equipamentos").getDocuments().then((docs) {
//       if (docs.documents.isNotEmpty) {
//         for (int i = 0; i < docs.documents.length; ++i) {
//           equipamentos.add(docs.documents[i].data);
//           initMarker(docs.documents[i].data);
//           //   _exibirMarcadores(docs.documents[i].data);
//         }
//       }
//     });
//   }
//
//   initMarker(equipamento) {
//     List<Marker> _markers = <Marker>[];
//
//     _markers.add(
//         Marker(
//           markerId: MarkerId("id"),
//           position: LatLng(equipamento['latlong'].latitude,
//               equipamento['latlong'].longitude),
//           draggable: false,
//           infoWindow: InfoWindow(title: 'equipamentos'),
//         )
//     );
//     setState(() {
//       _markers.clear();
//     });
//   }
//
//   _exibirMarcadores(LatLng latLng) async {
//     //buscar lista de endereços
//     List<Placemark> listaEnderecos = await Geolocator()
//         .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
//
//     if (listaEnderecos != null && listaEnderecos.length > 0) {
//       Placemark endereco = listaEnderecos[0];
//       String latitude = endereco.position.latitude.toString();
//       String longitude = endereco.position.longitude.toString();
//       String cidade = endereco.subAdministrativeArea;
//
//
//       Marker marcador = Marker(
//         markerId: MarkerId("marcador- ${latLng.latitude}, ${latLng.longitude}"),
//         position: latLng,
//         draggable: false,
//         infoWindow: InfoWindow(snippet: "local visitado", title: cidade),
//
//
//       );
//       //  Set<Polygon> listaPolygons = {};
//       //  Polygon polygon = Polygon(
//       //      polygonId:PolygonId("polygon"),
//       //      fillColor: Colors.green,
//       //      strokeColor: Colors.red,
//       //      strokeWidth: 10,
//       //      points: [latLng],
//       //      consumeTapEvents: true,
//       //      onTap: (){
//       //     //   print("clicado na área");
//       //      }
//       //  );
//       // listaPolygons.add(polygon);
//       //  setState(() {
//       //    _polygons.add(polygon);
//       //    _polygons = listaPolygons;
//       //    _marcadores.add(marcador);
//       //    // //  _markers.clear();
//
//
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Scaffold(
//           appBar: AppBar(
//             title: Text("Definindo viagens"),
//             centerTitle: true,
//           ),
//           body:
//               Stack(
//                 children: <Widget>[
//                   Container(
//                       height: MediaQuery
//                           .of(context).size.height - 50.0,
//                       width: MediaQuery.of(context).size.width,
//                       child: mapToggle ?
//                       GoogleMap(
//                          initialCameraPosition: CameraPosition(
//                            target: LatLng(-15.557404, -56.037753), zoom: 12.0
//                          ),
//                           onMapCreated: MapCreated,
//
//
//                       ):
//                       Center(child:
//                       Text("carregando espere",
//                         style: TextStyle(
//                             fontSize: 20.0
//                         ),))
//                   )
//                 ],
//               ),
//           );
//   }
//
//     void MapCreated(controller) {
//       setState(() {
//        _controller = controller;
//       });
//     }
//   }
