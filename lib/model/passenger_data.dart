// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

PassengersData passengersDataFromJson(String str) => PassengersData.fromJson(json.decode(str) as Map<String, dynamic>) ;

String passengersDataToJson(PassengersData data) => json.encode(data.toJson());

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    forEach((element) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    });

    return result;
  }
}

class PassengersData {
  PassengersData({
    required this.totalPassengers,
    required this.totalPages,
    required this.data,
  });

  int totalPassengers;
  int totalPages;
  List<Passengers> data;

  factory PassengersData.fromJson(Map<String, dynamic> json) => PassengersData(
    totalPassengers: json["totalPassengers"],
    totalPages: json["totalPages"],
    // data: List<Passengers>.from(json["data"].map((x) =>  Passengers.fromJson(x))).distinctBy((y) => y.name).toList(),
    data: List<Passengers>.from(json["data"].map((x) =>  Passengers.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalPassengers": totalPassengers,
    "totalPages": totalPages,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Passengers {
  Passengers({
    required this.id,
    required this.name,
    required this.trips,
    required this.airline,
    required this.v,
  });


  String id;
  String name;
  int trips;
  Airline airline;
  int v;

  factory Passengers.fromJson(Map<String, dynamic> json) => Passengers(
    id: json["_id"],
    name: json["name"],
    trips: json["trips"],
    airline: Airline.fromJson(json["airline"][0]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "trips": trips,
    "airline": airline.toJson(),
    "__v": v,
  };
}

class Airline {
  Airline({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.slogan,
    required this.headQuaters,
    required this.website,
    required this.established,
  });

  int id;
  String name;
  String country;
  String logo;
  String slogan;
  String headQuaters;
  String website;
  String established;

  factory Airline.fromJson(Map<String, dynamic> json) => Airline(
    id: json["id"],
    name: json["name"],
    country: json["country"],
    logo: json["logo"],
    slogan: json["slogan"],
    headQuaters: json["head_quaters"],
    website: json["website"],
    established: json["established"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "country": country,
    "logo": logo,
    "slogan": slogan,
    "head_quaters": headQuaters,
    "website": website,
    "established": established,
  };

}

