import 'package:flutter/material.dart';

import 'list_categoria.dart';
import 'list_feriado.dart';
import 'list_tarefa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _indice = 0;

  final List<Widget> _telas = const [
    ListaTarefa(),
    ListaCategoria(),
    ListaFeriado(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (valor) {
          setState(() {
            _indice = valor;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Feriados',
          ),
        ],
      ),
    );
  }
}
