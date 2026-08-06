import 'package:flutter/material.dart';
import '../database/tarefadao.dart';
import '../model/tarefa.dart';
import 'form_tarefa.dart';


class ListaTarefa extends StatefulWidget {

  const ListaTarefa({super.key});

  @override
  State<ListaTarefa> createState() {
    return ListaTarefaState();
  }

}


class ListaTarefaState extends State<ListaTarefa> {

  List<Tarefa> tarefas = [];

  final TarefaDao dao = TarefaDao();


  @override
  void initState() {
    super.initState();

    carregarTarefas();
  }


  void carregarTarefas() async {

    final lista = await dao.findAll();

    setState(() {
      tarefas = lista;
    });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),


      floatingActionButton: FloatingActionButton(

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormaTarefa();
              },
            ),
          );


          carregarTarefas();

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