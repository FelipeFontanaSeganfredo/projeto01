import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const int _databaseVersion = 3;

String _createTarefasSql = '''
CREATE TABLE IF NOT EXISTS TAREFAS (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status INTEGER,
  descricao TEXT,
  obs TEXT,
  categoria_id INTEGER
)
''';

String _createImagensSql = '''
CREATE TABLE IF NOT EXISTS IMAGENS (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tarefa_id INTEGER,
  descricao TEXT,
  imagemCodificada TEXT,
  FOREIGN KEY (tarefa_id) REFERENCES TAREFAS(id) ON DELETE CASCADE
)
''';

String _createCategoriasSql = '''
CREATE TABLE IF NOT EXISTS CATEGORIAS (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  descricao TEXT NOT NULL,
  cor TEXT NOT NULL,
  prioridade INTEGER NOT NULL,
  ativo INTEGER NOT NULL
)
''';

String _createImagensIndexSql =
    'CREATE INDEX IF NOT EXISTS idx_imagens_tarefa_id ON IMAGENS(tarefa_id)';

Future<Database> getDatabase() async {
  String path = kIsWeb
      ? 'dbtarefas.db'
      : join(await getDatabasesPath(), 'dbtarefas.db');

  return openDatabase(
    path,
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: (db, version) async {
      final batch = db.batch();
      batch.execute(_createTarefasSql);
      batch.execute(_createImagensSql);
      batch.execute(_createImagensIndexSql);
      batch.execute(_createCategoriasSql);
      await batch.commit(noResult: true);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      final batch = db.batch();

      // Migração da versão 1 para a versão 2: adiciona a tabela CATEGORIAS.
      if (oldVersion < 2) {
        batch.execute(_createCategoriasSql);
        // Garante a existência da tabela IMAGENS (com IF NOT EXISTS) para
        // instalações antigas que ainda não a possuíam.
        batch.execute(_createImagensSql);
        batch.execute(_createImagensIndexSql);
      }

      // Migração da versão 2 para a versão 3: adiciona a coluna categoria_id
      // em TAREFAS, permitindo vincular uma categoria a cada tarefa.
      if (oldVersion < 3) {
        batch.execute(
          'ALTER TABLE TAREFAS ADD COLUMN categoria_id INTEGER',
        );
      }

      await batch.commit(noResult: true);
    },
    version: _databaseVersion,
  );
}
