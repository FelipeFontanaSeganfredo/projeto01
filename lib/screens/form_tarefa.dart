import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/editor.dart';
import '../database/categoriadao.dart';
import '../database/imagemdao.dart';
import '../database/tarefadao.dart';
import '../model/categoria.dart';
import '../model/imagem.dart';
import '../model/tarefa.dart';

class FormaTarefa extends StatefulWidget {
  final Tarefa? tarefa;

  const FormaTarefa({super.key, this.tarefa});

  @override
  State<FormaTarefa> createState() => FormaTarefaState();
}

class FormaTarefaState extends State<FormaTarefa> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController controladorDescricao = TextEditingController();
  final TextEditingController controladorObs = TextEditingController();

  final TarefaDao _tarefaDao = TarefaDao();
  final ImagemDao _imagemDao = ImagemDao();
  final CategoriaDao _categoriaDao = CategoriaDao();
  final ImagePicker _picker = ImagePicker();

  final List<Imagem> _imagensExistentes = [];
  final List<Imagem> _imagensNovas = [];
  final List<int> _imagensRemovidas = [];

  List<Categoria> _categorias = [];
  int? _categoriaId;

  @override
  void initState() {
    super.initState();

    if (widget.tarefa != null) {
      controladorDescricao.text = widget.tarefa!.descricao;
      controladorObs.text = widget.tarefa!.obs;
      _categoriaId = widget.tarefa!.categoriaId;
      carregarImagens();
    }

    carregarCategorias();
  }

  Future<void> carregarCategorias() async {
    final lista = await _categoriaDao.findAll();
    setState(() {
      _categorias = lista;
    });
  }

  Future<void> carregarImagens() async {
    final lista = await _imagemDao.findByTarefa(widget.tarefa!.id);
    setState(() {
      _imagensExistentes.clear();
      _imagensExistentes.addAll(lista);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Tarefa'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          salvarTarefa();
        },
        child: const Icon(Icons.save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Editor(
              controlador: controladorDescricao,
              rotulo: 'Tarefa',
              dica: 'Informe a descrição da tarefa',
              icone: Icons.edit,
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe a descrição da tarefa';
                }
                return null;
              },
            ),
            Editor(
              controlador: controladorObs,
              rotulo: 'OBS',
              dica: 'Informe a observação da tarefa',
              icone: Icons.edit,
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe a observação da tarefa';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<int?>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(
                  icon: Icon(Icons.category),
                  labelText: 'Categoria',
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sem categoria'),
                  ),
                  ..._categorias.map(
                    (categoria) => DropdownMenuItem<int?>(
                      value: categoria.id,
                      child: Text(categoria.nome),
                    ),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _categoriaId = valor;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Imagens',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            secaoImagens(),
          ],
        ),
      ),
    );
  }

  Widget secaoImagens() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ..._imagensExistentes
              .map((imagem) => miniaturaImagem(imagem, existente: true)),
          ..._imagensNovas
              .map((imagem) => miniaturaImagem(imagem, existente: false)),
          botaoAdicionar(),
        ],
      ),
    );
  }

  Widget botaoAdicionar() {
    return GestureDetector(
      onTap: escolherImagem,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32),
            SizedBox(height: 4),
            Text('Adicionar'),
          ],
        ),
      ),
    );
  }

  Widget miniaturaImagem(Imagem imagem, {required bool existente}) {
    Widget preview;
    try {
      preview = Image.memory(
        base64Decode(imagem.imagemCodificada),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    } catch (e) {
      preview = const Icon(Icons.broken_image);
    }

    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: preview,
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: () => removerImagem(imagem, existente: existente),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> escolherImagem() async {
    final XFile? arquivo = await _picker.pickImage(source: ImageSource.gallery);
    if (arquivo == null) {
      return;
    }

    final Uint8List bytes = await arquivo.readAsBytes();
    final String base64 = base64Encode(bytes);

    setState(() {
      _imagensNovas.add(
        Imagem(0, widget.tarefa?.id ?? 0, arquivo.name, base64),
      );
    });
  }

  void removerImagem(Imagem imagem, {required bool existente}) {
    setState(() {
      if (existente) {
        _imagensExistentes.remove(imagem);
        _imagensRemovidas.add(imagem.id);
      } else {
        _imagensNovas.remove(imagem);
      }
    });
  }

  Future<void> salvarTarefa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int id = widget.tarefa?.id ?? 0;
    final int status = widget.tarefa?.status ?? 0;

    final tarefa = Tarefa(
      id,
      status,
      controladorDescricao.text,
      controladorObs.text,
      categoriaId: _categoriaId,
    );

    int tarefaId = id;
    if (widget.tarefa == null) {
      tarefaId = await _tarefaDao.add(tarefa);
    } else {
      await _tarefaDao.update(tarefa);
    }

    for (final imagem in _imagensNovas) {
      imagem.tarefaId = tarefaId;
      await _imagemDao.add(imagem);
    }

    for (final idImagem in _imagensRemovidas) {
      await _imagemDao.delete(idImagem);
    }

    if (mounted) {
      Navigator.pop(context, tarefa);
    }
  }

  @override
  void dispose() {
    controladorDescricao.dispose();
    controladorObs.dispose();
    super.dispose();
  }
}
