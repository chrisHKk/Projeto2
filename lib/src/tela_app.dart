
import 'package:flutter/material.dart';
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
    Text('Quartos Ocupados'),
    Text('Excluir Reserva'),
    Text('Chatboot'),
  ];

  void _onItemTapped(int index) {
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
        title: Text('RommRoost'),
        backgroundColor: Colors.green[900], // Cor verde escuro
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
        onTap: _onItemTapped,
      ),
    );
  }
}