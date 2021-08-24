import 'dart:convert';

import 'package:http/http.dart';

class NaverApi {
  static Future getNaverData(long, lati) async {
    List sigu = await _getsigu(long, lati);
    await _loadSettings();
    return sigu;
  }

  static _getsigu(long, lati) async {
    List gusilist = [];
    Map<String, String> test = {
      "X-NCP-APIGW-API-KEY-ID": "n9hamqjko2",
      "X-NCP-APIGW-API-KEY": "H0oYKsp8RuG0tn63J3geayID1VrBDVeeXuchqMSa"
    };
    var uri =
        "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=${long},${lati}&sourcecrs=epsg:4326&output=json";
    Response response = await get(Uri.parse(uri), headers: test);
    String jsonData = response.body;
    var myJson_gu =
        jsonDecode(jsonData)['results'][1]['region']['area2']['name'];
    var myJson_si =
        jsonDecode(jsonData)['results'][1]['region']['area1']['name'];
    gusilist.add(myJson_si);
    gusilist.add(myJson_gu);

    return gusilist;
  }

  static _loadSettings() async {
    print("world");
  }
}
