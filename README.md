# projeto01

Aplicativo Flutter para gerenciamento de tarefas, desenvolvido como trabalho
acadêmico. O app permite cadastrar tarefas, anexar imagens (armazenadas em
Base64 no SQLite), organizar tarefas por categorias e consultar feriados a
partir de um serviço HTTP público.

---

## 1. Requisito 1 — CRUD de uma nova tabela (CATEGORIAS)

Foi criado um CRUD completo para a tabela **CATEGORIAS**, com pelo menos 5
campos além do `id`:

| Campo       | Tipo     | Descrição                         |
|-------------|----------|-----------------------------------|
| `id`        | INTEGER  | Chave primária (auto incremento)  |
| `nome`      | TEXT     | Nome da categoria (obrigatório)   |
| `descricao` | TEXT     | Descrição da categoria            |
| `cor`       | TEXT     | Cor em hexadecimal (ex.: `#E53935`) |
| `prioridade`| INTEGER  | Prioridade (1=Baixa, 2=Média, 3=Alta) |
| `ativo`     | INTEGER  | 1 = ativa, 0 = inativa            |

### Operações implementadas

- **Criar** — `lib/screens/form_categoria.dart`
- **Listar** — `lib/screens/list_categoria.dart`
- **Visualizar** — `lib/screens/detalhe_categoria.dart`
- **Editar** — `lib/screens/form_categoria.dart` (reutilizado)
- **Excluir** — `lib/screens/detalhe_categoria.dart`

### Confirmação antes de excluir

A exclusão exibe um `AlertDialog` pedindo confirmação do usuário antes de
apagar o registro (em `detalhe_categoria.dart`). Ao confirmar, as tarefas que
usavam aquela categoria são desvinculadas (`TarefaDao.limparCategoria`).

### Validação de formulário

Os campos obrigatórios (Nome e Descrição) são validados com `Form` +
`TextFormField` + `validator`, seguindo as boas práticas do Flutter:

- https://docs.flutter.dev/cookbook/forms/validation

### Widgets visuais diferentes de `TextField`

- `Switch` — campo **Ativo**.
- `DropdownButtonFormField` — campo **Prioridade**.
- Seletor visual de cor — círculos clicáveis (`lib/components/cores.dart`).

### Atualização/migração do banco de dados

A tabela `CATEGORIAS` foi adicionada por meio de uma migração real em
`lib/database/database.dart`, usando `onUpgrade` e `batch.commit()`:

```dart
onUpgrade: (db, oldVersion, newVersion) async {
  final batch = db.batch();
  if (oldVersion < 2) {
    batch.execute(_createCategoriasSql);
    ...
  }
  await batch.commit(noResult: true);
},
version: _databaseVersion,
```

