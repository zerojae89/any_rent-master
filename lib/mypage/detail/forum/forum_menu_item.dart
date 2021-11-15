import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';

class MyPageMenuItem extends StatelessWidget{
  const MyPageMenuItem({ Key key, this.press, this.icon, this.title, this.horizontal, this.vertical }) : super(key: key);
  final Function press;
  final Icon icon;
  final String title;
  final int horizontal;
  final int vertical;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return InkWell(
      onTap: press,
      child: Column(
        children: [
          Container(
            height: 80,
            child: Container(
              padding: EdgeInsets.only(top:5,bottom: 0,left: 20,right: 20),
              child: Row(
                children: [
                  icon,
                  SizedBox(width: defaultSize * 2,),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: defaultSize * 1.8//16
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: defaultSize * 1.6,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}