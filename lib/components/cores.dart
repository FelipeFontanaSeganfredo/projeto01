import 'package:flutter/material.dart';

class Cor {
  final String nome;
  final String hex;
  final Color cor;

  const Cor(this.nome, this.hex, this.cor);
}

const List<Cor> paletaCores = [
  Cor('Vermelho', '#E53935', Color(0xFFE53935)),
  Cor('Rosa', '#D81B60', Color(0xFFD81B60)),
  Cor('Roxo', '#8E24AA', Color(0xFF8E24AA)),
  Cor('Azul', '#1E88E5', Color(0xFF1E88E5)),
  Cor('Verde', '#43A047', Color(0xFF43A047)),
  Cor('Amarelo', '#FDD835', Color(0xFFFDD835)),
  Cor('Laranja', '#FB8C00', Color(0xFFFB8C00)),
  Cor('Marrom', '#6D4C41', Color(0xFF6D4C41)),
];

Color parseCor(String hex) {
  final limpo = hex.replaceAll('#', '');
  final valor = int.tryParse(limpo, radix: 16);
  if (valor == null) {
    return Colors.grey;
  }
  return Color(0xFF000000 | valor);
}