Veja a seção [Banco de dados](#banco-de-dados) para o histórico completo.

### Barra de menu inferior

O novo CRUD está acessível pela `BottomNavigationBar` em `lib/screens/home.dart`,
com as abas **Tarefas**, **Categorias** e **Feriados**.

---

## 2. Requisito 2 — Recurso com serviço HTTP (Feriados)

A aba **Feriados** consome dados de uma API pública gratuita
([BrasilAPI](https://brasilapi.com.br/api/feriados/v1/)):

- `lib/services/feriado_service.dart` — faz a requisição HTTP `GET`, recebe o
  JSON e faz o *parse* para o modelo `Feriado`.
- `lib/screens/list_feriado.dart` — exibe a lista com **data** e **nome**.

A requisição usa o ano atual e mostra apenas os feriados a partir da data de
hoje (futuros). A tela trata três estados:

- **Carregando** — `CircularProgressIndicator`.
- **Erro** — mensagem de erro com botão "Tentar novamente".
- **Lista vazia** — mensagem informativa.

---

## 3. Funcionalidades extras

### Imagens nas tarefas (Base64 no SQLite)

- Seleção de imagens do dispositivo com `image_picker`.
- Conversão da imagem para **Base64** antes de salvar (`dart:convert`).
- Exibição com `Image.memory(base64Decode(...))`.
- As imagens ficam na tabela `IMAGENS`, relacionadas à tarefa via `tarefa_id`.
- Na lista de tarefas, a primeira imagem vira uma **capa/miniatura** do item.

### Categoria na tarefa

Cada tarefa pode ser vinculada a uma categoria (`categoria_id`), escolhida em um
`DropdownButtonFormField` no formulário de tarefa.

---

## 4. Estrutura de pastas

```
lib/
├── main.dart                  # Inicialização do app e do tema
├── components/
│   ├── editor.dart            # Campo de texto reutilizável (TextFormField)
│   └── cores.dart             # Paleta de cores e função parseCor()
├── database/
│   ├── database.dart          # Abertura do banco, onCreate e migrações (onUpgrade)
│   ├── tarefadao.dart         # CRUD da tabela TAREFAS
│   ├── categoriadao.dart      # CRUD da tabela CATEGORIAS
│   └── imagemdao.dart         # Acesso à tabela IMAGENS
├── model/
│   ├── tarefa.dart            # Modelo Tarefa
│   ├── categoria.dart         # Modelo Categoria
│   ├── imagem.dart            # Modelo Imagem
│   └── feriado.dart           # Modelo Feriado
├── screens/
│   ├── home.dart              # Tela com BottomNavigationBar
│   ├── list_tarefa.dart       # Lista de tarefas (com capa e categoria)
│   ├── form_tarefa.dart       # Formulário de tarefa (com imagens e categoria)
│   ├── list_categoria.dart    # Lista de categorias
│   ├── form_categoria.dart    # Formulário de categoria
│   ├── detalhe_categoria.dart # Visualização/edição/exclusão de categoria
│   └── list_feriado.dart      # Lista de feriados (HTTP)
└── services/
    └── feriado_service.dart   # Requisição HTTP dos feriados
```

---

## 5. Banco de dados

Banco SQLite `dbtarefas.db` (via `sqflite`, com suporte a web via
`sqflite_common_ffi_web`).

### Tabelas

- **TAREFAS** — `id`, `status`, `descricao`, `obs`, `categoria_id`
- **IMAGENS** — `id`, `tarefa_id`, `descricao`, `imagemCodificada` (Base64),
  com `FOREIGN KEY (tarefa_id) REFERENCES TAREFAS(id)`
- **CATEGORIAS** — `id`, `nome`, `descricao`, `cor`, `prioridade`, `ativo`

### Histórico de versões

| Versão | Mudança |
|--------|---------|
| 1      | Tabela `TAREFAS` (estrutura original da aula) |
| 2      | `onUpgrade`: criação da tabela `CATEGORIAS` e da tabela `IMAGENS` |
| 3      | `onUpgrade`: `ALTER TABLE TAREFAS ADD COLUMN categoria_id INTEGER` |

---

## 6. Dependências adicionadas

- `sqflite` — banco SQLite.
- `sqflite_common_ffi_web` — suporte ao SQLite no Flutter Web.
- `http` — requisições HTTP (Feriados).
- `image_picker` — seleção de imagens do dispositivo.
- `path` — montagem do caminho do banco.

---

## 7. Como executar

```bash
flutter pub get
flutter run
```

Para rodar no navegador: `flutter run -d chrome`.

---

## 8. Checklist acadêmico

| Requisito | Onde está implementado |
|-----------|------------------------|
| CRUD de tabela com pelo menos 5 campos | `CATEGORIAS` — `categoriadao.dart` + telas em `screens/` |
| Confirmação antes da exclusão | `AlertDialog` em `detalhe_categoria.dart` |
| Validação de formulário (campos obrigatórios) | `form_categoria.dart` (e `form_tarefa.dart`) via `Form`/`validator` |
| Widget visual diferente | `Switch`, `DropdownButtonFormField`, seletor de cor |
| Atualização/migração do banco | `onUpgrade` em `database.dart` |
| Opção do CRUD na barra de menu inferior | `home.dart` (aba "Categorias") |
| Recurso usando serviço HTTP | `feriado_service.dart` |
| Requisição de dados via HTTP | `http.get` na BrasilAPI |
| Exibição dos dados recebidos | `list_feriado.dart` |
| Armazenamento e exibição de imagens em Base64 | `IMAGENS` + `image_picker` + `Image.memory` |
