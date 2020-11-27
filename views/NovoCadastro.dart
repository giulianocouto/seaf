import 'dart:io';
import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/models/cidades.dart';
import 'package:agriculturafamiliar/util/Configuracoes.dart';
import 'package:agriculturafamiliar/views/widgets/BotaoCustomizado.dart';
import 'package:agriculturafamiliar/views/widgets/InputCustomizado.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validadores/Validador.dart';

class NovoCadastro extends StatefulWidget {
  @override
  _NovoCadastroState createState() => _NovoCadastroState();
}

class _NovoCadastroState extends State<NovoCadastro> {
  List<File> _listaImagens = List();
  List<DropdownMenuItem<String>> _listaItensDropCidades = List();
  List<DropdownMenuItem<String>> _listaItensDropCategorias = List();
  final _formKey = GlobalKey<FormState>();

  // final _picker = ImagePicker();
  BuildContext _dialogContext;
  bool _vigente = false;
  bool _aditivo = false;
  bool _vistoria = false;
  bool _rp = false;
  bool _Adesivo = false;
  bool _serie = false;
  bool _AdesivoConv = false;
  bool _incra = false;
  bool _pncf = false;
  bool _intermat = false;
  bool _pct = false;
  bool _af = false;
  bool _acampamento = false;
  bool _terceiros = false;
  bool _cessionario = false;
  bool _comodato = false;
  bool _termoCessao = false;
  bool _termoResp = false;
  bool _permissaoUso = false;
  bool _diaria = false;
  bool _combustivel = false;
  bool _lei = false;
  bool _social = false;
  bool _motorista = false;
  bool _manutencao = false;
  bool _documento = false;
  bool _bem = false;
  bool _guarda = false;


  Equipamentos _equipamentos;

//  String _textoBotao = "sim";
  String _itemSelecionadoCidade;
  String _itemSelecionadoCategoria;

