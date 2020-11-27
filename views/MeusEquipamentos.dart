import 'dart:async';
//import 'dart:html';

import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/views/NovoCadastro.dart';
import 'package:agriculturafamiliar/views/widgets/ItemEquipamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class MeusEquipamentos extends StatefulWidget {
  @override
  _MeusEquipamentosState createState() => _MeusEquipamentosState();
}

class _MeusEquipamentosState extends State<MeusEquipamentos> {

 final _controller = StreamController<QuerySnapshot>.broadcast();
 String _idUsuarioLogado;
// String _nomeUsuarioLogado;
//  String _emailUsuarioLogado;

 _recuperaDadosUsuarioLogado() async {
   FirebaseAuth auth = FirebaseAuth.instance;
   FirebaseUser usuarioLogado = await auth.currentUser();
   _idUsuarioLogado = usuarioLogado.uid;
  // _nomeUsuarioLogado = usuarioLogado.displayName;
  //  _emailUsuarioLogado = usuarioLogado.email;


 }
 Future<Stream<QuerySnapshot>> _adicionarListenerCadastros() async{
   // primeiro recuperar usuario logado depois os equipamentos

   await _recuperaDadosUsuarioLogado();

   Firestore db = Firestore.instance;
   Stream<QuerySnapshot> stream = db
       .collection("meus_equipamentos")
       .document(_idUsuarioLogado)
    //   .collection("meus_equipamentos")
    //   .document(_nomeUsuarioLogado)
    //    .collection("meus_equipamentos")
    //    .document(_emailUsuarioLogado)
       .collection("equipamentos")
   .snapshots();
//recuperar os dados passados na stream
   stream.listen((dados) {
     _controller.add(dados);
   });
 }
 _removerEquipamentos(String idEquipamentos){
   //certificar esta igual o firestore
   Firestore db = Firestore.instance;
   db.collection("meus_equipamentos")
   .document(_idUsuarioLogado)
   .collection("equipamentos")
   .document(idEquipamentos)
   .delete().then  ((_){
     db.collection("equipamentos")
         .document(idEquipamentos)
         .delete();
   });
 }
 // criando metodo para editar o equipamento

 // void _editarEquipamento(BuildContext context, Equipamentos equipamentos)async{
 //   await Navigator.push(context,
 //   MaterialPageRoute(builder: (context)=> NovoCadastro(equipamentos)),
 //   );
 //
 //  }

@override
  void initState() {
       super.initState();
    _adicionarListenerCadastros();
  }


  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(children: <Widget>[
        Text("Carregando Equipamentos"),
        CircularProgressIndicator(),
      ],),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Equipamentos") ,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
       icon: Icon(Icons.add),
        label: Text("adicionar"),
      //  child:Icon(Icons.add),
        onPressed: (){
         Navigator.pushNamed(context, "/novo equipamento");
        },
      ),
      // mostrar tela de meus equipamentos igual retornar para tela principal
      body: StreamBuilder(
       stream: _controller.stream,
        builder: (contex, snapshot) {
         switch (snapshot.connectionState){
           case ConnectionState.none:
           case ConnectionState.waiting:
             return carregandoDados;
             break;
           case ConnectionState.active:
           case ConnectionState.done:
             //tratar erros ao carregar primeiro
             if(snapshot.hasError)
               return Text("Erro ao carregar os dados!");
       QuerySnapshot querySnapshot = snapshot.data;
             return ListView.builder(
                 itemCount: querySnapshot.documents.length,
                 itemBuilder: (_,indice){
                   List<DocumentSnapshot> equipamentos = querySnapshot.documents.toList();
                   DocumentSnapshot documentSnapshot = equipamentos[indice];
                   //instaciar equipamento
                   Equipamentos equipamento = Equipamentos.fromDocumentSnapshot(documentSnapshot);
                   return ItemEquipamento(
                     equipamento : equipamento,
                     onPressedRemover: (){
                       showDialog(
                           context: context,
                         builder: (context){
                         return AlertDialog(
                           title: Text("Confirmar"),
                           content: Text("Deseja realmente excluir o equipamento??"),
                           actions: <Widget>[
                             FlatButton(
                               child: Text("Cancelar",
                               style: TextStyle(
                                 color: Colors.grey
                               ),
                               ),
                               onPressed: (){
                                 Navigator.of(context).pop();
                               },
                             ),
                             FlatButton(
                               color: Colors.red,
                               child: Text("Remover",
                                 style: TextStyle(
                                     color: Colors.white
                                 ),
                               ),
                               onPressed: (){
                                 _removerEquipamentos(equipamento.id);
                                 Navigator.of(context).pop();
                               },
                             ),
                           ],
                         )   ;
                         }
                       );
                     },
                       );
                 }
             );
         }
          return Container();
        },
      ),
    ) ;
  }
}

