import 'package:agriculturafamiliar/models/Usuario.dart';
import 'package:agriculturafamiliar/views/widgets/BotaoCustomizado.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file:///C:/Users/giulianocouto.AGRICULTURAF/AndroidStudioProjects/agriculturafamiliar/lib/views/widgets/InputCustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController(
      text: "giuliano.couto@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(
      text: "123456789");
  bool _carregando = false;
  bool _cadastrar = false;
  String _mensagemErro = "";
  String _textoBotao = "Entrar";

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _validarCampos() {
    //recuperar os dados dos campos usando o controlador
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        //configurar usuer
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        //cadastrar ou logar
        if (_cadastrar) {
          //cadsatrar
          _cadastraUsuario(usuario);

        } else {
          //logar
          _logarUsuario(usuario);
        }
      } else {
        setState(() {
         _mensagemErro = "Preencha a senha ! digite mais de 6 caracteres";
        _scaffoldKey.currentState.showSnackBar(
         SnackBar(content: Text("Verificar Senha"),
         backgroundColor: Colors.redAccent,
           duration: Duration(seconds: 2),
          )
        );
        });
      }
    }else{
      setState(() {
        _mensagemErro = "Preencha o Email válido";

        _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("verificar Email"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
        )
        );
      });
    }
  }
// autenticaçã email e senha
  _cadastraUsuario(Usuario usuario) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth.createUserWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha
    ).then((firebaseUser) {

      //salvar usuarios firebase
      db.collection("usuarios")
      .document(firebaseUser.user.uid)
      .setData(usuario.toMap());//salvar no firebase como map

//redirecinar para tela principal

      Navigator.pushReplacementNamed(context, "/");
      // SnackBar(content: Text("Cadastrado com Sucesso" + firebaseUser.user.email),
      //   backgroundColor: Colors.redAccent,
      //   duration: Duration(seconds: 2),
      // );

    }).catchError((erro){
    //  print("novo usuario: erro" +erro.toString());
      _mensagemErro = "Erro ao cadastrar usuario verificar email e senha";
    });
  }

  _logarUsuario(Usuario usuario) async{

    setState(() {
      _carregando = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    ).then((firebaseUser){
      //redirecinar para tela principal
   Navigator.pushReplacementNamed(context, "/");
    SnackBar(content: Text("Logado com Sucesso"),
     backgroundColor: Colors.redAccent,
     duration: Duration(seconds: 2),
   );

    }).catchError((erro){
      //  print("novo usuario: erro" +erro.toString());
      _mensagemErro = "Erro ao Logar usuario verificar email e senha";
    });
  }
//    void usuarioAtual() async{
//     FirebaseAuth auth = FirebaseAuth.instance;
//
//    FirebaseUser usuariologado = await auth.currentUser();
//
//    if (usuariologado != null){
//
//    }else {
//      //deslogado
//    }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        color: Color(0xff000080),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "E-mail",
                  autofocus: true,
                  type: TextInputType.emailAddress,
                ),
                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "Senha",
                  maxLines: 1,
                  obscure: true,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Logar"),
                    Switch (
                        value: _cadastrar,
                        onChanged: (bool valor) {
                          setState(() {
                            _cadastrar = valor;
                            _textoBotao = "Entrar";

                            if (_cadastrar){
                              _textoBotao = "Cadastrar";
                            }
                          });
                        }),
                    Text("Cadastrar"
                    ),
                  ],
                ),
                BotaoCustomizado(
                  texto: _textoBotao,
                  onPressed: (){
                    _validarCampos();
                  },
                ),
                FlatButton(
                    child: Text("Ir para Equipamentos SEAF"),
                onPressed:() {
                  Navigator.pushReplacementNamed(context, "/");
                }
                ),
               _carregando ? Center( child: CircularProgressIndicator(
                 backgroundColor: Colors.blueAccent,),
                         ): Container(),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro, style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red

                  ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
