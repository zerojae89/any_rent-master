import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';

class MypageProfileMenuItem extends StatelessWidget{
  const MypageProfileMenuItem({
    Key key,
    this.icon,
    this.title,
    this.contents,
    this.horizontal,
    this.vertical
  }) : super(key: key);
  final Icon icon;
  final String title, contents;
  final int horizontal;
  final int vertical;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultSize * horizontal, vertical: 0),
            child: Row(
              children: [
                icon,
                SizedBox(width: defaultSize * 2,),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: defaultSize * 1.8,fontWeight: FontWeight.bold //16
                  ),
                ),
                Spacer(),
                Text(
                  (contents ?? ''),
                  style: TextStyle(
                    fontSize: defaultSize * 1.5, //16
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider()
      ],
    );
  }
}