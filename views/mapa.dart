import 'package:agriculturafamiliar/models/Destino.dart';
import 'package:agriculturafamiliar/models/Requisicao.dart';
import 'package:agriculturafamiliar/models/Usuario.dart';
import 'package:agriculturafamiliar/util/StatusRequisicao.dart';
import 'package:agriculturafamiliar/util/UsuarioFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class mapa extends StatefulWidget {
  @override
  _mapaState createState() => _mapaState();
}

class _mapaState extends State<mapa> {
  TextEditingController _controllerDestino =
      TextEditingController(text: "Parque das Nações, Cuiabá - MT");

  List<String> itensMenu = ["Configurações", "Deslogar"];
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-15.548125, -56.080960),
  );
  Set<Marker> _marcadores = {};

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case "Deslogar":
        _deslogarUsuario();
        break;
      case "Configurações":
        break;
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      _exibirMarcadorUsuario(position);
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);

      _movimentarCamera(_posicaoCamera);
    });
  }

  _recuperaUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if (position != null) {
        _exibirMarcadorUsuario(position);
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);

        _movimentarCamera(_posicaoCamera);
      }
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _exibirMarcadorUsuario(Position Local) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcadorUsuario = Marker(
          markerId: MarkerId("marcador-usuario"),
          position: LatLng(Local.latitude, Local.longitude),
          infoWindow: InfoWindow(title: "local atual"),
          icon: icone);

      setState(() {
        _marcadores.add(marcadorUsuario);
      });
    });
  }

  _buscaequipamento() async {
    String enderecoDestino = _controllerDestino.text;
    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEnderecos =
          await Geolocator().placemarkFromAddress(enderecoDestino);
      if (listaEnderecos != null && listaEnderecos.length > 0) {
        //recuperar o primeiro endereço é o mais proximo do endereço digitado
        Placemark endereco = listaEnderecos[0];
        // instanciar a classe destino para chamar todos campos como latitude longitutde
        Destino destino = Destino();
        destino.cidade = endereco.subAdministrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.numero = endereco.subThoroughfare;

        //lembra latitude longitude campo double
        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;

        // criando mensagem dialog de confirmação do endereço

        String enderecoConfirmacao;
        enderecoConfirmacao = "\n Cidade : " + destino.cidade;
        enderecoConfirmacao +=
            "\n Cep : " + destino.cep + "\n bairro : " + destino.bairro;
        enderecoConfirmacao += "\n rua : " + destino.rua + "," + destino.numero;
        enderecoConfirmacao += "\n Latitude : " + (destino.latitude).toString();
        enderecoConfirmacao +=
            "\n Longitude : " + (destino.longitude).toString();

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Confirmação da geolocalização do equipamento"),
                content: Text(enderecoConfirmacao),
                contentPadding: EdgeInsets.all(30),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text(
                      "Confirmar",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                    Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperaUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rastrear local Equipamento"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            //imagem o texto sobrepoem a imagem fica por cima
            //texto
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              //  myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
            ),
            Positioned(
              top: 100,
              child: Image.asset(
                "imagens/logo.png",
                width: 180,
                height: 100,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.transparent,
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20),
                          width: 10,
                          height: 10,
                          child: Icon(Icons.location_on, color: Colors.green),
                        ),
                        hintText: "local atual",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, top: 16)),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 55,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.transparent,
                  ),
                  child: TextField(
                    controller: _controllerDestino,
                    decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20),
                          width: 10,
                          height: 10,
                          child: Icon(Icons.location_city,
                              color: Colors.blueAccent),
                        ),
                        hintText: "buscar o destino",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, top: 16)),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                    : EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      "equipamento",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Color(0xff000080),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: () {
                      _buscaequipamento();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
