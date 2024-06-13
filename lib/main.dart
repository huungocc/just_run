import 'package:flutter/material.dart';
import 'quote.dart';

void main() {
  runApp(MaterialApp(
    home: QuoteList(),
  ));
}

class QuoteList extends StatefulWidget {
  @override
  State<QuoteList> createState() => _QuoteListState();
}

class _QuoteListState extends State<QuoteList> {
  List<Quote> quotes = [
    Quote('Hello I am Ngoc', 'Tom'),
    Quote('Welcome to my app', 'Tim'),
    Quote('I live in Ha Noi, Viet Nam', 'Hela'),
  ];

  Widget QuoteTemplete(quote){
    return Container(
      width: double.infinity,
      child: Card(
        color: Colors.blueGrey[800],
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(quote.text, style: TextStyle(color: Colors.amberAccent, fontSize: 20)),
              Text(quote.author, style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Awesome Quotes', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Column(
        children: quotes.map((quote) => QuoteTemplete(quote)).toList(),
      ),
    );
  }
}
