
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) validator;
  final Function(String) onSaved;



  const InputCustomizado(
      {@required this.controller,
      @required this.hint,
      this.obscure = false,
      this.autofocus = false,
      this.type = TextInputType.text,
      this.inputFormatters,
      this.maxLines = 1,//para campo descricao nao der erro numero de linha
      this.validator,
      this.onSaved


      });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.type,
      inputFormatters: this.inputFormatters,
      maxLines: this.maxLines,
      onSaved: onSaved,
      validator: this.validator,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(22, 10, 22, 10),
          hintText: this.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          )),
    );
  }
}
