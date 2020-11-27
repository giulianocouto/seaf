import 'package:agriculturafamiliar/main.dart';
import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:agriculturafamiliar/views/mapa.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesEquipamento extends StatefulWidget {

 Equipamentos equipamento;
 DetalhesEquipamento(this.equipamento);



  @override
  _DetalhesEquipamentoState createState() => _DetalhesEquipamentoState();
}

class _DetalhesEquipamentoState extends State<DetalhesEquipamento> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Equipamentos _equipamentos;

  List<Widget> _getListaImagens() {
// widget.equipamento.fotos
    List<String> listaUrlImagens = _equipamentos.fotos;
    return listaUrlImagens.map((url){
      return Container(
        height: 200,//250
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth
          ),

        ),
      );

    }).toList();


  }
  _ligarTelefone(String telefone) async{
 //    Telefone = "https://www.google.com/";
    if( await canLaunch("Telefone:$telefone")) {
      await launch("Telefone:$telefone");
    }else{
      print("não pode fazer ligação");
      _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("verificar numero de Telefone"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
              )
      );
    }

  }

  _localizarMapa(String mapa) async{
    //    Telefone = "https://www.google.com/";
    if( await canLaunch("Telefone:$mapa()")) {
      await launch("Telefone:$mapa()");
    }else{
      print("não pode encontrar");
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("verificar coordenadas"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          )
      );
    }

  }
    @override
    void initState() {
      super.initState();
      _equipamentos = widget.equipamento;
// para nao precisar chamar widgtes e carregar a tela
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Equipamento"),

        ),
        body: Stack(
          //Conteudos
          children: <Widget>[
            ListView(children: <Widget>[
              SizedBox(
                height: 250,
                child: Carousel(
                  images: _getListaImagens(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.white,
                  autoplay: false,
                  dotIncreasedColor: temaPadrao.primaryColor,
                ),
              ),

              Container(

                padding: EdgeInsets.all(4),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: temaPadrao.primaryColor)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                  Text("Informações listagem de Equipamentos:",

                    style: TextStyle(

                       fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: temaPadrao.primaryColor
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(vertical: 16),
                  //   child: Divider( ),
                  // ),

                  Text("Equipamento : ${_equipamentos.equipamentos}",

                    //   textAlign: TextAlign.justify,
                    style: TextStyle(

                     //   letterSpacing: 1,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: temaPadrao.primaryColor,


                    ),
                    // textAlign: TextAlign.end,
                  ),
                  // Text("Equipamento : ${_equipamentos.equipamentos}",
                  //   style: TextStyle(
                  //       letterSpacing: 1,
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       color: temaPadrao.primaryColor
                  //   ),
                  //  // textAlign: TextAlign.end,
                  // ),
                  // Text( "${_equipamentos.equipamentos}",
                  // style: TextStyle(
                  //   fontSize: 18,
                  //   fontWeight: FontWeight.w400,
                  //   color: temaPadrao.primaryColor
                  // ),
                  // ),
                  Text("Atividades: ${_equipamentos.DescrevaAtividades}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: temaPadrao.primaryColor
                    ),
                  ),

                  // Text ( "${_equipamentos.DescrevaAtividades}",
                  //   style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: temaPadrao.primaryColor
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(vertical: 16),
                  //   child: Divider( ),
                  // ),
                  Text("Telefone para contato: ${_equipamentos.Telefone}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: temaPadrao.primaryColor
                    ),
                  ),
                  // Padding(
                  //     padding: EdgeInsets.only(bottom: 65),
                  //     child: Text ( "${_equipamentos.Telefone}",
                  //       style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.bold,
                  //           color: temaPadrao.primaryColor
                  //       ),
                  //     ),
                  // ),
                    // ),
                    Text("Termo vigente: ${_equipamentos.textoBotaovigente}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui Aditivo: ${_equipamentos.textoBotaoaditivo}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                        ),

                    Text("Numero Termo Cessão: ${_equipamentos.NumTermoCessao}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("latitude: ${_equipamentos.latitude}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("longitude: ${_equipamentos.longitude}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    // Text("Coord Geografica: ${_equipamentos.latlong}",
                    //   style: TextStyle(
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.bold,
                    //       color: temaPadrao.primaryColor
                    //   ),
                    // ),
                    Text("Numero do Processo: ${_equipamentos.NumProcesso}",
                          style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),

                    Text("Data Cessão: ${_equipamentos.DATACESSAO}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Vistoriado: ${_equipamentos.textoBotaovistoria}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui Placa de Patrimonio: ${_equipamentos.rp}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("RP Do equipamento: ${_equipamentos.rpequip}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Posssui Adesivo do Gov: ${_equipamentos.Adesivo}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui Aditivo Convênio: ${_equipamentos.AdesivoConv}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui Placa Num Série: ${_equipamentos.serie}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Comunidades Atendidas: ${_equipamentos.ComunidadesAtendidas}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),

                    Text("Numero de Famílias atendidas: ${_equipamentos.NumfamiliasAtendidas}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Incra: ${_equipamentos.textoBotaoincra}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("PNCF: ${_equipamentos.textoBotaopncf}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("INTERMAT: ${_equipamentos.intermat}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("PCT: ${_equipamentos.pct}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("AF: ${_equipamentos.af}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Acampamento: ${_equipamentos.Acampamento}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Terceiros: ${_equipamentos.terceiros}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Gestor do Bem: ${_equipamentos.gestorBem}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Comodato: ${_equipamentos.comodato}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Termo de Cessão: ${_equipamentos.termoCessao}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Termo de Responsabilidade: ${_equipamentos.termoResp}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Permissão de uso: ${_equipamentos.permissaoUso}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Cessionário: ${_equipamentos.cessionario}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Forneceu como Diária: ${_equipamentos.diaria}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Combustivel: ${_equipamentos.combustivel}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui lei Municipal: ${_equipamentos.lei}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Possui Controle social: ${_equipamentos.social}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("O Bem esta sendo utilizado como de acordo: ${_equipamentos.bem}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Documentação em dia: ${_equipamentos.documento}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Manutenção/conservação do bem Adequada: ${_equipamentos.manutencao}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Operadores/ Motorista qualificados: ${_equipamentos.motorista}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Aguarda do bem adequada: ${_equipamentos.guarda}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Nome do entrevistado: ${_equipamentos.NomeEntrevistado}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("Cargo / Instituição : ${_equipamentos.CargoInstituicao}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),
                    Text("CPF: ${_equipamentos.CPF}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: temaPadrao.primaryColor
                      ),
                    ),


                ],),
              ),
            ],),
            //botaoligar
         Positioned(
           left: 150,
           right: 150,
             bottom: 25,
           child: GestureDetector(
             child: Container(
               child: Text(
                   "Ligar",
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 18

                 ),
               ),
               padding: EdgeInsets.all(6),
               alignment: Alignment.center,
               decoration: BoxDecoration(
                 color: temaPadrao.primaryColor,
                 borderRadius: BorderRadius.circular(30)
               ),
             ),
             onTap: (){
                 _ligarTelefone(_equipamentos.Telefone);


             },
           ),
         ),
            Positioned(
              left: 100,
              right: 100,
              bottom: 80,
              child: GestureDetector(
                child: Container(
                  child: Text(
                    "Localaizar no  mapa",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18

                    ),
                  ),
                  padding: EdgeInsets.all(6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: temaPadrao.primaryColor,
                      borderRadius: BorderRadius.circular(30)
                  ),
                ),
                onTap: (){
             //   _localizarMapa(_equipamentos.latlong);


                },
              ),
            ),

          ],


        ),

      );
    }
  }


