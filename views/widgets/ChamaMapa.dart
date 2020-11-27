import 'dart:async';
import 'package:agriculturafamiliar/views/widgets/MapaMTonlineEquipamentos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//viagens cheklist equipamentos

class ChamaMapa extends StatefulWidget {
  @override
  _ChamaMapaState createState() => _ChamaMapaState();
}

class _ChamaMapaState extends State<ChamaMapa> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;

  _abrirMapa(String idViagem){

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MapaMTonlineEquipamentos( idViagem: idViagem, )
        )
    );
  }
  _excluirViagem(String idViagem){

    _db.collection("viagens")
        .document( idViagem )
        .delete();
  }
  _adicionarLocal(){

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MapaMTonlineEquipamentos()
        )
    );

  }

  _adicionarListenerViagens() async {
//recupera todas viagens salvas no bd
    final stream = _db.collection("viagens")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  @override
  void initState() {
    super.initState();

    _adicionarListenerViagens();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checlist Viagens "),),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xff0066cc),
          onPressed: (){
            _adicionarLocal();
          }
      ),
      body: StreamBuilder<QuerySnapshot> (
          stream: _controller.stream,
          // ignore: missing_return
          builder: (context, snapshot)  {
            switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:
              if(snapshot.data == null) return CircularProgressIndicator();
                QuerySnapshot querySnapshot = snapshot.data;
                List<DocumentSnapshot> viagens = querySnapshot.documents.toList();
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: viagens.length,
                          itemBuilder: (context, index){

                            DocumentSnapshot item = viagens[index];
                            String cidade = item["cidade"];
                            String idViagem = item.documentID;

                            return GestureDetector(
                              onTap: (){
                                _abrirMapa(idViagem);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(cidade),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: (){
                                          _excluirViagem(idViagem);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ),
                              ),
                            );

                          }
                      ),
                    )
                  ],
                );

                break;
            }
          }
      ),
    );
  }
}


