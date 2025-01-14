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
  List<String> week_info = [];
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
    final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${api_key}'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weather_info = 'Температура: ${(data['main']['temp']-273.15).round()}°C\n'
                      'Ощущается как ${(data['main']['feels_like']-273.15).round()}°C\n'
                      'Атмосферное давление ${data['main']['pressure']} гПа\n'
                      'Влажность: ${data['main']['humidity']}%\n'
                      'Скорость ветра: ${data['wind']['speed']} м/с';
      });
      _fetchWeeklyWeather();
    } else {
      setState(() {
        weather_info = 'Ошибка: ${response.statusCode} - ${response.reasonPhrase}';
      });
    }
  }

  Future<void> _fetchWeeklyWeather() async {
    final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=${latitude}&lon=${longitude}&appid=${api_key}'));
    
    if (response.statusCode == 200) {
      final data1 = json.decode(response.body);
      print(data1);
      setState(() {
        week_info = [
          (data1['list'][0]['main']['temp_min']-273.15).round().toString(), (data1['list'][0]['main']['temp_max']-273.15).round().toString(), data1['list'][0]['wind']['speed'].toString(), data1['list'][0]['main']['humidity'].toString(), data1['list'][0]['main']['pressure'].toString(),
          (data1['list'][1]['main']['temp_min']-273.15).round().toString(), (data1['list'][1]['main']['temp_max']-273.15).round().toString(), data1['list'][1]['wind']['speed'].toString(), data1['list'][1]['main']['humidity'].toString(), data1['list'][1]['main']['pressure'].toString()
        ];
      });
    } else {
      setState(() {
        week_info = ['Ошибка: ${response.statusCode} - ${response.reasonPhrase}', '', '', '', '', '', '', '', ''];
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
    return Scaffold(
      appBar: AppBar (
        title: Text("Данные о погоде в городе ${widget.city}"),
        actions: [
          IconButton(
            onPressed: () {
              _navigateToThirdScreen(context);
            },
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              weather_info,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      )
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String day;
  final String temperature;
  final String windSpeed;
  final String humidity;
  final String pressure;
  
  WeatherCard({
    required this.day,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth * 0.9;
    final cardHeight = screenHeight * 0.3;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: cardHeight * 0.08,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: cardHeight * 0.02),
            Text(
              temperature,
              style: TextStyle(
                fontSize: cardHeight * 0.10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: cardHeight * 0.02),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ветер: $windSpeed',
                  style: TextStyle(fontSize: cardHeight * 0.07, color: theme.colorScheme.onSurface),
                ),
                Text(
                  'Влажность: $humidity',
                  style: TextStyle(fontSize: cardHeight * 0.07, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            Text(
              'Давление: $pressure',
              style: TextStyle(fontSize: cardHeight * 0.07, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}


class ThirdScreen extends StatefulWidget {
  final String city;
  final List<String> info;

  ThirdScreen({required this.city, required this.info});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Погода на 2 дня в городе ${widget.city}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isWideScreen ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WeatherCard(
              day: 'Завтра',
              temperature: 'от ${widget.info[0]}°C до ${widget.info[1]}°C',
              windSpeed: '${widget.info[2]} м/с',
              humidity: '${widget.info[3]}%',
              pressure: '${widget.info[4]} гПа',
            ),
            WeatherCard(
              day: 'Послезавтра',
              temperature: 'от ${widget.info[5]}°C до ${widget.info[6]}°C',
              windSpeed: '${widget.info[7]} м/с',
              humidity: '${widget.info[8]}%',
              pressure: '${widget.info[9]} гПа',
            ),
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherCard(
              day: 'Завтра',
              temperature: 'от ${widget.info[0]}°C до ${widget.info[1]}°C',
              windSpeed: '${widget.info[2]} м/с',
              humidity: '${widget.info[3]}%',
              pressure: '${widget.info[4]} гПа',
            ),
            SizedBox(height: 16.0),
            WeatherCard(
              day: 'Послезавтра',
              temperature: 'от ${widget.info[5]}°C до ${widget.info[6]}°C',
              windSpeed: '${widget.info[7]} м/с',
              humidity: '${widget.info[8]}%',
              pressure: '${widget.info[9]} гПа',
            ),
          ],
        ),
      ),
    );
  }
}