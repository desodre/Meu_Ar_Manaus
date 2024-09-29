import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:meu_ar_mao/data/air_quality.dart';
import 'package:meu_ar_mao/data/api_key.dart';
import 'package:http/http.dart' as http;

Future<AirQuality?> fetchData() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Localização está desativado!');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('A localização foi negada!');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Localização foi negada permanentemente!');
    }

    Position position = await Geolocator.getCurrentPosition();

    var url = Uri.parse(
        'https://api.waqi.info/feed/geo:${position.latitude};${position.longitude}/?token=$API_KEY');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      AirQuality airQuality = AirQuality.fromjson(jsonDecode(response.body));

      if (airQuality.aqi >= 0 && airQuality.aqi <= 50) {
        airQuality.menssage =
            "A qualidade do ar é considerada satisfatória e a poluição atmosférica representa pouco ou nenhum risco";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      } else if (airQuality.aqi >= 51 && airQuality.aqi <= 100) {
        airQuality.menssage =
            "A qualidade do ar é aceitável; no entanto, para alguns poluentes, pode haver um problema moderado de saúde para um número muito pequeno de pessoas que são anormalmente sensíveis à poluição do ar.";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      } else if (airQuality.aqi >= 101 && airQuality.aqi <= 150) {
        airQuality.menssage =
            "Membros de grupos sensíveis podem sofrer efeitos na saúde. O público em geral provavelmente não será afetado.";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      } else if (airQuality.aqi >= 151 && airQuality.aqi <= 200) {
        airQuality.menssage =
            "Todos podem começar a sentir efeitos na saúde; membros de grupos sensíveis podem sentir efeitos mais graves na saúde";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      } else if (airQuality.aqi >= 201 && airQuality.aqi < 300) {
        airQuality.menssage =
            "Todos podem começar a sentir efeitos na saúde; membros de grupos sensíveis podem sentir efeitos mais graves na saúde";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      } else if (airQuality.aqi >= 300) {
        airQuality.menssage =
            "Alerta de saúde: todos podem sofrer efeitos mais graves na saúde";
        airQuality.emojiRef = ''; //add futuramente um asset de emojis
      }
      print(airQuality);
      return airQuality;
    }
    return null;
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}
