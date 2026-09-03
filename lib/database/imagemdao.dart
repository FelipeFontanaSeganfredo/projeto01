import 'package:sqflite/sqflite.dart';
import '../model/imagem.dart';
import 'database.dart';

class ImagemDao {
  static const String _tableName = 'imagens';

  Map<String, dynamic> toMap(Imagem imagem) {
    return {
      'tarefa_id': imagem.tarefaId,
      'descricao': imagem.descricao,
      'imagemCodificada': imagem.imagemCodificada,
    };
  }

  List<Imagem> toList(List<Map<String, dynamic>> result) {
    final List<Imagem> imagens = [];
    for (Map<String, dynamic> row in result) {
      imagens.add(Imagem(
        row['id'],
        row['tarefa_id'],
        row['descricao'],
        row['imagemCodificada'],
      ));
    }
    return imagens;
  }

  Future<int> add(Imagem imagem) async {
    Database db = await getDatabase();
    return db.insert(_tableName, toMap(imagem));
  }

  Future<int> delete(int id) async {
    Database db = await getDatabase();
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Imagem>> findByTarefa(int tarefaId) async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db
        .query(_tableName, where: 'tarefa_id = ?', whereArgs: [tarefaId]);
    return toList(result);
  }

  Future<Imagem?> findFirstByTarefa(int tarefaId) async {
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'tarefa_id = ?',
      whereArgs: [tarefaId],
      orderBy: 'id ASC',
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return toList(result).first;
  }
}
