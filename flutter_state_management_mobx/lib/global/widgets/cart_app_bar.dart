import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:state_management_example/global/styles/app_colors.dart';
import 'package:state_management_example/global/styles/app_fonts.dart';
import 'package:state_management_example/global/widgets/cart_list_tile.dart';
import 'package:state_management_example/mobx/cart.dart';

import 'cart_icon_button.dart';

class CartAppBar extends StatefulWidget {
  CartAppBar({@required this.inHomePage, @required this.title});

  final bool inHomePage;
  final String title;

  @override
  _CartAppBarState createState() => _CartAppBarState();
}

class _CartAppBarState extends State<CartAppBar> {
  bool showCart = false;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  void cartOnClick() {
    setState(() {
      showCart == false ? showCart = true : showCart = false;
    });
  }

  void deleteOnClick() {
    final cart = Provider.of<Cart>(context);
    cart.emptyCart();
  }

  void categoryOnClick(BuildContext context) {
    Navigator.of(context).pop();
  }

  void checkoutOnClick() {
    print('Go to checkout here!');
  }

  Widget buildButton() {
    Widget homeBtn = IconButton(
      icon: Icon(Icons.view_agenda, color: AppColors.appWhite),
      onPressed: () => categoryOnClick(context),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15.0),
    );
    Widget deleteBtn = IconButton(
      icon: Icon(Icons.delete_outline, color: AppColors.appWhite),
      onPressed: () => deleteOnClick(),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15.0),
    );

    if (widget.inHomePage) {
      return AnimatedCrossFade(
        firstChild: deleteBtn,
        secondChild: const SizedBox(width: 48),
        crossFadeState:
            showCart ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 250),
      );
    } else {
      return AnimatedCrossFade(
        firstChild: deleteBtn,
        secondChild: homeBtn,
        crossFadeState:
            showCart ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusbar = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = 56;
    double dragStart;
    final cart = Provider.of<Cart>(context);
    return GestureDetector(
      onVerticalDragStart: (d) {
        dragStart = d.globalPosition.dy;
      },
      onVerticalDragUpdate: (d) {
        if (d.globalPosition.dy > dragStart + 100) {
          setState(() {
            showCart = true;
          });
        } else if ((d.globalPosition.dy < dragStart - 100)) {
          setState(() {
            showCart = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: showCart == true ? screenHeight * 0.85 : 56 + statusbar,
        decoration: BoxDecoration(color: AppColors.appBlue1, boxShadow: [
          BoxShadow(
              color: AppColors.appBlack,
              blurRadius: 10,
              spreadRadius: 10,
              offset: Offset(0, -10))
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: appBarHeight + statusbar,
              child: Padding(
                padding: EdgeInsets.only(top: statusbar),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildButton(),
                    Expanded(
                        child: Text(showCart ? 'Cart' : widget.title,
                            textAlign: TextAlign.center,
                            style: AppFonts.appbarTitle())),
                    CartIconButton(
                      cartOnClick: cartOnClick,
                    ),
                  ],
                ),
              ),
            ),
            showCart == true
                ? Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: ListView(
                                children: List.generate(
                                    cart.uniqueProducts().length, (index) {
                          final product = cart.uniqueProducts()[index];
                          return Observer(
                            builder: (_) {
                              final quantity = cart.getProductQuantity(product);
                              return quantity > 0
                                  ? CartListTile(
                                      product: product,
                                      quantity:
                                          cart.getProductQuantity(product),
                                    )
                                  : const SizedBox();
                            },
                          );
                        }))),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Observer(builder: (_) {
                                return Text(
                                  "\$${cart.getCartValue()}",
                                  style: AppFonts.cartValue(),
                                );
                              }),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                color: AppColors.appWhite,
                                splashColor: Colors.grey,
                                onPressed: () => checkoutOnClick(),
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.payment,
                                        color: AppColors.appBlue2,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Go to checkout',
                                        style: AppFonts.cartCheckOutBtn(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
