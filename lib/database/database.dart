import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async{

  String path = join(await getDatabasesPath(), 'dbtarefas.db');
  String tableSql = '''
CREATE TABLE TAREFAS (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status INTEGER,
  descricao TEXT,
  obs TEXT
)
''';


  return openDatabase(
      path,
      onCreate: (db, version){
        db.execute(tableSql);
      },
      version : 1
  );
}
