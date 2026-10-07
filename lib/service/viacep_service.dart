import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  /// Retorna o endereço do CEP ou null se não existir / der erro.
  static Future<Map<String, dynamic>?> buscar(String cep) async {
    final limpo = cep.replaceAll(RegExp(r'\D'), '');
    if (limpo.length != 8) return null;

    final resp = await http.get(Uri.parse('https://viacep.com.br/ws/$limpo/json/'));
    if (resp.statusCode != 200) return null;

    final dados = jsonDecode(resp.body) as Map<String, dynamic>;
    if (dados.containsKey('erro')) return null; // CEP inexistente
    return dados;
  }
}