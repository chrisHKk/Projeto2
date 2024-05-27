import 'package:flutter/material.dart';

class DetalhesReservaScreen extends StatelessWidget {
  final String nome;
  final String valorQuarto;
  final String formaPagamento;
  final String dataEntrada;
  final String dataSaida;
  final int quarto;
  final String status;
  final String? descricao;

  DetalhesReservaScreen({
    required this.nome,
    required this.valorQuarto,
    required this.formaPagamento,
    required this.dataEntrada,
    required this.dataSaida,
    required this.quarto,
    required this.status,
    this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: $nome', style: TextStyle(fontSize: 18)),
            Text('Valor do Quarto: $valorQuarto', style: TextStyle(fontSize: 18)),
            Text('Forma de Pagamento: $formaPagamento', style: TextStyle(fontSize: 18)),
            Text('Data de Entrada: $dataEntrada', style: TextStyle(fontSize: 18)),
            Text('Data de Saída: $dataSaida', style: TextStyle(fontSize: 18)),
            Text('Quarto: $quarto', style: TextStyle(fontSize: 18)),
            Text('Status: $status', style: TextStyle(fontSize: 18)),
            Text('Descrição: $descricao', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
