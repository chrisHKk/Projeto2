import 'package:flutter/material.dart';
import 'package:tela/src/screens/data_entry_form.dart';
import 'package:tela/src/screens/quartos_livres_screen.dart';
import 'package:tela/src/screens/registro_reservas_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Text('Cadastrar Reserva'),
    QuartosLivresScreen(),
    RegistroReservasScreen(),  // Nome atualizado
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
        title: Text(
          'RoomRoost',
          style: TextStyle(
          color: Colors.white,
        ),
        ),
        centerTitle: true,
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
            icon: Icon(Icons.list),
            label: 'Registro de Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatboot',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.black,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
