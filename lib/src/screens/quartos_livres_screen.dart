import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'detalhes_reserva_screen.dart';

class QuartosLivresScreen extends StatefulWidget {
  @override
  _QuartosLivresScreenState createState() => _QuartosLivresScreenState();
}

class _QuartosLivresScreenState extends State<QuartosLivresScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _reservas;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _reservas = {};
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchReservas();
  }

  Future<void> _fetchReservas() async {
    final response = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final Map<DateTime, List<Map<String, dynamic>>> reservas = {};

      for (var reserva in data.values) {
        DateTime startDate = DateFormat('dd/MM/yyyy').parse(reserva['data de entrada']);
        DateTime endDate = DateFormat('dd/MM/yyyy').parse(reserva['data de saida']);
        for (var day = startDate; day.isBefore(endDate) || day.isAtSameMomentAs(endDate); day = day.add(Duration(days: 1))) {
          final dayKey = DateTime(day.year, day.month, day.day);
          if (reservas[dayKey] == null) {
            reservas[dayKey] = [];
          }
          reservas[dayKey]!.add(reserva);
        }
      }

      setState(() {
        _reservas = reservas;
      });
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  List<Map<String, dynamic>> _getReservasForDay(DateTime day) {
    return _reservas[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showReservasDialog(DateTime day) {
    List<Map<String, dynamic>> reservasNoDia = _getReservasForDay(day);
    List<int> quartosOcupados = reservasNoDia.map((reserva) {
      // Verifica se o valor é um int ou string e converte para int se necessário
      var quarto = reserva['quarto'];
      if (quarto is String) {
        return int.parse(quarto);
      } else if (quarto is int) {
        return quarto;
      } else {
        throw Exception('Tipo inesperado para o número do quarto');
      }
    }).toList();

    List<int> quartosLivres = List<int>.generate(12, (index) => index + 1).where((quarto) => !quartosOcupados.contains(quarto)).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reservas para ${DateFormat('dd/MM/yyyy').format(day)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quartos Ocupados:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...reservasNoDia.map((reserva) {
                  return ListTile(
                    title: Text('Quarto: ${reserva['quarto']}'),
                    subtitle: Text('Nome: ${reserva['name']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesReservaScreen(
                            nome: reserva['name'],
                            valorQuarto: reserva['valor do quarto'],
                            formaPagamento: reserva['forma de pagamento'],
                            dataEntrada: reserva['data de entrada'],
                            dataSaida: reserva['data de saida'],
                            quarto: reserva['quarto'],
                            status: reserva['status'],
                            descricao: reserva['descricao'],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                SizedBox(height: 16),
                Text('Quartos Disponíveis:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...quartosLivres.map((quarto) {
                  return ListTile(
                    title: Text('Quarto: $quarto'),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quartos Livres'),
        backgroundColor: Colors.green[900],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showReservasDialog(selectedDay);
            },
            eventLoader: _getReservasForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 95, 3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
