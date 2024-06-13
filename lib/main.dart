import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Quote(),
  ));
}

class Quote extends StatefulWidget {
  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  List<String> quote = [
    'My name is Ngoc',
    'I was born in Viet Nam',
    'I speak Vietnamese'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Awesome Quotes', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Column(
        children: quote.map((quote) => Text(quote)).toList(),
      ),
    );
  }
}
