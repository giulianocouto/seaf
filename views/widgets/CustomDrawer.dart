import 'dart:async';
import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/views/Cadastros.dart';
import 'package:agriculturafamiliar/views/Login.dart';
import 'package:agriculturafamiliar/views/MeusEquipamentos.dart';
import 'package:agriculturafamiliar/views/NovoCadastro.dart';
import 'package:agriculturafamiliar/views/SplashScreen.dart';
import 'package:agriculturafamiliar/views/mapa.dart';
import 'package:agriculturafamiliar/views/widgets/ChamaMapa.dart';
import 'package:agriculturafamiliar/views/widgets/MapaMT.dart';
import 'package:agriculturafamiliar/views/widgets/MapaMTonline.dart';
import 'package:agriculturafamiliar/views/widgets/MapaMarcadores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'MapaMTonlineEquipamentos.dart';
class CustomDrawer extends StatefulWidget {


//  CustomDrawer(this.pageController);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  String _idUsuarioLogado;
// String _nomeUsuarioLogado;
  String _emailUsuarioLogado;


  TextEditingController _controllerEmail = TextEditingController();
  // TextEditingController _controllerSenha = TextEditingController(
  //     text: );



  // _recuperaDadosUsuarioLogado() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   FirebaseUser usuarioLogado = await auth.currentUser();
  //   _idUsuarioLogado = usuarioLogado.uid;
  //   // _nomeUsuarioLogado = usuarioLogado.displayName;
  //     _emailUsuarioLogado = usuarioLogado.email;
  //
  // }
  _verificarUsuarioLogado() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null){
   //   String idUsuario = usuarioLogado.uid;
      setState(() {
        String email = usuarioLogado.email;
        _controllerEmail.text = (email);
      });

    }
  }
        //entra automatico usuario
  @override
  void initState(){
    super.initState();
   _verificarUsuarioLogado();
  }


  @override
  Widget build(BuildContext context) {
    Widget _buildDrawerBack() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromARGB(0xff000245, 0xff000140, 0xff000198, 0xff000197),
              Colors.white54
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        );




    // _redirecionaUsuarioemail(String idUsuario) async{
    //   Firestore db = Firestore.instance;
    //   DocumentSnapshot snapshot = await db.collection("usuarios")
    //   .document(idUsuario)
    //   .get();
    //   //dados sao retornados como map
    //   Map<String, dynamic> dados = snapshot.data;
    //   String email = dados["email"];
    //    }

    Future<Stream<QuerySnapshot>> _adicionarListenerCadastros() async{
      // primeiro recuperar usuario logado depois os equipamentos

  //    await _recuperaDadosUsuarioLogado();
      await _verificarUsuarioLogado();
      Firestore db = Firestore.instance;
      Stream<QuerySnapshot> stream = db
          .collection("meus_equipamentos")
         .document(_idUsuarioLogado)
      //   .collection("meus_equipamentos")
      //   .document(_nomeUsuarioLogado)
         .collection("meus_equipamentos")
        .document(_emailUsuarioLogado)
          .collection("equipamentos")
          .snapshots();
//recuperar os dados passados na stream
      stream.listen((dados) {
        _controller.add(dados);
      });
    }

    return Drawer(
      child: Stack(
        children: <Widget>[
          _buildDrawerBack(),
          //criar listview inserir todos os campos do menudrawer
          ListView(

            padding: EdgeInsets.only(left: 32.0, top: 16.0),
            children: <Widget>[

              Container(

                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 170.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 8.0,
                      left: 0.0,
                      child: Text(
                        "SEAF\nMenu",
                        style: TextStyle(
                            fontSize: 34.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Text(
                            _controllerEmail.text,
                              style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            child: Text(
                              "Entre ou Cadastar",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Login()));
                            },
                          ),
                        ],
                      ),

                    ),
                  ],
                ),
              ),
              Divider(),
              // pagina inicial equipamentos

              Material(
                color: Colors.transparent,
                child: InkResponse(
                  containedInkWell: false,
                  highlightColor: Colors.indigoAccent.withOpacity(0.5),
                  splashColor: Colors.indigo,
                  radius: 95.0,
                  //borderRadius: BorderRadius.circular(45.0),
                  onTap: () {
                    Navigator.of(context).pop();
                    // controller.jumpToPage(page);

                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Cadastros()));
                  },
                  child: Container(
                    height: 95.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          size: 60.0,
                          color: Colors.indigoAccent,
                          //  color: controller.page.round() == page ?
                          //   Theme.of(context).primaryColor : Colors.grey[700],
                        ),
                    // Icon(Icons.account_circle,
                    //   size: 65.0, color: Colors.indigoAccent,



                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Início",
                          style: TextStyle(
                            fontSize: 16.0,
                            //       color: controller.page.round() == page ?
                            //    Theme.of(context).primaryColor : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

               // pagina meus equipamentos

              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    // controller.jumpToPage(page);

                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MeusEquipamentos()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.directions_car,
                          size: 32.0,
                             ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Meus Equipamentos",
                          style: TextStyle(
                            fontSize: 16.0,
                             ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // pagina localizar Satelite

              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => mapa()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Buscar \n Endereços Destino",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MapaMT()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "localizar\nEquipamentos Offline",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Material(
              //   color: Colors.transparent,
              //   child: InkResponse(
              //     onTap: () {
              //       Navigator.of(context).pop();
              //       Navigator.of(context).push(
              //           MaterialPageRoute(builder: (context) =>MapaMTonline()));
              //     },
              //     child: Container(
              //       height: 60.0,
              //       child: Row(
              //         children: <Widget>[
              //           Icon(
              //             Icons.location_on,
              //             size: 32.0,
              //           ),
              //           SizedBox(
              //             width: 32.0,
              //           ),
              //           Text(
              //             "Marcadores descrição",
              //             style: TextStyle(
              //               fontSize: 16.0,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) =>SplashScreen()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Viagens Checklist",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) =>MapaMarcadores()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Mapa marcadores",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // pagina cadeias produtivas

              Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => NovoCadastro()));
                  },
                  child: Container(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.streetview,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 32.0,
                        ),
                        Text(
                          "Cadeias Produtivas",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
