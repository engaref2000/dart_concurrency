import 'package:flutter/material.dart';
import 'dart:developer' as devtool show log;
import 'dart:io';
import 'dart:convert';

extension Log on Object {
  void log() => devtool.log(toString());
}

@immutable
class Person {
  final String name;
  final int age;
  const Person({required this.name, required this.age});

  Person.formjson(Map<String, dynamic> json)
      : name = json["name"] as String,
        age = json["age"] as int;
  @override
  String toString() {
    return 'Person ($name , $age)';
  }
}

extension EmptyOnError<E> on Future<List<Iterable<E>>> {
  Future<List<Iterable<E>>> emptyOnError() =>
      catchError((_, __) => List<Iterable<E>>.empty());
}

void testit() async {
  final persons = await Future.wait([getdate(people1Url), getdate(people2Url)])
      .emptyOnError();
  // final persons = await getdate(people1Url);
  persons.log();
}

Future<Iterable<Person>> getdate(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((lst) => lst.map((e) => Person.formjson(e)));

const people1Url = "http://127.0.0.1:5500/api/people1.json";
const people2Url = "http://127.0.0.1:5500/api/people2.json";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    testit();
    'this after tesit'.log();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
    );
  }
}
