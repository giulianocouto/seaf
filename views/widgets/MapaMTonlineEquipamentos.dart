import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


//viagens para chelist equipakmentos

class MapaMTonlineEquipamentos extends StatefulWidget {

  String idViagem;

  MapaMTonlineEquipamentos({ this.idViagem });

  @override
  _MapaMTonlineEquipamentosState createState() => _MapaMTonlineEquipamentosState();
}

class _MapaMTonlineEquipamentosState extends State<MapaMTonlineEquipamentos> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-15.557404, -56.037753),
      zoom:6
  );
  Firestore _db = Firestore.instance;

  TextEditingController _controllerEmail = TextEditingController();
  _onMapCreated( GoogleMapController controller ){
    _controller.complete( controller );
  }

  _adicionarMarcador( LatLng latLng ) async {

    List<Placemark> listaEnderecos = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if( listaEnderecos != null && listaEnderecos.length > 0 ){
      Placemark endereco = listaEnderecos[0];
  //   double latitude  = endereco.position.latitude;
   //  double longitude = endereco.position.longitude;
      String cidade = endereco.subAdministrativeArea;

      // Placemark endereco = listaEnderecos[0];
      // String cidade = endereco.administrativeArea
      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
              title: cidade
          )


      );
      //setstate

      if (mounted) {
        setState(() {
          _marcadores.add(marcador);

          //Salva no firebase

          Map<String, dynamic> viagem = Map();
          viagem["cidade"] = cidade;
          viagem["latitude"] = latLng.latitude;
          viagem["longitude"] = latLng.longitude;
          viagem["datadia"] = DateTime.now().toString();
          viagem["usuario"] = _controllerEmail.text;

          _db.collection("viagens")
              .add(viagem);
        });
      }
    }

  }

  _verificarUsuarioLogado() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null){
      setState(() {
        String email = usuarioLogado.email;
        _controllerEmail.text = (email);
      });

    }
  }
  _movimentarCamera() async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
            _posicaoCamera
        )
    );

  }

  _adicionarListenerLocalizacao(){

    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);
    geolocator.getPositionStream( locationOptions ).listen((Position position){
     if (mounted)
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 6
        );
        _movimentarCamera();
      });

    });

  }

  _recuperaViagemParaID(String idViagem) async {

    if( idViagem != null ) {
      //exibir marcador para id viagem
      DocumentSnapshot documentSnapshot = await _db
          .collection("viagens")
          .document(idViagem)
          .get();

      var dados = documentSnapshot.data;

      String cidade = dados[("cidade")];
      LatLng latLng = LatLng(
          dados["latitude"],
          dados["longitude"]
      );
      if (mounted) {
        setState(() {
          Marker marcador = Marker(
              markerId: MarkerId(
                  "marcador-${latLng.latitude}-${latLng.longitude}"),
              position: latLng,
              infoWindow: InfoWindow(
                  title: cidade
              )
          );

          _marcadores.add(marcador);
          _posicaoCamera = CameraPosition(
              target: latLng,
              zoom: 6
          );
          _movimentarCamera();
        });
      } else {
        _adicionarListenerLocalizacao();
      }
    }
  }

  @override
  void initState() {
    super.initState();
 //   _adicionarListenerLocalizacao();
   _verificarUsuarioLogado();
    //Recupera viagem pelo ID
    _recuperaViagemParaID( widget.idViagem );
  }


  @override
  void dispose() {
    super.dispose();
  //  _verificarUsuarioLogado();
    //Recupera viagem pelo ID
    _recuperaViagemParaID( widget.idViagem );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Marcadores todos \n equipamentos Online"),),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,

        //  myLocationEnabled: true,
        ),
      ),
    );

  }
}
