import 'dart:async';
import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/views/DetalhesEquipamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


// mapa offline com todos os maquinarios cedidos para prefeituras, cooperativas

class MapaMT extends StatefulWidget {
  //DetalhesEquipamento detalhesEquipamento;
   Equipamentos equipamento;


  @override
  MapaMTState createState() => MapaMTState();
}

class MapaMTState extends State<MapaMT> {
  Completer<GoogleMapController> _controller = Completer();

  // teste marcadores 29/10
  _onMapCreater(GoogleMapController controller){
    _controller.complete(controller);
  }


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Equipamentos _equipamentos;
  final _controller1 = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
//equipamentos em offline quando sem sinal internet buscar equipamentos e alguns dados no mapa
  CameraPosition _posicaoCamera =  CameraPosition(
    target: LatLng(-10.473297, -50.505114),
  );
  Set<Marker>_marcadores = {};


  @override
  void initState() {
    super.initState();
    _equipamentos = widget.equipamento;
//    _recuperaUltimaLocalizacaoConhecida();


  }
  double zoomVal= 6.5;
  @override
  Widget build(BuildContext context) {
    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando mapa"),
          CircularProgressIndicator()
        ],
      ),
    );
    var mensagemNaotemDados = Center(
      child: Text("Não tem dados de mapa",
      style:  TextStyle(
      fontSize: 18,
        fontWeight: FontWeight.bold
              ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              //
            }),
        title: Text("MATO GROSSO"),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                //
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _zoomminusfunction(),
          _zoomplusfunction(),
          _buildContainer(),
        ],
      ),

    );
  }

  Widget _zoomminusfunction() {

    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus,color:Color(0xff6200ee)),
          onPressed: () {
            zoomVal--;
            _minus( zoomVal);
          }),
    );
  }
  Widget _zoomplusfunction() {

    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus,color:Color(0xff6200ee)),
          onPressed: () {
            zoomVal++;
            _plus(zoomVal);
          }),
    );
  }
//-15.558454, -56.047813 cuiaba
   // -11.856218,-55.503106 sinop
  //-10.657142, -51.570338 confresa
  // -10.473297, -50.505114 santa terezinha
  //-16.074127, -57.698630 caceeres
  // -11.419656, -58.782702 juina
  // -15.877246, -52.230282 barra do garcas


  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(-15.558454, -56.047813), zoom: zoomVal)));
  }
  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(-15.558454, -56.047813), zoom: zoomVal)));
  }


  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://firebasestorage.googleapis.com/v0/b/agricultura-2891b.appspot.com/o/meus_equipamentos%2FX1AF4zwpiZlm5K0c3hZN%2F1598361026905?alt=media&token=a033c609-47c4-4623-ab6f-c4ef842058af",
                  -15.877246, -52.230282,"Barra do Garça"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
                  -11.419656, -58.782702,"Juína"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                  -16.074127, -57.698630,"Cáceres"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat,double long,String nomecidade) {
    return  GestureDetector(
      onTap: () {
        _gotoLocation(lat,long);
      },
      child:Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(nomecidade),
                    ),
                  ),

                ],)
          ),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String localidade) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(localidade,
                style: TextStyle(
                    color: Color(0xff6200ee),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              )),
        ),
        SizedBox(height:5.0),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    child: Text(
                      "150",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18.0,
                      ),
                    )),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStarHalf,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                    child: Text(
                      "(familias:)",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18.0,
                      ),
                    )),
              ],
            )),
        SizedBox(height:5.0),
        Container(
            child: Text(
             "investimento: \u00B7 \u0024\u0024 \u00B7 1.6 mi",
                style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
        SizedBox(height:5.0),
        Container(
            child: Text(
                "Equipamentos \u00B7 Trator",

              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            )),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:  CameraPosition(target: LatLng(-15.557404, -56.037753), zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Markergeral,cuiabaMarker,confresaMarker,sinopMarker,barradogarcaMarker,juinaMarker,caceresMarker
        },
      ),
    );
  }

  Future<void> _gotoLocation(double lat,double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 15,tilt: 50.0,
      bearing: 45.0,)));
  }
