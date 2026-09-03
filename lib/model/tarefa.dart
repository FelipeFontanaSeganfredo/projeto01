class Tarefa {
  int id;
  int status;
  String descricao;
  String obs;
  int? categoriaId;

  Tarefa(
    this.id,
    this.status,
    this.descricao,
    this.obs, {
    this.categoriaId,
  });
}