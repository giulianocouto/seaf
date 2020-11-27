import 'dart:async';

import 'package:agriculturafamiliar/Screens/HomeScreen.dart';
import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/util/Configuracoes.dart';
import 'package:agriculturafamiliar/util/CustomSearchDelegate.dart';
import 'package:agriculturafamiliar/views/MeusEquipamentos.dart';
import 'package:agriculturafamiliar/views/widgets/CustomDrawer.dart';
import 'package:agriculturafamiliar/views/widgets/ItemEquipamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Cadastros extends StatefulWidget {
  @override
  _CadastrosState createState() => _CadastrosState();
}

class _CadastrosState extends State<Cadastros> {
  // criar lista de itens

  String _resultado = "";

  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _listaItensDropCidades;
  List<DropdownMenuItem<String>> _listaItensDropCategorias;
  final _controler = StreamController<QuerySnapshot>.broadcast();
 // final _pageController = PageController();

  String _itemSelecionadoCidade;
  String _itemSelecionadoCategoria;
  String _buscarRP;

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Meus Equipamentos":
        Navigator.pushNamed(context, "/meus-equipamentos");
        break;
      case "Entrar / Cadastar":
        Navigator.pushNamed(context, "/Login");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, "/Login");
  }

  //verificar usuario logado e constoi o menu
  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //para recuperar o usuario logado
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      itensMenu = ["Entrar / Cadastar"];
    } else {
      itensMenu = ["Meus Equipamentos", "Deslogar"];
    }
  }

  _carregarItensDropdown() {
    _listaItensDropCategorias = Configuracoes.getCategorias();

    _listaItensDropCidades = Configuracoes.getCidades();
  }

  Future<Stream<QuerySnapshot>> _filtrarEquipamentos() async {
    Firestore db = Firestore.instance;
    // Stream<QuerySnapshot> stream = db
    //     .collection("equipamentos")
    //     .snapshots();
    Query query = db.collection("equipamentos");

    if (_itemSelecionadoCidade != null) {
      query = query.where("cidade", isEqualTo: _itemSelecionadoCidade);
    }

    if (_itemSelecionadoCategoria != null) {
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }
// criado filtro para busca por rp
    if (_buscarRP != null) {
      query = query.where("rpequip", isEqualTo: _buscarRP);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerEquipamentos() async {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("equipamentos").snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _verificarUsuarioLogado();
    _adicionarListenerEquipamentos();
//    _filtrarEquipamentos();
  }

  Icon cusIcon = Icon(Icons.search);

  Widget cusSearchBar = Text("SEAF");
  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando equipamentos"),
          CircularProgressIndicator()
        ],
      ),
    );



    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
      // aqui inserir o widget Drawer
      //   leading: IconButton(
      //     icon: Icon(Icons.menu
      //     ),
      //     onPressed: (){},
      //   ),
       // title: Text("SEAF"),
         elevation: 10.0,
        actions: <Widget>[

          IconButton(
              icon: Icon(Icons.search),
              onPressed: ()async  {
      String res = await showSearch(context: context,delegate: CustomSearchDelegate());
           setState(() {
              _resultado = res;
              });
      print("resultado digitado" + res);
              }
              ),
    // IconButton(
          //   onPressed: () {
          //      setState(() {
          //       if (this.cusIcon.icon == Icons.search) {
          //         this.cusIcon = Icon(Icons.cancel);
          //         this.cusSearchBar = TextField(
          //           textInputAction: TextInputAction.search,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //             hintText: "Buscar por RP",
          //             // fazaer a ligação par mostrar RP no app search
          //
          //           ),
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 20.0,
          //           ),
          //           // onChanged: (query) {
          //           //   _buscarRP=(query);
          //           //   _filtrarEquipamentos();
          //           // },
          //
          //
          //         );
          //     //    _buscarRP = ;
          //  //       _filtrarEquipamentos();
          //
          //       } else {
          //         this.cusIcon = Icon(Icons.search);
          //         this.cusSearchBar = Text("SEAF");
          //       }
          //     });
          //   },
          //   icon: cusIcon,
          // ),
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
              //converteu map para lista
            },
          )
        ],
        title: cusSearchBar,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            // exibir area de filtros
            Row(
              children: <Widget>[
                //colocar expanded par pegar tamanho maximo na linha
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      iconEnabledColor: Color(0xff000199),
                      value: _itemSelecionadoCidade,
                      items: _listaItensDropCidades,
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black),
                      onChanged: (cidade) {
                        setState(() {
                          //para mostrar o setState
                          _itemSelecionadoCidade = cidade;
                          _filtrarEquipamentos();
                        });
                      },
                    ),
                  ),
                ),

                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 50, //60
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: SingleChildScrollView(
                      child: DropdownButton(
                        iconEnabledColor: Color(0xff000199),
                        value: _itemSelecionadoCategoria,
                        items: _listaItensDropCategorias,
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black),
                        onChanged: (categoria) {
                          //para mostrar o setState

                          setState(() {
                            _itemSelecionadoCategoria = categoria;
                            _filtrarEquipamentos();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // exibir area de listagem de equipamentos
            StreamBuilder(
                //criar um streamcontroller
                stream: _controler.stream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return carregandoDados;
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      //criar um listview para mostrar equipamentos depois de recuperar dados do firebase
                      QuerySnapshot querySnapshot = snapshot.data;
                      if (querySnapshot.documents.length == 0) {
                        return Container(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            "Nenhum Equipamento!! ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                            itemCount: querySnapshot.documents.length,
                            itemBuilder: (_, indice) {
                              List<DocumentSnapshot> equipamentos =
                                  querySnapshot.documents.toList();
                              DocumentSnapshot documentSnapshot =
                                  equipamentos[indice];
                              Equipamentos equipamento =
                                  Equipamentos.fromDocumentSnapshot(
                                      documentSnapshot);

                              return ItemEquipamento(
                                equipamento: equipamento,
                                onTapItem: () {
                                  Navigator.pushNamed(
                                      context, "/detalhes-equipamento",
                                      arguments: equipamento);
                                },
                              );
                            }),
                      );
                  }
                  return Container();
                }),
          ],
        ),
      ),
    );

  }
}
