import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';

class PermissionMenuItem extends StatelessWidget{
  const PermissionMenuItem({ Key key, this.icon, this.title, this.content }) : super(key: key);
  final Icon icon;
  final String title, content;

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Row(
      children: [
        icon,
        Text( title,  style: TextStyle( fontSize: defaultSize * 1.6, ), ),
        Text( content,  style: TextStyle( fontSize: defaultSize * 1.45, ), ),
      ],
    );
  }
}