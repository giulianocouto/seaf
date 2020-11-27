import 'package:agriculturafamiliar/models/Equipamentos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemEquipamento extends StatelessWidget {
  Equipamentos equipamento;
  VoidCallback onTapItem;
  VoidCallback onPressedRemover;
  ItemEquipamento({
    @required this.equipamento,
    this.onTapItem,
    this.onPressedRemover
   }
  );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(children: <Widget>[

                SizedBox(
                 width:80,//120
                 height: 80,
                 child: Image.network(equipamento.fotos[0],
                 fit: BoxFit.cover,
                 ),
              ),
                //imagem

                //titulo
                Expanded(
                    flex: 3,//3
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                     Text( equipamento.cidade,

                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold
                     ),
                     ),
                        Text(equipamento.textoBotaovistoria),
                        Text(equipamento.rpequip),
                      Text(equipamento.categoria),
                        // tratar erro nnbd
                        Text(equipamento.DescrevaAtividades == null? "" : equipamento.DescrevaAtividades),
                    ],),
                  ),
                ),
               if (this.onPressedRemover != null) Expanded(
                    flex: 1,
                  child: FlatButton(
                    color: Colors.red,
                    padding: EdgeInsets.all(10),
                    onPressed: this.onPressedRemover,
                    child: Icon(Icons.delete, color: Colors.white,),
                  ),
                )
                //botao remover

          ],
          ),

          ),
        ),
    );
  }
}
