import 'package:flutter/material.dart';
import '../database/tarefadao.dart';
import '../model/tarefa.dart';
import '../components/editor.dart';


class FormaTarefa extends StatefulWidget {

  const FormaTarefa({super.key});

  @override
  State<FormaTarefa> createState() {
    return FormaTarefaState();
  }

}


class FormaTarefaState extends State<FormaTarefa> {

  TextEditingController controladorDescricao =
  TextEditingController();

  TextEditingController controladorObs =
  TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Formulário de Tarefa"),
      ),


      floatingActionButton: FloatingActionButton(

        onPressed: () {
          criarTarefa(context);
        },

        child: const Icon(Icons.save),

      ),


      body: Column(

        children: [

          Editor(
            controlador: controladorDescricao,
            rotulo: "Tarefa",
            dica: "Informe a descrição da tarefa",
            icone: Icons.edit,
          ),


          Editor(
            controlador: controladorObs,
            rotulo: "OBS",
            dica: "Informe a observação da tarefa",
            icone: Icons.edit,
          ),

        ],

      ),

    );

  }


  void criarTarefa(BuildContext context) {

    final tarefa = Tarefa(
      0,
      0,
      controladorDescricao.text,
      controladorObs.text,
    );

    TarefaDao dao = TarefaDao();
    dao.add(tarefa);

    Navigator.pop(context, tarefa);

  }


  @override
  void dispose() {

    controladorDescricao.dispose();
    controladorObs.dispose();

    super.dispose();

  }

}