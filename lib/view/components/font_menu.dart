import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showFontMenu(BuildContext context, Function(String?) onSelected) {
  showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
    items: [
      PopupMenuItem<String>(
        value: 'Inter',
        child: Text('inter'.tr, style: TextStyle(fontFamily: 'Inter')),
      ),
      PopupMenuItem<String>(
        value: 'Lobster',
        child: Text('lobster'.tr, style: TextStyle(fontFamily: 'Lobster')),
      ),
      PopupMenuItem<String>(
        value: 'Pacifico',
        child: Text('pacifico'.tr, style: TextStyle(fontFamily: 'Pacifico')),
      ),
      PopupMenuItem<String>(
        value: 'PlayfairDisplay',
        child: Text('playfair_display'.tr,
            style: TextStyle(fontFamily: 'PlayfairDisplay')),
      ),
      PopupMenuItem<String>(
        enabled: false,
        child: Divider(),
      ),
      PopupMenuItem<String>(
        value: 'Bold',
        child: Text('bold'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      PopupMenuItem<String>(
        value: 'Underline',
        child: Text('underline'.tr,
            style: TextStyle(decoration: TextDecoration.underline)),
      ),
      PopupMenuItem<String>(
        value: 'Italic',
        child: Text('italic'.tr, style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      PopupMenuItem<String>(
        enabled: false,
        child: Divider(),
      ),
      PopupMenuItem<String>(
        value: 'Back to normal',
        child: Text('back_to_normal'.tr,
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal)),
      ),
    ],
  ).then((value) {
    onSelected(value);
  });
}
