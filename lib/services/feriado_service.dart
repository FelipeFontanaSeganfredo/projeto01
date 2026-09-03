import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/feriado.dart';

class FeriadoService {
  Future<List<Feriado>> buscarFeriados() async {
    final ano = DateTime.now().year;
    final url = 'https://brasilapi.com.br/api/feriados/v1/$ano';
    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(resposta.body);
      final hoje = _dataHoje();

      return dados.map((item) {
        return Feriado(
          item['date'] as String? ?? '',
          item['name'] as String? ?? '',
        );
      }).where((feriado) {
        return feriado.data.compareTo(hoje) >= 0;
      }).toList();
    }

    throw Exception(
      'Falha ao carregar feriados (status ${resposta.statusCode})',
    );
  }

  String _dataHoje() {
    final agora = DateTime.now();
    final mes = agora.month.toString().padLeft(2, '0');
    final dia = agora.day.toString().padLeft(2, '0');
    return '${agora.year}-$mes-$dia';
  }
}
