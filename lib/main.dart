import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: Text('Выбор города'),
            ),
            body: FirstScreen(),
        )
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _controller = TextEditingController();
  String _city = '';
   void _navigateToSecondScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(city: _city,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onSubmitted: (value) {
                _navigateToSecondScreen(context);
            },
            decoration: InputDecoration(
              labelText: 'Введите название города',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _city = value;
              });
            },
          ),
          SizedBox(height: 20),
          Text('Вы ввели: $_city'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                ElevatedButton.icon(
                    onPressed: () {
                      _navigateToSecondScreen(context);
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text(''),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
    final String city;
    SecondScreen({required this.city});
    @override
    State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
    void _navigateToThirdScreen(BuildContext context) {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ThirdScreen(city: widget.city,)),
        );
    }
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
                Text(widget.city),
                ElevatedButton.icon(
                    onPressed: () {
                      _navigateToThirdScreen(context);
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text(''),
                ),
            ],
        ),
      );
    }
}

class ThirdScreen extends StatefulWidget {
    final String city;
    ThirdScreen({required this.city});
    @override
    State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [Text('')],
        )
      );
    }
}