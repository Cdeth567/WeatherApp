import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    String weather_info = '';
    String week_info = '';
    double longitude = -94.04;
    double latitude = 33.44;
    String api_key = 'b5422874d4779ee24c0f0be04b165d73';
    @override
    void initState() {
      super.initState();
      _fetchCoordinates();
    }
    Future<void> _fetchCoordinates() async {
        final response = await http.get(Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=${widget.city}&limit=1&appid=${api_key}'));
        if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
                longitude = data[0]["lon"];
                latitude = data[0]['lat'];
            });
            _fetchWeather();
        }
        else {
            setState(() {
                weather_info = 'Не удалось найти город';
            });
        }
    }

    Future<void> _fetchWeather() async {
      final response = await http.get(Uri.parse('https://api.openweathermap.org/data/3.0/onecall?lat=${latitude}&lon=${longitude}&units=metric&exclude=minutely,hourly,alerts&appid=${api_key}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weather_info = 'Температура: ${data['current.temp']}°C\n'
                        'Ощущается как ${data['current.feels_like']}°C\n'
                        'Атмосферное давление ${data['current.pressure']} гПа'
                       'Влажность: ${data['current.humidity']}%\n'
                       'Скорость ветра: ${data['current.wind_speed']*0.44704} м/с';
          week_info = '';
        });
      } else {
        setState(() {
          print('Ошибка: ${response.statusCode} - ${response.reasonPhrase}');
          weather_info = 'Не удалось получить данные о погоде';
          week_info = 'Не удалось получить данные о погоде';
        });
      }
    }

    void _navigateToThirdScreen(BuildContext context) {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ThirdScreen(city: widget.city, info: week_info)),
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
                SizedBox(height: 20),
                Text(weather_info)
            ],
        ),
      );
    }
}

class ThirdScreen extends StatefulWidget {
    final String city;
    final String info;
    ThirdScreen({required this.city, required this.info});
    @override
    State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
 
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [Text(widget.info)],
        )
      );
    }
}