  _selecionarImagemGaleria() async {
// imagepicker.picker deprecated usar getimage

    File imagemSelecionada =
    await ImagePicker.pickImage(source: ImageSource.gallery);
    // final bytes = await imagemSelecionada.readAsBytes();
    if (imagemSelecionada != null) {
      setState(() {
        //  final pickedFile = await _picker.getImage(source:ImageSource.gallery);
        //  final _listaImagens = File(imagemSelecionada.path);
        _listaImagens.add(imagemSelecionada);
      });
    }
  }

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        //para nao deixar usuario fechar a tela
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Salvando Cadastro Equipamentos")
              ],),
          );
        }
    );
  }

  _salvarEquipamentos() async {
    _abrirDialog(_dialogContext);
    // fazer upload das imagens
    //upload imagens no storage
    await _uploadImagens();
    //pegar usuario logado
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    String idUsuarioLogado = usuarioLogado.uid;

    //  print("lista imagens:${_equipamentos.fotos.toString()}");
    //salvar equipamentos no firestore
    Firestore db = Firestore.instance;
    db.collection("meus_equipamentos")
        .document(idUsuarioLogado)
        .collection("equipamentos")
        .document(_equipamentos.id)
        .setData(_equipamentos.toMap()).then((_) {
      // salvar cadastros de equipamentos gerais para buscar por cidade e categorias

      db.collection("equipamentos")
          .document(_equipamentos.id)
          .setData(_equipamentos.toMap()).then((_) {
        Navigator.pop(_dialogContext);
        //nao quero usuario voltar para essa tela de salvar
        //    Navigator.pushReplacementNamed(context, "/meus-equipamentos");
        Navigator.pop(context);
      });
    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      StorageReference arquivo = pastaRaiz
          .child("meus_equipamentos")
          .child(_equipamentos.id)
          .child(nomeImagem);
      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _equipamentos.fotos.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _equipamentos = Equipamentos.gerarId();
  }

  _carregarItensDropdown() {
   _listaItensDropCategorias = Configuracoes.getCategorias();

   _listaItensDropCidades = Configuracoes.getCidades();

 }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Novo Equipamento"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Form(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // comecar adcionar area de imagens depois outros campos
                      FormField<List>(
                        initialValue: _listaImagens,
                        validator: (imagens) {
                          if (imagens.length == 0) {
                            return "Necessario selecionar uma imagem";
                          }
                          return null;
                        },
                        // aqui cria os form
                        builder: (state) {
                          return Column(
                            children: <Widget>[
                              Container(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _listaImagens.length +
                                        1, //esquema aprecer imagem para add
                                    itemBuilder: (context, indice) {
                                      //0
                                      //1
                                      if (indice == _listaImagens.length) {
                                        return Padding(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              _selecionarImagemGaleria();
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[400],
                                              radius: 50,
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.grey[100],
                                                  ),
                                                  Text(
                                                    "Inserir",
                                                    style: TextStyle(
                                                      color: Colors.grey[100],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (_listaImagens.length > 0) {
                                        return Padding(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    Dialog(
                                                      // wrap colom com singlechildscrollview para nao dar problema renderizar imagem pixel
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          children: <Widget>[
                                                            Image.file(
                                                                _listaImagens[indice]),
                                                            FlatButton(
                                                              child: Text(
                                                                  "Excluir"),
                                                              textColor: Colors
                                                                  .red,
                                                              onPressed: () {
                                                                setState(() {
                                                                  _listaImagens
                                                                      .removeAt(
                                                                      indice);
                                                                  Navigator.of(
                                                                      context)
                                                                      .pop();
                                                                });
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                              FileImage(_listaImagens[indice]),
                                              child: Container(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.4),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    }),
                              ),
                              if (state.hasError)
                                Container(
                                  child: Text(
                                    "[${state.errorText}]",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      // menu dropdown
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:EdgeInsets.fromLTRB(0,0, 0, 0),
                              child: SingleChildScrollView(
                                child: DropdownButtonFormField(
                                    value: _itemSelecionadoCidade,
                                    hint: Text("Cidades"),
                                    onSaved: (cidade) {
                                      _equipamentos.cidade = cidade;
                                    },
                                    style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                    //  fontWeight: FontWeight.bold,
                                     
                                      color: Colors.black,
                                      fontSize: 9.5,
                                    ),
                                    items: _listaItensDropCidades,
                                    validator: (valor) {
                                      return Validador()
                                          .add(Validar.OBRIGATORIO,
                                          msg: "Campo obrigatório")
                                          .valido(valor);
                                    },
                                    onChanged: (valor) {
                                      setState(() {
                                        _itemSelecionadoCidade = valor;
                                      });
                                    }),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(2,2,2, 2),
                              child: SingleChildScrollView(
                                child: DropdownButtonFormField(
                                    value: _itemSelecionadoCategoria,
                                    hint: Text("Categorias"),
                                    onSaved: (categoria) {
                                      _equipamentos.categoria = categoria;
                                    },
                                    style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                    items: _listaItensDropCategorias,
                                    validator: (valor) {
                                      return Validador()
                                          .add(Validar.OBRIGATORIO,
                                          msg: "Campo obrigatório")
                                          .valido(valor);
                                    },
                                    onChanged: (valor) {
                                      setState(() {
                                        _itemSelecionadoCategoria = valor;
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //caixa de textos e botoes

                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "Equipamentos",
                          onSaved: (equipamentos) {
                            _equipamentos.equipamentos = equipamentos;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),


                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 20,),
                              Text(
                                "Termo vigente?",

                              ),

                              Switch(
                                  value: _vigente,

                                 onChanged: (bool valor ) {
                                  setState(() {

                                    _vigente = valor;

                                    _equipamentos.textoBotaovigente = "não";

                                    if (_vigente) {
                                     _equipamentos.textoBotaovigente = "sim";
                                     _vigente = valor;
                                    };
                                  });
                                },
                              ),
                              Text(""),
                              Text(
                                "Possui Aditivo?",
                              ),

                              Switch(
                                  value: _aditivo,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _aditivo = valor;
                                      _equipamentos.textoBotaoaditivo = "não";


                                      if (_aditivo) {
                                        _equipamentos.textoBotaoaditivo = "sim";
                                        _aditivo = valor;
                                      }
                                    });
                                  }),
                              Text(""),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Numero Termo de Cessão",
                          onSaved: (NumTermoCessao) {
                            _equipamentos.NumTermoCessao = NumTermoCessao;
                          },
                          type: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            RealInputFormatter(),
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(bottom: 6),
                      //   child: InputCustomizado(
                      //     hint: "latitude",
                      //     onSaved: (latitude) {
                      //       _equipamentos.latitude = latitude;
                      //     },
                      //     type: TextInputType.text,
                      //     inputFormatters: [
                      //       WhitelistingTextInputFormatter.digitsOnly,
                      //       RealInputFormatter(),
                      //
                      //     ],
                      //     validator: (valor) {
                      //       return Validador()
                      //           .add(
                      //           Validar.OBRIGATORIO, msg: "Campo obrigatório")
                      //           .valido(valor);
                      //     },
                      //     controller: null,
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "latitude",
                          onSaved: (latitude) {
                            _equipamentos.latitude = latitude;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "longitude",
                          onSaved: (longitude) {
                            _equipamentos.longitude = longitude;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "latlong",
                          onSaved: (latlong) {
                    //        _equipamentos.latlong = latlong;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),

                      // Padding(
                      //   padding: EdgeInsets.only(bottom: 6),
                      //   child: InputCustomizado(
                      //     hint: "longitude",
                      //     onSaved: (longitude) {
                      //       _equipamentos.longitude = longitude;
                      //     },
                      //     type: TextInputType.number,
                      //     inputFormatters: [
                      //       WhitelistingTextInputFormatter.digitsOnly,
                      //       RealInputFormatter(),
                      //     ],
                      //     validator: (valor) {
                      //       return Validador()
                      //           .add(
                      //           Validar.OBRIGATORIO, msg: "Campo obrigatório")
                      //           .valido(valor);
                      //     },
                      //     controller: null,
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(bottom: 6),
                      //   child: InputCustomizado(
                      //     hint: "Coordenadas Geo",
                      //     onSaved: (latlong) {
                      //      _equipamentos.latlong = latlong;
                      //     },
                      //     type: TextInputType.number,
                      //     inputFormatters: [
                      //       WhitelistingTextInputFormatter.digitsOnly,
                      //       RealInputFormatter(),
                      //
                      //     ],
                      //     validator: (valor) {
                      //       return Validador()
                      //           .add(
                      //           Validar.OBRIGATORIO, msg: "Campo obrigatório")
                      //           .valido(valor);
                      //     },
                      //     controller: null,
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Numero do Processo",
                          onSaved: (NumProcesso) {
                            _equipamentos.NumProcesso = NumProcesso;
                          },
                          type: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            RealInputFormatter(),
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Telefone",
                          onSaved: (Telefone) {
                            _equipamentos.Telefone = Telefone;
                          },
                          type: TextInputType.phone,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter()
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "DATA CESSÃO",

                          onSaved: (DATACESSAO) {
                            _equipamentos.DATACESSAO = DATACESSAO;
                          },
                          type: TextInputType.datetime,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            // RealInputFormatter(centavos: true),
                            DataInputFormatter(),
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      // vistoriar objeto?
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Vistoriado?",
                                ),
                                Switch(
                                    value: _vistoria,
                                    onChanged: (bool valor) {
                                      setState(() {
                                        _vistoria = valor;
                                        _equipamentos.textoBotaovistoria = "não Vistoriado";

                                        if (_vistoria) {
                                         _equipamentos.textoBotaovistoria ="Vistoriado";
                                          _vistoria = valor;
                                        }
                                      });
                                    }),

                                Text(""),
                                // adicionar campo texto para entrada RP caso sim
                                Text(
                                  "Placa Patrimonio?",
                                ),
                                Switch(
                                    value: _rp,
                                    onChanged: (bool valor) {
                                      setState(() {
                                        _rp = valor;
                                        _equipamentos.rp = "não tem Placa Patrimonio";

                                        if (_rp) {
                                          _equipamentos.rp =
                                          "Tem Placa Patrimonio";
                                          _rp = valor;
                                          // adicionar campo rp
                                        }
                                      });
                                    }),
                                Text(""),
                              ],
                            ),
                          ),

                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "rpequip",
                          onSaved: (rpequip) {
                            _equipamentos.rpequip = rpequip;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          }, controller: null,
                          //    controller: null,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Adesivo gov?",
                              ),
                              Switch(
                                  value: _Adesivo,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _Adesivo = valor;
                                      _equipamentos.Adesivo = "não possui adesivo";

                                      if (_Adesivo) {
                                        _equipamentos.Adesivo = "possui adesivo";
                                        _Adesivo = valor;
                                      }
                                    });
                                  }),
                              Text(""),
                              Text(
                                "Placa Num Série?",
                              ),
                              Switch(
                                  value: _serie,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _serie = valor;
                                      _equipamentos.serie = "não tem numero de Série";

                                      if (_serie) {
                                        _equipamentos.serie = "sim possui numero de Série";
                                      }
                                    });
                                  }),
                              Text(""),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Adesivo num Convênio?",
                              ),
                              Switch(
                                  value: _AdesivoConv,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _AdesivoConv = valor;
                                      _equipamentos.AdesivoConv = "não possui adesivo de convenio";

                                      if (_AdesivoConv) {
                                        _equipamentos.AdesivoConv = "possui adesivo de convenio";
                                      }
                                    });
                                  }),
                              Text(""),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Comunidades Atendidas",
                          onSaved: (ComunidadesAtendidas) {
                            _equipamentos.ComunidadesAtendidas =
                                ComunidadesAtendidas;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Numero de famílias atendidas",
                          onSaved: (NumfamiliasAtendidas) {
                            _equipamentos.NumfamiliasAtendidas =
                                NumfamiliasAtendidas;
                          },
                          type: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            RealInputFormatter(),
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),

                      new CheckboxListTile(

                        title: new Text("INCRA"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_1, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _incra = valor;
                            _equipamentos.textoBotaoincra = "não incra";
                            if (_incra) {
                              _equipamentos.textoBotaoincra = "Incra";
                              _incra = valor;
                            };
                          });
                        },
                        value: _incra,
                      ),
                      //_pncf
                      new CheckboxListTile(

                        title: new Text("PNCF/BT"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_2, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _pncf = valor;
                            _equipamentos.textoBotaopncf = "PNCF/BT não";
                            if (_pncf) {
                              _equipamentos.textoBotaopncf = "PNCF/BT";
                              _pncf = valor;
                            };
                          });
                        },
                        value: _pncf,

                      ),
                      new CheckboxListTile(

                        title: new Text("INTERMAT"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_3, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _intermat = valor;
                            _equipamentos.intermat = "não INTERMAT";
                            if (_intermat) {
                              _equipamentos.intermat = "INTERMAT";
                              _intermat = valor;
                            };
                          });
                        },
                        value: _intermat,
                      ),
                      new CheckboxListTile(
                        title: new Text("PCT"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_4, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _pct = valor;
                            _equipamentos.pct = "não PCT";
                            if (_pct) {
                              _equipamentos.pct = "PCT";
                              _pct = valor;
                            }
                          });
                        },
                        value: _pct,
                      ),
                      new CheckboxListTile(
                        title: new Text("AF"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_5, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _af = valor;
                            _equipamentos.af = "não AF";
                            if (_af) {
                              _equipamentos.af = "AF";
                              _af = valor;
                            }
                          });
                        },
                        value: _af,
                      ),
                      new CheckboxListTile(
                        title: new Text("Acampamento"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_6, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _acampamento = valor;
                            _equipamentos.Acampamento = "não Acampamento";
                            if (_acampamento) {
                              _equipamentos.Acampamento = "Acampamento";
                            }
                          });
                        },
                        value: _acampamento,
                      ),
                      new CheckboxListTile(
                        title: new Text("TERCEIROS"),
                        activeColor: Colors.indigo,
                        secondary:
                        const Icon(Icons.directions_walk, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _terceiros = valor;
                            _equipamentos.terceiros = "não TERCEIROS";
                            if (_terceiros) {
                              _equipamentos.terceiros = "TERCEIROS";
                            }
                          });
                        },
                        value: _terceiros,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint: "Gestor do Bem",
                          onSaved: (gestorBem) {
                            _equipamentos.gestorBem = gestorBem;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      new CheckboxListTile(
                        title: new Text("Comodato"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_1, color: Colors.indigo),
                        onChanged: (bool valor) {

                          setState(() {

                            _comodato = valor;
                            _equipamentos.comodato = "não comodato";
                            if(_comodato) {
                              _equipamentos.comodato = "comodato";
                            }
                          });
                        },
                        value: _comodato,
                      ),
                      new CheckboxListTile(
                        title: new Text("Termo de Cessão"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_2, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _termoCessao = valor;
                            _equipamentos.termoCessao = "não termo de Cessão";
                            if(_termoCessao){
                              _equipamentos.termoCessao = "termo de Cessão";
                            }
                          });
                        },
                        value: _termoCessao,
                      ),
                      new CheckboxListTile(
                        title: new Text("Termo de responsabilidade"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_3, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _termoResp = valor;
                            _equipamentos.termoResp = "Não termo de responsabilidade";
                            if(_termoResp){
                              _equipamentos.termoResp = "termo de responsabilidade";
                            }
                          });
                        },
                        value: _termoResp,
                      ),
                      new CheckboxListTile(
                        title: new Text("Permissão de uso"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.filter_4, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _permissaoUso = valor;
                            _equipamentos.permissaoUso = "não permissao de uso";
                            if(_permissaoUso){
                              _equipamentos.permissaoUso = "permissao de uso";
                            }

                          });
                        },
                        value: _permissaoUso,
                      ),

                      new CheckboxListTile(
                          title: new Text("Cessionário"),
                          activeColor: Colors.indigo,
                          secondary:
                          const Icon(Icons.accessibility, color: Colors.indigo),
                          onChanged: (bool valor) {
                            setState(() {
                              _cessionario = valor;
                              _equipamentos.cessionario = "não cessionario";
                              if (_cessionario){
                                _equipamentos.cessionario = "cessionario";
                              }
                            });
                          },
                          value: _cessionario
                      ),
                      new CheckboxListTile(
                          title: new Text("Forneceu como Diária"),
                          activeColor: Colors.indigo,
                          secondary: const Icon(
                              Icons.filter_1, color: Colors.indigo),
                          onChanged: (bool valor) {
                            setState(() {
                              _diaria = valor;
                              _equipamentos.diaria = "não diária";
                              if (_diaria){
                                _equipamentos.diaria = "diária";
                              }

                            });
                          },
                          value: _diaria
                      ),
                      new CheckboxListTile(
                          title: new Text("Combustivel"),
                          activeColor: Colors.indigo,
                          secondary: const Icon(
                              Icons.filter_2, color: Colors.indigo),
                          onChanged: (bool valor) {
                            setState(() {
                              _combustivel = valor;
                              _equipamentos.combustivel = "não combustivel";
                              if (_combustivel){
                                _equipamentos.combustivel = "combustível";
                              }

                            });
                          },
                          value: _combustivel),

                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Lei municipal?",
                              ),
                              Switch(
                                  value: _lei,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _lei = valor;
                                     _equipamentos.lei = "não lei municipal";

                                      if (_lei) {
                                        _equipamentos.lei = "lei municipal";
                                        _lei = valor;
                                      }
                                    });
                                  }),
                              Text(""),
                              Text(
                                "Controle social?",
                              ),
                              Switch(
                                  value: _social,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _social = valor;
                                      _equipamentos.social = "não social";

                                      if (_social) {
                                       _equipamentos.social =" social";
                                        _social = valor;
                                      }
                                    });
                                  }),
                              Text(""),
                            ],
                          ),
                        ),
                      ),

                      //quanto a utilização do bem cedido
                      new CheckboxListTile(
                        title: new Text(
                            "o Bem está sendo utilizado de acordo com O termo?"),
                        activeColor: Colors.indigo,
                        secondary:
                        const Icon(Icons.business_center, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _bem = valor;
                            _equipamentos.bem = "bem não utilizado de acordo";
                            if (_bem){
                              _equipamentos.bem = "bem utilizado de acordo";

                            }
                          });
                        },
                        value: _bem,
                      ),
                      new CheckboxListTile(
                        title: new Text("Documentção em dias?"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.business, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _documento = valor;
                            _equipamentos.documento = "documento atrasados";
                            if(_documento){
                              _equipamentos.documento = "documento em dias";
                            }
                          });
                        },
                        value: _documento,
                      ),
                      new CheckboxListTile(
                        title: new Text(
                            "Manutenção/conservação do Bem adequada?"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.build, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _manutencao = valor;
                            _equipamentos.manutencao = "Manutenção/conservação do Bem não adequada";
                            if (_manutencao){
                              _equipamentos.manutencao = "Manutenção/conservação do Bem adequada";
                            }
                          });
                        },
                        value: _manutencao,
                      ),
                      new CheckboxListTile(
                        title: new Text(
                            "Operadores/motoristas Qualificados/ treinados?"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(Icons.airline_seat_recline_extra,
                            color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _motorista = valor;
                            _equipamentos.motorista = "Operadores/motoristas Qualificados/ treinados Não";
                            if(_motorista){
                              _equipamentos.motorista = "Operadores/motoristas Qualificados/ treinados";
                            }

                          });
                        },
                        value: _motorista,
                      ),

                      new CheckboxListTile(
                        title: new Text("A guarda do bem está adequada?"),
                        activeColor: Colors.indigo,
                        secondary: const Icon(
                            Icons.https, color: Colors.indigo),
                        onChanged: (bool valor) {
                          setState(() {
                            _guarda = valor;
                            _equipamentos.guarda ="A guarda do bem não está adequada";
                            if (_guarda){
                              _equipamentos.guarda ="A guarda do bem está adequada";

                            }
                          });
                        },
                        value: _guarda,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: InputCustomizado(
                          hint:
                          "Descreva quais atividades/culturas o bem esta sendo utilizados (200 caracteres)",
                          maxLines: null,
                          onSaved: (DescrevaAtividades) {
                            _equipamentos.DescrevaAtividades =
                                DescrevaAtividades;
                          },

                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .maxLength(200, msg: "ate 200 caracteres ")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      // caso for resfriador de leite

                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "Nome do entrevistado",
                          onSaved: (NomeEntrevistado) {
                            _equipamentos.NomeEntrevistado = NomeEntrevistado;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: InputCustomizado(
                          hint: "Cargo/Instituição",
                          onSaved: (CargoInstituicao) {
                            _equipamentos.CargoInstituicao = CargoInstituicao;
                          },
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 6, top: 6),
                        child: InputCustomizado(
                          hint: "CPF",
                          onSaved: (CPF) {
                            _equipamentos.CPF = CPF;
                          },
                          type: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                          validator: (valor) {
                            return Validador()
                                .add(
                                Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                          controller: null,
                        ),
                      ),

                      BotaoCustomizado(
                        texto: "Cadastrar Equipamentos",
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            // salva campos

                            _formKey.currentState.save();
                            //conf dialog context
                            _dialogContext = context;

                            // salvar Cadastros
                            _salvarEquipamentos();
                          }
                        },
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
    }
  }
