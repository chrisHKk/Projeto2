import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class DataEntryForm extends StatefulWidget {
  const DataEntryForm({Key? key}) : super(key: key);

  @override
  State<DataEntryForm> createState() => _DataEntryFormState();
}

class _DataEntryFormState extends State<DataEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _floatController = TextEditingController();
  final _stringController = TextEditingController();
  final _dataEntradaController = TextEditingController();
  final _dataSaidaController = TextEditingController();
  int _numeroSelecionado = 1;
  String? _formaPagamentoSelecionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva'),
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
                controller: _floatController,
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
              DropdownButtonFormField(
                value: _numeroSelecionado,
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
                      _numeroSelecionado = newValue;
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
              
              Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _submitForm();
        }
      },
      child: const Text(
        'Enviar',
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

Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Verificar quartos ocupados
    final ocupadosResponse = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json?orderBy="status"&equalTo="ocupado"'),
    );

    if (ocupadosResponse.statusCode == 200) {
      final ocupadosData = json.decode(ocupadosResponse.body) as Map<String, dynamic>?;
      
      // Map vazio para representar que não há quartos ocupados
      final List<Map<String, dynamic>> ocupados = ocupadosData?.entries.map((entry) => entry.value as Map<String, dynamic>).toList() ?? [];

      // Verificar se o quarto está ocupado durante o período selecionado
      final selectedStartDate = DateFormat('dd/MM/yyyy').parse(_dataEntradaController.text);
      final selectedEndDate = DateFormat('dd/MM/yyyy').parse(_dataSaidaController.text);

      if (ocupados.any((reserva) =>
          reserva['quarto'] == _numeroSelecionado &&
          (selectedStartDate.isBefore(DateFormat('dd/MM/yyyy').parse(reserva['data de saida'])) &&
              selectedEndDate.isAfter(DateFormat('dd/MM/yyyy').parse(reserva['data de entrada']))))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quarto não disponível para as datas selecionadas')),
        );
        return; // Abortar o envio do formulário
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar quartos ocupados')),
      );
      return; // Abortar o envio do formulário
    }

    // Enviar a reserva se o quarto estiver disponível
    final response = await http.post(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json'),
      body: json.encode({
        'name': _nomeController.text,
        'valor do quarto': _floatController.text,
        'forma de pagamento': _stringController.text,
        'data de entrada': _dataEntradaController.text,
        'quarto': _numeroSelecionado,
        'data de saida': _dataSaidaController.text,
        'status': 'ocupado',
      }),
    );

    if (response.statusCode == 200) {
      _nomeController.clear();
      _floatController.clear();
      _stringController.clear();
      _dataEntradaController.clear();
      _dataSaidaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva enviada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar a reserva')),
      );
    }
  }
}

}
