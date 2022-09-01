import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    "https://api.hgbrasil.com/finance/stock_price?key=f828834b";

Future<Ativo> getAtivo(String symbol) async {
    symbol = symbol.trim().toUpperCase();
    http.Response response = await http.get('$request&symbol=$symbol');

    if (response.statusCode == 200) {
      return Ativo.fromJson(jsonDecode(response.body), symbol);
    } else {
      throw Exception('Falha ao acessar API.');
    }
}

class Ativo {
  final String empresa;
  final String moeda;
  final double preco;

  const Ativo({this.empresa, this.moeda, this.preco});

  factory Ativo.fromJson(Map<String, dynamic> result, String symbol) {
    if ((!result['valid_key']) || (result['results'][symbol].containsKey('error'))) {
        return const Ativo(
          empresa: 'Chave inválida',
          moeda: '',
          preco: 0,
        );
    } else {
        return Ativo(
            empresa: result['results'][symbol]['company_name'],
            moeda: result['results'][symbol]['currency'],
            preco: result['results'][symbol]['price'],
        );
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();  
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  Future<Ativo> _futureAtivo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Ativos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Consulta de Ativos'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureAtivo == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Informe o código da ação'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureAtivo = getAtivo(_controller.text);
            });
          },
          child: const Text('Pesquisar'),
        ),
      ],
    );
  }

  FutureBuilder<Ativo> buildFutureBuilder() {
    return FutureBuilder<Ativo>(
      future: _futureAtivo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {         
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(snapshot.data.empresa),
              Text(snapshot.data.moeda),
              Text(snapshot.data.preco.toString()),
            ]
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );

/*
  FutureBuilder<Ativo> buildFutureBuilder() {
    return FutureBuilder<Ativo>(
      future: _futureAtivo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {         
          return Text(snapshot.data.empresa);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
*/
  }

}