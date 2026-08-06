import 'package:flutter/material.dart';
import '../model/tarefa.dart';


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

          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(

              controller: controladorDescricao,

              style: const TextStyle(fontSize: 20),

              decoration: const InputDecoration(
                icon: Icon(Icons.edit),
                labelText: "Tarefa",
                hintText: "Informe a descrição da tarefa",
              ),

            ),
          ),


          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(

              controller: controladorObs,

              style: const TextStyle(fontSize: 20),

              decoration: const InputDecoration(
                icon: Icon(Icons.edit),
                labelText: "OBS",
                hintText: "Informe a observação da tarefa",
              ),

            ),
          ),

        ],

      ),

    );

  }


  void criarTarefa(BuildContext context) {

    final tarefa = Tarefa(
      controladorDescricao.text,
      controladorObs.text,
    );


    Navigator.pop(context, tarefa);

  }


  @override
  void dispose() {

    controladorDescricao.dispose();
    controladorObs.dispose();

    super.dispose();

  }

}