import 'package:flutter/material.dart';

import '../components/cores.dart';
import '../components/editor.dart';
import '../database/categoriadao.dart';
import '../model/categoria.dart';

class FormaCategoria extends StatefulWidget {
  final Categoria? categoria;

  const FormaCategoria({super.key, this.categoria});

  @override
  State<FormaCategoria> createState() => _FormaCategoriaState();
}

class _FormaCategoriaState extends State<FormaCategoria> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController controladorNome = TextEditingController();
  final TextEditingController controladorDescricao = TextEditingController();

  int _prioridade = 1;
  bool _ativo = true;
  String _cor = paletaCores.first.hex;

  @override
  void initState() {
    super.initState();

    final categoria = widget.categoria;
    if (categoria != null) {
      controladorNome.text = categoria.nome;
      controladorDescricao.text = categoria.descricao;
      _prioridade = categoria.prioridade;
      _ativo = categoria.ativo == 1;
      _cor = categoria.cor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => salvarCategoria(context),
        child: const Icon(Icons.save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Editor(
              controlador: controladorNome,
              rotulo: 'Nome',
              dica: 'Informe o nome da categoria',
              icone: Icons.label,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o nome da categoria';
                }
                return null;
              },
            ),
            Editor(
              controlador: controladorDescricao,
              rotulo: 'Descrição',
              dica: 'Informe a descrição da categoria',
              icone: Icons.description,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe a descrição da categoria';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Cor',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: paletaCores.map((cor) {
                final selecionado = cor.hex == _cor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cor = cor.hex;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cor.cor,
                      shape: BoxShape.circle,
                      border: selecionado
                          ? Border.all(color: Colors.black87, width: 3)
                          : null,
                    ),
                    child: selecionado
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<int>(
                initialValue: _prioridade,
                decoration: const InputDecoration(
                  icon: Icon(Icons.flag),
                  labelText: 'Prioridade',
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Baixa')),
                  DropdownMenuItem(value: 2, child: Text('Média')),
                  DropdownMenuItem(value: 3, child: Text('Alta')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _prioridade = valor;
                    });
                  }
                },
              ),
            ),
            SwitchListTile(
              title: const Text('Ativo'),
              subtitle: const Text('Define se a categoria está ativa'),
              secondary: const Icon(Icons.toggle_on),
              value: _ativo,
              onChanged: (valor) {
                setState(() {
                  _ativo = valor;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void salvarCategoria(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoria = Categoria(
      widget.categoria?.id ?? 0,
      controladorNome.text,
      controladorDescricao.text,
      _cor,
      _prioridade,
      _ativo ? 1 : 0,
    );

    CategoriaDao dao = CategoriaDao();

    if (widget.categoria == null) {
      dao.add(categoria);
    } else {
      dao.update(categoria);
    }

    Navigator.pop(context, categoria);
  }

  @override
  void dispose() {
    controladorNome.dispose();
    controladorDescricao.dispose();
    super.dispose();
  }
}
