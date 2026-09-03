import 'package:flutter/material.dart';

import '../components/cores.dart';
import '../database/categoriadao.dart';
import '../database/tarefadao.dart';
import '../model/categoria.dart';
import 'form_categoria.dart';

class DetalheCategoria extends StatefulWidget {
  final Categoria categoria;

  const DetalheCategoria({super.key, required this.categoria});

  @override
  State<DetalheCategoria> createState() => _DetalheCategoriaState();
}

class _DetalheCategoriaState extends State<DetalheCategoria> {
  late Categoria _categoria;
  final CategoriaDao dao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    _categoria = widget.categoria;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Categoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => editarCategoria(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => excluirCategoria(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: parseCor(_categoria.cor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _categoria.nome,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Descrição', style: Theme.of(context).textTheme.titleSmall),
            Text(
              _categoria.descricao,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('Prioridade', style: Theme.of(context).textTheme.titleSmall),
            Text(descricaoPrioridade(_categoria.prioridade)),
            const SizedBox(height: 16),
            Text('Cor', style: Theme.of(context).textTheme.titleSmall),
            Text(_categoria.cor),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _categoria.ativo == 1 ? Icons.check_circle : Icons.cancel,
                  color: _categoria.ativo == 1 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(_categoria.ativo == 1 ? 'Ativa' : 'Inativa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String descricaoPrioridade(int prioridade) {
    switch (prioridade) {
      case 1:
        return 'Baixa';
      case 2:
        return 'Média';
      case 3:
        return 'Alta';
      default:
        return 'Baixa';
    }
  }

  Future<void> editarCategoria() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormaCategoria(categoria: _categoria),
      ),
    );

    if (resultado is Categoria) {
      setState(() {
        _categoria = resultado;
      });
    }
  }

  Future<void> excluirCategoria() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir categoria'),
          content: Text(
            'Deseja realmente excluir a categoria "${_categoria.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      final TarefaDao tarefaDao = TarefaDao();
      await tarefaDao.limparCategoria(_categoria.id);
      await dao.delete(_categoria.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
