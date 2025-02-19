import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/LoginPage.dart';
import 'package:delivery_app/ShoppingCartPage.dart';
import 'package:delivery_app/models/shoppingcart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AccountPage.dart';
import 'HomePage.dart';
import 'OrdersPage.dart';
import 'models/user.dart';
import 'repository/orderitem_repository.dart';
import 'repository/shopping_repository.dart';

class MainUserPageWidget extends StatelessWidget {
  const MainUserPageWidget({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App main user page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainUserPage(title: 'Delivery app main user page', user: user),
    );
  }
}

class MainUserPage extends StatefulWidget {
  const MainUserPage({Key? key, required this.title, required this.user})
      : super(key: key);
  final User user;
  final String title;

  @override
  State<MainUserPage> createState() => MainUserPageState();
}

class MainUserPageState extends State<MainUserPage> {
  int _selectedIndex = 0;
  List<Widget> pages = [];
  static int no_items = 0;
  Timer? timer;

  final ShoppingRepository repository_cart = ShoppingRepository();
  final OrderItemRepository repository_orderitem = OrderItemRepository();

  @override
  void initState() {
    super.initState();
    pages = [
      HomePageWidget(user: widget.user),
      ShoppingCartPageWidget(user: widget.user),
      OrdersPageWidget(user: widget.user),
      AccountPageWidget(user: widget.user),
    ];
    getnoproductsshoppingcart();
    timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (Timer t) => getnoproductsshoppingcart(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getnoproductsshoppingcart() async {
    String cart_ref =
        await repository_cart.searchActiveShoppingcarts(widget.user.ref);
    if (cart_ref != "") {
      List<DocumentSnapshot<Object?>> produse =
          await repository_orderitem.getItemsforShoppingCart(cart_ref);
      no_items = produse.length;
      setState(() {});
    } else {
      final newShoppingcart = ShoppingCart(
        user: widget.user.ref,
        finished: false,
        datetime: "",
      );
      repository_cart.addShoppingCarts(newShoppingcart);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Vrei să ieși din aplicație?'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Nu'),
                  ),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Da'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: pages[_selectedIndex],
        floatingActionButton: (_selectedIndex == 3)
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const LoginPageWidget(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                backgroundColor: Colors.red,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: 'Acasă',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              label: 'Coș',
              backgroundColor: Colors.red,
              icon: Stack(
                children: <Widget>[
                  const Icon(
                    Icons.shopping_cart,
                    size: 30,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: 19.0,
                          width: 19.0,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (no_items < 10) ? "$no_items" : "9+",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                size: 30,
              ),
              label: 'Comenzi',
              backgroundColor: Colors.red,
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle_rounded,
                size: 30,
              ),
              label: 'Cont',
              backgroundColor: Colors.red,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
