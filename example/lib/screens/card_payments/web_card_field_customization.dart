import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class WebCardFieldCustomizationExample extends StatefulWidget {
  const WebCardFieldCustomizationExample({super.key});

  @override
  State<WebCardFieldCustomizationExample> createState() => _WebCardFieldCustomizationExampleState();
}

class _WebCardFieldCustomizationExampleState extends State<WebCardFieldCustomizationExample> {
  late String _fontFamily = 'Montserrat';
  late String _cssSrc = 'https://fonts.googleapis.com/css?family=Montserrat';

  late final _fontFamilyController = TextEditingController(text: _fontFamily);
  late final _cssSrcController = TextEditingController(text: _cssSrc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: 150,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: CardField(
              autofocus: true,
              enablePostalCode: true,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: _fontFamily,
                color: Color(0xFF272B2B),
              ),
              placeholderColor: Colors.blueGrey,
              onCardChanged: (_) {},
              webFonts: [
                WebFont(
                  family: _fontFamily,
                  cssSrc: _cssSrc,
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _fontFamilyController,
                  decoration: InputDecoration(
                    labelText: 'Font Family',
                  ),
                  onChanged: (value) => setState(() => _fontFamily = value),
                ),
                TextField(
                  controller: _cssSrcController,
                  decoration: InputDecoration(
                    labelText: 'CSS Source',
                  ),
                  onChanged: (value) => setState(() => _cssSrc = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
