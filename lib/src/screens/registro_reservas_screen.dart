import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalhes_reserva_screen.dart';

class RegistroReservasScreen extends StatefulWidget {
  @override
  _RegistroReservasScreenState createState() => _RegistroReservasScreenState();
}

class _RegistroReservasScreenState extends State<RegistroReservasScreen> {
  late Future<List<Map<String, dynamic>>> _reservasFuture;
  List<Map<String, dynamic>> _reservas = [];
  List<Map<String, dynamic>> _reservasFiltradas = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reservasFuture = _fetchReservas();
    _searchController.addListener(_filterReservas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchReservas() async {
    final response = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      List<Map<String, dynamic>> reservas = data.entries.map((entry) {
        final reserva = entry.value as Map<String, dynamic>;
        reserva['id'] = entry.key;
        return reserva;
      }).toList();
      setState(() {
        _reservas = reservas;
        _reservasFiltradas = reservas;
      });
      return reservas;
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  void _filterReservas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _reservasFiltradas = _reservas.where((reserva) {
        return reserva['name'].toLowerCase().contains(query) ||
            reserva['data de entrada'].contains(query) ||
            reserva['data de saida'].contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Reservas'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou data',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reservasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma reserva encontrada'));
          }

          return ListView.builder(
            itemCount: _reservasFiltradas.length,
            itemBuilder: (context, index) {
              final data = _reservasFiltradas[index];
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
                        descricao: data['descricao'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
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
        _reservasFuture = _fetchReservas();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir a reserva')),
      );
    }
  }
}
