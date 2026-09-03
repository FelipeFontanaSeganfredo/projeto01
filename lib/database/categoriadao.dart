import 'package:sqflite/sqflite.dart';
import '../model/categoria.dart';
import 'database.dart';

class CategoriaDao {
  static const String _tableName = 'categorias';

  Map<String, dynamic> toMap(Categoria categoria) {
    return {
      'nome': categoria.nome,
      'descricao': categoria.descricao,
      'cor': categoria.cor,
      'prioridade': categoria.prioridade,
      'ativo': categoria.ativo,
    };
  }

  List<Categoria> toList(List<Map<String, dynamic>> result) {
    final List<Categoria> categorias = [];
    for (Map<String, dynamic> row in result) {
      categorias.add(Categoria(
        row['id'],
        row['nome'],
        row['descricao'],
        row['cor'],
        row['prioridade'],
        row['ativo'],
      ));
    }
    return categorias;
  }

  Future<int> add(Categoria categoria) async {
    Database db = await getDatabase();
    return db.insert(_tableName, toMap(categoria));
  }

  Future<int> update(Categoria categoria) async {
    Database db = await getDatabase();
    return db.update(
      _tableName,
      toMap(categoria),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await getDatabase();
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Categoria>> findAll() async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query(_tableName);
    return toList(result);
  }

  Future<Categoria?> findById(int id) async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return toList(result).first;
  }
}
