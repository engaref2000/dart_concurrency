import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:developer' as devtool show log;
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;

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

///this extension handel all the wait Future for any resone if
///item in list of wait is fauild the result will empty list
///ignoring if one or more item in list of Future wate is success
extension EmptyOnError<E> on Future<List<Iterable<E>>> {
  Future<List<Iterable<E>>> emptyOnError() =>
      catchError((_, __) => List<Iterable<E>>.empty());
}

///this extension handel one item in  the wait Future for any resone if item in list of wait is fauild the result will empty
///for this item .
///the other item in list of Future waite is success and
///give its result .
extension EmptyOnErrorOnFuture<E> on Future<Iterable<E>> {
  Future<Iterable<E>> emptyOnErr() =>
      catchError((_, __) => Iterable<E>.empty());
}

/*
the Future.forEach function 
if you don,t care about of result of running the Future , 
will porcess all the iterable action 
and feed with null if success 
and return .catchError((_, __) => -1) here -1 if any error happing 

 */
Stream<Iterable<Person>> getPerson() async* {
  for (final url in Iterable.generate(
      2, (i) => 'http://127.0.0.1:5500/api/people${i + 1}.json')) {
    yield await getdata(url);
  }
}

void testit() async {
  final result = await Future.forEach(
    Iterable.generate(
        2, (i) => "http://127.0.0.1:5500/api/people${i + 1}.json"),
    getdata,
  ).catchError((_, __) => -1);
  if (result != null) {
    'Error accurred'.log();
  } else {
    'all Done '.log();
  }
  // final persons = await getdate(people1Url);
  // persons.log();

  ///the resutl is
  ///[(), (Person (foo 2 , 30), Person (bear 2 , 30), Person (baz 2 , 20), Person (koo 2 , 40))]
}

void testit1() async {
  await for (final person in getPerson()) {
    person.log();
  }
}

Future<Iterable<Person>> getdata(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((lst) => lst.map((e) => Person.formjson(e)));

const people1Url = "http://127.0.0.1:5500/api/people11.json";
const people2Url = "http://127.0.0.1:5500/api/people2.json";

mixin ListOfThingsAPI<T> {
  Future<Iterable<T>> get(String url) => HttpClient()
      .getUrl(Uri.parse(url))
      .then((reqs) => reqs.close())
      .then((resp) => resp.transform(utf8.decoder).join())
      .then((str) => json.decode(str) as List<dynamic>)
      .then((lst) => lst.cast());
}

class GetApiEndPoint with ListOfThingsAPI<String> {}

class GetPeople with ListOfThingsAPI<Map<String, dynamic>> {
  Future<Iterable<Person>> getPeople(String url) => get(url).then(
        (jsons) => jsons.map(
          (e) => Person.formjson(e),
        ),
      );
}

void testIt3() async {
  final people = await GetApiEndPoint()
      .get(
        'http://127.0.0.1:5500/api/apis.json',
      )
      .then((urls) => Future.wait(
            urls.map(
              (url) => GetPeople().getPeople(url),
            ),
          ));
  people.log();
}

void testIt4() async {
  await for (final people in Stream.periodic(const Duration(seconds: 3))
      .asyncExpand((_) => GetPeople()
          .getPeople(
            'http://127.0.0.1:5500/api/people1.json',
          )
          .asStream())) {
    people.log();
  }
}

extension RandomElement<T> on Iterable<T> {
  T getRandomItem() => elementAt(math.Random().nextInt(length));
}

const names = ['foo', 'bar', 'baz'];

class UpperCaseSink implements EventSink<String> {
  final EventSink<String> _sink;
  UpperCaseSink(this._sink);

  @override
  void add(String event) => _sink.add(event.toUpperCase());

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);

  @override
  void close() => _sink.close();
}

class StreamTransformCaseString extends StreamTransformerBase<String, String> {
  @override
  Stream<String> bind(
    Stream<String> stream,
  ) =>
      Stream<String>.eventTransformed(stream, (sink) => UpperCaseSink(sink));
}

void testit5() async {
  await for (final name in Stream.periodic(
      const Duration(seconds: 3), (_) => names.getRandomItem()).transform(
    StreamTransformCaseString(),
  )) {
    name.log();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    testit5();
    // 'this after tesit'.log();
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
