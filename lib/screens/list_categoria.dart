import 'package:flutter/material.dart';

import '../components/cores.dart';
import '../database/categoriadao.dart';
import '../model/categoria.dart';
import 'detalhe_categoria.dart';
import 'form_categoria.dart';

class ListaCategoria extends StatefulWidget {
  const ListaCategoria({super.key});

  @override
  State<ListaCategoria> createState() => _ListaCategoriaState();
}

class _ListaCategoriaState extends State<ListaCategoria> {
  List<Categoria> categorias = [];
  final CategoriaDao dao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    carregarCategorias();
  }

  void carregarCategorias() async {
    final lista = await dao.findAll();
    setState(() {
      categorias = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Categorias'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormaCategoria(),
            ),
          );
          carregarCategorias();
        },
        child: const Icon(Icons.add),
      ),
      body: categorias.isEmpty
          ? const Center(child: Text('Nenhuma categoria cadastrada.'))
          : ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) => itemCategoria(categorias[index]),
            ),
    );
  }

  Widget itemCategoria(Categoria categoria) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: parseCor(categoria.cor),
        ),
        title: Text(categoria.nome),
        subtitle: Text(categoria.descricao),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalheCategoria(categoria: categoria),
            ),
          );
          carregarCategorias();
        },
      ),
    );
  }
}
