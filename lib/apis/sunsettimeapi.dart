import 'package:xml/xml.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class SunsetTimeApi {
  static Future getSunsetTimeData(long, lati) async {
    List sunset = await _getsunset(long, lati);
    await _loadSettings();
    return sunset;
  }

  static _getsunset(long, lati) async {
    List sunsetlist = [];
    String dateStr = DateFormat('yyyyMMdd').format(DateTime.now());

    Response response = await get(Uri.parse(
        'http://apis.data.go.kr/B090041/openapi/service/RiseSetInfoService/getLCRiseSetInfo?ServiceKey=cR1YY2ji2HzxD35o6BnH7GgH46ViNYaXmUFWJ%2FKKXc%2BMYcZNA51AWWyKOPorXp8pHJ6gBLiaXzJ809NDVwgNSg%3D%3D&locdate=${dateStr}&longitude=${long}&latitude=${lati}&dnYn=Y'));
    var xmlData = XmlDocument.parse(response.body);
    var parsingData =
        xmlData.findAllElements('sunset').toString().substring(9, 13);

    sunsetlist.add(parsingData);
    return sunsetlist;
  }

  static _loadSettings() async {
    print("world");
  }
}
