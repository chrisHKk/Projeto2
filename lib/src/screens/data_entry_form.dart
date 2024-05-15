import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataEntryForm extends StatefulWidget {
  const DataEntryForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                decoration: const InputDecoration(labelText: 'Valor (float)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor da hospedagem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stringController,
                decoration:
                    const InputDecoration(labelText: 'Forma de Pagamento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Forma de pagamento';
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
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      _dataEntradaController.text = formattedDate;
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
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      _dataSaidaController.text = formattedDate;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                    }
                  },
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Texto em negrito
                      fontSize: 20, // Tamanho da fonte
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
