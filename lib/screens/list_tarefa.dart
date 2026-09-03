import 'dart:convert';

import 'package:flutter/material.dart';

import '../components/cores.dart';
import '../database/categoriadao.dart';
import '../database/imagemdao.dart';
import '../database/tarefadao.dart';
import '../model/categoria.dart';
import '../model/imagem.dart';
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
  Map<int, Imagem> capas = {};
  Map<int, Categoria> categorias = {};

  final TarefaDao dao = TarefaDao();
  final ImagemDao imagemDao = ImagemDao();
  final CategoriaDao categoriaDao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void carregarTarefas() async {
    final lista = await dao.findAll();

    final mapaCapas = <int, Imagem>{};
    for (final tarefa in lista) {
      final capa = await imagemDao.findFirstByTarefa(tarefa.id);
      if (capa != null) {
        mapaCapas[tarefa.id] = capa;
      }
    }

    final listaCategorias = await categoriaDao.findAll();
    final mapaCategorias = <int, Categoria>{};
    for (final categoria in listaCategorias) {
      mapaCategorias[categoria.id] = categoria;
    }

    setState(() {
      tarefas = lista;
      capas = mapaCapas;
      categorias = mapaCategorias;
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
    final capa = capas[tarefa.id];
    final categoria = tarefa.categoriaId == null
        ? null
        : categorias[tarefa.categoriaId];

    return Card(
      child: ListTile(
        leading: capa != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(capa.imagemCodificada),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 48,
                  ),
                ),
              )
            : Icon(
                tarefa.status == 0
                    ? Icons.add_alert_rounded
                    : Icons.check_circle,
              ),
        title: Text(tarefa.descricao),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tarefa.obs),
            if (categoria != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: parseCor(categoria.cor),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        categoria.nome,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                tarefa.status == 0
                    ? Icons.check_circle_outline
                    : Icons.undo,
              ),
              onPressed: () {
                mudarStatus(tarefa);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                excluirTarefa(tarefa);
              },
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormaTarefa(tarefa: tarefa);
              },
            ),
          );
          carregarTarefas();
        },
      ),
    );
  }

  void mudarStatus(Tarefa tarefa) async {
    tarefa.status = tarefa.status == 0 ? 1 : 0;
    await dao.update(tarefa);
    carregarTarefas();
  }

  void excluirTarefa(Tarefa tarefa) async {
    await dao.delete(tarefa.id);
    carregarTarefas();
  }
}
