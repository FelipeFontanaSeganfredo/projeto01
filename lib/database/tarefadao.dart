import 'package:sqflite/sqflite.dart';
import '../model/tarefa.dart';
import 'database.dart';

class TarefaDao {
  String _tableName = "tarefas";

  // converter objeto para map
  Map<String, dynamic> toMap(Tarefa tarefa){
    final Map<String, dynamic> tarefaMap = Map();
    tarefaMap['descricao'] = tarefa.descricao;
    tarefaMap['obs'] = tarefa.obs;
    tarefaMap['status'] = tarefa.status;
    return tarefaMap;
  }

  List<Tarefa> toList (List<Map<String, dynamic>> result){
    final List<Tarefa> tarefas = [];
    for (Map<String, dynamic> row in result){
      Tarefa tarefa = Tarefa(row['id'],
          row['status'],
          row['descricao'],
          row['obs']);
      tarefas.add(tarefa);
    }
    return tarefas;
  }
  Future<int> add(Tarefa tarefa) async {
    Database db = await getDatabase();
    Map<String, dynamic> tarefaMap = toMap(tarefa);

    print(tarefaMap);

    return db.insert(_tableName, tarefaMap);
  }

  Future<int> update(Tarefa tarefa) async{
    Database db = await getDatabase();
    Map<String, dynamic> tarefaMap = toMap(tarefa);
    return db.update(_tableName, tarefaMap, where: 'id = ?',
        whereArgs: [tarefa.id]);
  }

  Future<int> delete(int id) async{
    Database db = await getDatabase();
    return db.delete(_tableName, where: 'id = ?',whereArgs: [id]);
  }

  Future<List<Tarefa>> findAll() async{
    Database db = await getDatabase();
    List<Map<String, dynamic>> result = await db.query(_tableName);
    List<Tarefa> tarefas = toList(result);
    return tarefas;
  }
}