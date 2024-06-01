import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditarReservaScreen extends StatefulWidget {
  final String id;
  final String nome;
  final String valorQuarto;
  final String formaPagamento;
  final String dataEntrada;
  final String dataSaida;
  final int quarto;
  final String status;
  final String descricao;

  EditarReservaScreen({
    required this.id,
    required this.nome,
    required this.valorQuarto,
    required this.formaPagamento,
    required this.dataEntrada,
    required this.dataSaida,
    required this.quarto,
    required this.status,
    required this.descricao,
  });

  @override
  _EditarReservaScreenState createState() => _EditarReservaScreenState();
}

class _EditarReservaScreenState extends State<EditarReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorQuartoController;
  late TextEditingController _dataEntradaController;
  late TextEditingController _dataSaidaController;
  late TextEditingController _descricaoController;
  late int _quartoSelecionado;
  late String? _formaPagamentoSelecionada;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _valorQuartoController = TextEditingController(text: widget.valorQuarto);
    _dataEntradaController = TextEditingController(text: widget.dataEntrada);
    _dataSaidaController = TextEditingController(text: widget.dataSaida);
    _descricaoController = TextEditingController(text: widget.descricao);
    _quartoSelecionado = widget.quarto;
    _formaPagamentoSelecionada = widget.formaPagamento;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorQuartoController.dispose();
    _dataEntradaController.dispose();
    _dataSaidaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _editarReserva() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.patch(
        Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas/${widget.id}.json'),
        body: json.encode({
          'name': _nomeController.text,
          'valor do quarto': _valorQuartoController.text,
          'forma de pagamento': _formaPagamentoSelecionada,
          'data de entrada': _dataEntradaController.text,
          'data de saida': _dataSaidaController.text,
          'quarto': _quartoSelecionado,
          'status': widget.status,
          'descricao': _descricaoController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva editada com sucesso!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar a reserva')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Reserva'),
        backgroundColor: Colors.green[900],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(29.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do cliente';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valorQuartoController,
                decoration: const InputDecoration(labelText: 'Valor do quarto'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor da hospedagem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataEntradaController,
                decoration: const InputDecoration(labelText: 'Data de Entrada'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      _dataEntradaController.text = formattedDate;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _dataSaidaController,
                decoration: const InputDecoration(labelText: 'Data de Saída'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      _dataSaidaController.text = formattedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<int>(
                value: _quartoSelecionado,
                items: List.generate(12, (index) => index + 1)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _quartoSelecionado = newValue;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Quarto (1-12)'),
              ),
              DropdownButtonFormField<String>(
                value: _formaPagamentoSelecionada,
                items: ['Cartão de Crédito', 'Cartão de Débito', 'Dinheiro', 'Pix']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _formaPagamentoSelecionada = newValue;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição Opcional'),
                maxLines: 3,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _editarReserva,
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
