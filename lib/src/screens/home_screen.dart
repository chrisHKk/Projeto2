import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tela/src/screens/data_entry_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Cadastrar Reserva'),
    Text('Quartos Livres'),
    Text('Excluir Reserva'),
    Text('Chatboot'),
  ];

  void _onItemTapped(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataEntryForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RoomRoost'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar Reserva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Quartos Livres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Quartos Ocupados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Excluir Reserva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatboot',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[900], // Cor verde escuro
        unselectedItemColor: Colors.black, // Cor preta para os ícones não selecionados
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

class QuartosOcupadosScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchQuartosOcupados() async {
    final response = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json?orderBy="status"&equalTo="ocupado"'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries.map((entry) => entry.value as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchQuartosOcupados(),
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
              title: Text('Quarto: ${data['roomNumber']}'),
              subtitle: Text('Nome: ${data['name']}'),
            );
          }).toList(),
        );
      },
    );
  }
}
