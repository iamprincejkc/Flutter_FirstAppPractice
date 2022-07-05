import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'model/passenger_data.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 1;
  late int totalPages;
  List<Passengers> passengers = [];
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<bool> getPassengerData({bool isRefresh = false}) async {
    if (isRefresh) {
      if (refreshController.headerStatus == RefreshStatus.idle) {
        currentPage++;
      } else {
        currentPage = 1;
      }
    } else if (currentPage >= totalPages) {
      refreshController.loadNoData();
      return true;
    }
    final Uri uri = Uri.parse(
        'https://api.instantwebtools.net/v1/passenger?page=$currentPage&size=10');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final result = passengersDataFromJson(response.body);
      print(isRefresh);
      if (isRefresh) {
        passengers = result.data;
      } else {
        passengers.addAll(result.data);
      }

      totalPages = result.totalPages;

      print(refreshController.headerStatus);
      print('TotalPages:$totalPages');
      print('CurrentPage:$currentPage');

      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade400,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50))),
        toolbarHeight: 60,
        elevation: 14,
        title: const Text('List',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w200,
              fontStyle: FontStyle.italic,
              fontSize: 15.0,
              fontFamily: 'RaleWay',
              fontFamilyFallback: <String>[
                'Noto Sans CJK SC',
                'Noto Color Emoji',
              ],
            )),
        actions: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      blurRadius: 7, spreadRadius: 3, color: Colors.blueAccent)
                ], shape: BoxShape.circle, color: Colors.blue.shade400),
                child: const Icon(Icons.search, size: 20),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      blurRadius: 7, spreadRadius: 3, color: Colors.blueAccent)
                ], shape: BoxShape.circle, color: Colors.blue.shade400),
                child: const Icon(Icons.notifications, size: 20),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      blurRadius: 7, spreadRadius: 3, color: Colors.blueAccent)
                ], shape: BoxShape.circle, color: Colors.blue.shade400),
                child: const Icon(Icons.logout, size: 20),
              ),
              const SizedBox(width: 26)
            ],
          ),
        ],
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getPassengerData(isRefresh: true);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getPassengerData(isRefresh: true);
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        },
        child: ListView.separated(
            itemBuilder: (context, index) {
              final passenger = passengers[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(passenger.airline.logo),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text('${passenger.id} \n ${passenger.name}'),
                  subtitle: Text(passenger.airline.country),
                  trailing: Text(
                    passenger.airline.name,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: passengers.length),
      ),
    );
  }
}
