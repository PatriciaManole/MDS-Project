import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/RestaurantCard.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'models/restaurant.dart';
import 'models/user.dart';
import 'repository/restaurant_repository.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App main page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(title: 'Delivery app main page', user: user),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title, required this.user})
      : super(key: key);
  final User user;
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var search = "";
  final RestaurantRepository repository_restaurant = RestaurantRepository();

  bool con = false,
      old_con = true,
      is_connected = true,
      foundrestaurants = true;
  Timer? timer, timer2;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => AwaitConnection(),
    );
    timer2 = Timer.periodic(
      const Duration(seconds: 3),
      (Timer t) => isConnected(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(35),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                  decoration: const InputDecoration(
                    fillColor: Color.fromARGB(31, 139, 139, 139),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    hintText: 'Caută orice iți dorești în restaurante',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "Restaurante",
                        style: TextStyle(
                            fontFamily: 'Lato-Black',
                            fontSize: 30,
                            color: Colors.red,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        child: con
                            ? StreamBuilder<QuerySnapshot>(
                                stream: search == ""
                                    ? repository_restaurant.getRestaurants()
                                    : repository_restaurant
                                        .getSearchRestaurants(search),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.data?.size == 0) {
                                    return Container(
                                      padding: const EdgeInsets.only(top: 50),
                                      child: const Text(
                                        "Nu am putut găsi restaurantul căutat.",
                                        style: TextStyle(
                                          fontFamily: 'Lato-Black',
                                          fontSize: 20.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return _buildList(
                                        context, snapshot.data?.docs ?? []);
                                  } else {
                                    return const LinearProgressIndicator();
                                  }
                                },
                              )
                            : is_connected
                                ? Center(
                                    child: Column(
                                      children: const <Widget>[
                                        CircularProgressIndicator(),
                                        SizedBox(height: 25),
                                        Text(
                                          "Se încarcă ... ",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 255, 0, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      children: const <Widget>[
                                        SizedBox(height: 10),
                                        Text(
                                          "Verifică conexiunea la internet",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 255, 0, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot.isEmpty) {
      foundrestaurants = false;
    } else {
      foundrestaurants = true;
    }

    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      physics: const NeverScrollableScrollPhysics(),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final restaurant = Restaurant.fromSnapshot(snapshot);

    return Column(
      children: <Widget>[
        RestaurantCard(
          restaurant: restaurant,
          user: widget.user,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  AwaitConnection() async {
    bool oldcon = con;
    con = await CheckConnection();
    if (oldcon != con) {
      setState(() {});
    }
  }

  isConnected() {
    if (con == old_con && con == false) {
      is_connected = false;
      setState(() {});
    } else {
      is_connected = true;
    }
    old_con = con;
  }
}
