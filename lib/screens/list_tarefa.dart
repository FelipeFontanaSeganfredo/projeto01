import 'package:flutter/material.dart';
import '../model/tarefa.dart';
import 'form_tarefa.dart';


class ListaTarefa extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ListaTarefaState();
  }

}


class ListaTarefaState extends State<ListaTarefa> {

  List<Tarefa> tarefas = [];


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),


      floatingActionButton: FloatingActionButton(

        onPressed: () {

          final Future future = Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormaTarefa();
              },
            ),
          );


          future.then((tarefa) {

            setState(() {
              tarefas.add(tarefa);
            });

          });

        },

        child: const Icon(Icons.add),

      ),


      body: ListView.builder(

        itemCount: tarefas.length,


        itemBuilder: (context, index) {

          final tarefa = tarefas[index];

          return itemTarefa(tarefa);

        },

      ),

    );

  }


  Widget itemTarefa(Tarefa tarefa) {

    return Card(

      child: ListTile(

        leading: const Icon(Icons.add_alert_rounded),

        title: Text(tarefa.descricao),

        subtitle: Text(tarefa.obs),

      ),

    );

  }

}
