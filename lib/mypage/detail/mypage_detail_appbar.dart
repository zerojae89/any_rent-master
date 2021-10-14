import 'package:flutter/material.dart';

class MyPageDetailAppbar extends StatelessWidget{
  const MyPageDetailAppbar({
    Key key,
    // this.press,
    // this.icon,
    this.title
  }) : super(key: key);
  // final Function press;
  // final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
    );
  }
}