import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido_model.dart';

class ApiService {
  final String baseUrl = "http://172.16.16.27/Projeto_Pizzaria_082026/back-end/php/buscar_pedidos.php";

  Future<List<Pedido>> fetchPedidos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((pedido) => Pedido.fromJson(pedido)).toList();
    } else {
      throw Exception('Falha ao carregar pedidos. Status: ${response.statusCode}');
    }
  }
}