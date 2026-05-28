class Pedido {
  final String id;
  final String nome;
  final String endereco;
  final String cidade;
  final String cep;
  final String formaPagamento;
  final String pedido;
  final double total;
  final String dataPedido;
  final String status;

  Pedido({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.cep,
    required this.formaPagamento,
    required this.pedido,
    required this.total,
    required this.dataPedido,
    required this.status,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      cep: json['cep'],
      formaPagamento: json['forma_pagamento'],
      pedido: json['pedido'],
      total: double.parse(json['total'].toString()), 
      dataPedido: json['data_pedido'],
      status: json['status'],
    );
  }
}