//
// // recuperar o listeners querysnapshot
//
//   Stream<QuerySnapshot>_adicionarListenerLocalizacao(){
//     final stream = db.collection("equipamentos")
//     //  .where("latlong" , isNull:  )
//     .snapshots();
//      stream.listen((dados) {
//        _controller1.add(dados);
//      });
//   }
//
//
//   _recuperaUltimaLocalizacaoConhecida() async{
//     Position position = await Geolocator()
//         .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       if (position != null) {
//         _exibirMarcadorUsuario(position);
//         _posicaoCamera = CameraPosition(
//             target: LatLng(position.latitude, position.longitude),
//             zoom: 19
//         );
//
//         _movimentarCamera(_posicaoCamera);
//
//       }
//     });
//   }
//
//   _movimentarCamera(CameraPosition cameraPosition) async {
//     GoogleMapController googleMapController = await _controller.future;
//     googleMapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//             cameraPosition
//         )
//     );
//
//   }
//   _exibirMarcadorUsuario(Position Local) async{
//     double pixelRatio = MediaQuery.of(context).devicePixelRatio;
//     BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: pixelRatio),
//         "imagens/passageiro.png"
//     ).then((BitmapDescriptor icone){
//       Marker marcadorUsuario = Marker(
//           markerId: MarkerId("marcador-usuario"),
//           position: LatLng(Local.latitude, Local.longitude),
//           infoWindow: InfoWindow(
//               title: "local atual"
//           ),
//           icon:icone
//       );
//
//       setState(() {
//         _marcadores.add(marcadorUsuario);
//       });
//     });
//   }





  
}

Marker barradogarcaMarker = Marker(
  markerId: MarkerId('barradogarca'),
  position: LatLng(-15.877246, -52.230282),
  infoWindow: InfoWindow(title: 'Barra do Garça'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

Marker juinaMarker = Marker(
  markerId: MarkerId('juina'),
  position: LatLng(-11.419656, -58.782702),
  infoWindow: InfoWindow(title: 'juina'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker caceresMarker = Marker(
  markerId: MarkerId('caceres'),
  position: LatLng(-16.074127, -57.698630),
  infoWindow: InfoWindow(title: 'Cáceres'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

//New York Marker
// mato grosso marker
// -15.558454, -56.047813 cuiaba

// 40.742451, -74.005959 newyork


Marker Markergeral = Marker(
  markerId: MarkerId('cuiabateste'),
  position: LatLng(-15.548125, -56.088500),
  infoWindow: InfoWindow(title: 'Cuiabateste'),

  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);





Marker cuiabaMarker = Marker(
  markerId: MarkerId('cuiaba'),
  position: LatLng(-15.548125, -56.080960),
  infoWindow: InfoWindow(title: 'Cuiaba'),

  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker confresaMarker = Marker(
  markerId: MarkerId('confresa'),
  position: LatLng(-10.657142, -51.570338),
  infoWindow: InfoWindow(title: 'Confresa: '
      ' familias: 10 '
      ' equipamento: 1 trator'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);
Marker sinopMarker = Marker(
  markerId: MarkerId('Sinop'),
  position: LatLng(-11.856218, -55.503106),
  infoWindow: InfoWindow(title: 'Sinop: ' 'familias: 50 '
      ' equipamento: 1 trator, 2 resfriador de leite'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueViolet,
  ),
);

// //29/10 flutter - usando firebase : cloud firestore
// _recuperarPosicaoMarker() async {
//   // recuperar todos marcadores pelo idequipamento
//   var db = Firestore.instance;
//   QuerySnapshot resultado =
//   await db.collection("equipamentos").getDocuments();
//   resultado.documents.forEach((d) {
//     print(d.documentID);
//     print(d.data);
//   });
//   _recuperarMarkerEsp() async {
//     // recuperar  marcador espesifico pelo idequipamento
//     var db = Firestore.instance;
//     DocumentSnapshot resultado =
//     await db.collection("equipamentos")
//         .document("equipamentos").get();
//
//     print(resultado.documentID);
//     print(resultado.data);
//
//     // _dadosLocal = documentSnapshot.data;
//     // _adicionarListenerLocal();
//
//   }
//
//   _AtualizandoDoc() async {
//     var db = Firestore.instance;
//     QuerySnapshot resultado =
//     await db.collection("equipamentos").getDocuments();
//     resultado.documents.forEach((d) {
//       d.reference.updateData(
//           {
//             "latitude": -10.657142
//           }
//       );
//     });
//   }
//   _deletarMarkerEsp() async {
//     // deletar marcadores
//     var db = Firestore.instance;
//
//     await db.collection("equipamentos")
//         .document("equipamentos").delete();
//   }
//
//   Stream<QuerySnapshot> _adicionarListernerLocalizacao() {
//     final stream = db.collection("equipamentos")
//     //   .where("latitude ", isEqualTo: )
//         .snapshots();
//
//     stream.listen((dados) {
//       // _controller.add(dados);
//     });
//   }
//   //recebe notificação alteraçoes feitas no firebase
//     _notificarMudanca() async {
//     var db = Firestore.instance;
//     db.collection("equipamentos")
//         .snapshots().listen((dados) {
//       dados.documents.forEach((d) {
//         print(d.data);
//       });
//     });
//   }
//}
