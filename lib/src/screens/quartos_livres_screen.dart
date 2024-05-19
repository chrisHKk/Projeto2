import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuartosLivresScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchQuartosLivres() async {
    final response = await http.get(
      Uri.parse('https://pifinal2-default-rtdb.firebaseio.com/reservas.json?orderBy="status"&equalTo="livre"'),
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
      future: _fetchQuartosLivres(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhum quarto livre'));
        }

        return ListView(
          children: snapshot.data!.map((data) {
            return ListTile(
              title: Text('Quarto: ${data['quarto']}'),
              subtitle: Text('Nome: ${data['name']}'),
            );
          }).toList(),
        );
      },
    );
  }
}
