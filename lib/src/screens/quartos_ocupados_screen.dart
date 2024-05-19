import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalhes_reserva_screen.dart';

class QuartosOcupadosScreen extends StatefulWidget {
  @override
  _QuartosOcupadosScreenState createState() => _QuartosOcupadosScreenState();
}

class _QuartosOcupadosScreenState extends State<QuartosOcupadosScreen> {
  late Future<List<Map<String, dynamic>>> _quartosOcupadosFuture;

  @override
  void initState() {
    super.initState();
    _quartosOcupadosFuture = _fetchQuartosOcupados();
  }

  Future<List<Map<String, dynamic>>> _fetchQuartosOcupados() async {
    final response = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json?orderBy="status"&equalTo="ocupado"'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries.map((entry) {
        final reserva = entry.value as Map<String, dynamic>;
        reserva['id'] = entry.key; // Adiciona o ID da reserva para futura exclusão
        return reserva;
      }).toList();
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  Future<void> _excluirReserva(BuildContext context, String id) async {
    final response = await http.delete(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas/$id.json'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva excluída com sucesso!')),
      );
      setState(() {
        _quartosOcupadosFuture = _fetchQuartosOcupados();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir a reserva')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _quartosOcupadosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhum quarto ocupado'));
        }

        return ListView(
          children: snapshot.data!.map((data) {
            return ListTile(
              title: Text('Quarto: ${data['quarto']}'),
              subtitle: Text('Nome: ${data['name']}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Excluir Reserva'),
                        content: Text('Tem certeza de que deseja excluir a reserva do quarto ${data['quarto']}?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Sim'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancelar'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    await _excluirReserva(context, data['id']);
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesReservaScreen(
                      nome: data['name'],
                      valorQuarto: data['valor do quarto'],
                      formaPagamento: data['forma de pagamento'],
                      dataEntrada: data['data de entrada'],
                      dataSaida: data['data de saida'],
                      quarto: data['quarto'],
                      status: data['status'],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
