import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  String sehir = '';
  var sicaklik;
  var responseWeather;
  var response;
  var woeid;
  List temps = List(5);
  List abbr = List(5);
  List day = List(5);
  Position position;

  String weatherShort = 'back';

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print('hata');
    }
  }

  Future<void> getLocationData() async {
    response = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParser = jsonDecode(response.body);
    woeid = locationDataParser[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    response = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}');
    var locationDataParser = jsonDecode(response.body);
    woeid = locationDataParser[0]['woeid'];
    sehir = locationDataParser[0]['title'];
  }

  Future<void> getLocationWeatherData() async {
    responseWeather = await http
        .get('https://www.metaweather.com/api/location/location/$woeid/');
    var weatherDataParsed = jsonDecode(utf8.decode(responseWeather.bodyBytes));

    setState(() {
      sicaklik =
          weatherDataParsed["consolidated_weather"][0]['the_temp'].round();

      for (int i = 0; i < temps.length; i++) {
        temps[i] = weatherDataParsed["consolidated_weather"][i + 1]['the_temp']
            .round();
      }

      weatherShort =
          weatherDataParsed['consolidated_weather'][0]['weather_state_abbr'];
      for (int i = 0; i < abbr.length; i++) {
        abbr[i] = weatherDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
      }
      for (int i = 0; i < day.length; i++) {
        day[i] =
            weatherDataParsed['consolidated_weather'][i + 1]['applicable_date'];
      }
    });
  }

  Future<void> asenkronYapici() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    getLocationWeatherData();
  }

  Future<void> asenkronYapiciArama() async {
    await getLocationData();
    getLocationWeatherData();
  }

  void initState() {
    asenkronYapici();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/$weatherShort.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: sicaklik == null
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red[400],
                strokeWidth: 3,
              ),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$weatherShort.png'),
                    ),
                    Text(
                      '$sicaklik° C',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        fontSize: 60,
                        color: Colors.black,
                        shadows: <Shadow>[
                          Shadow(
                              color: Colors.white,
                              blurRadius: 6,
                              offset: Offset(-1, 1))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          sehir,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            shadows: <Shadow>[
                              Shadow(
                                  color: Colors.white,
                                  blurRadius: 6,
                                  offset: Offset(-1, 1))
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));

                            asenkronYapiciArama();
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    buildWeatherContainer(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildWeatherContainer(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView.builder(
        itemCount: temps.length,
        itemBuilder: (BuildContext context, int position) {
          return DailyWeather(
            image: abbr[position],
            date: day[position].toString(),
            temp: temps[position].toString(),
          );
        },
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather({Key key, @required this.image, this.temp, this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text('$temp°C'),
            Text('$date')
          ],
        ),
      ),
    );
  }
}
