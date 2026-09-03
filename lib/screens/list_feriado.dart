import 'package:flutter/material.dart';

import '../model/feriado.dart';
import '../services/feriado_service.dart';

class ListaFeriado extends StatefulWidget {
  const ListaFeriado({super.key});

  @override
  State<ListaFeriado> createState() => _ListaFeriadoState();
}

class _ListaFeriadoState extends State<ListaFeriado> {
  final FeriadoService _service = FeriadoService();

  List<Feriado> _feriados = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    carregarFeriados();
  }

  Future<void> carregarFeriados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.buscarFeriados();
      setState(() {
        _feriados = lista;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível carregar os feriados.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feriados'),
      ),
      body: construirCorpo(),
    );
  }

  Widget construirCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(_erro!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: carregarFeriados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_feriados.isEmpty) {
      return const Center(child: Text('Nenhum feriado encontrado.'));
    }

    return ListView.builder(
      itemCount: _feriados.length,
      itemBuilder: (context, index) {
        final feriado = _feriados[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(feriado.nome),
            subtitle: Text(feriado.data),
          ),
        );
      },
    );
  }
}
