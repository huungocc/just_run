import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  String location;
  String? time;
  String url;
  bool isDayTime = true;

  WorldTime({required this.location, required this.url});

  static Future<List<WorldTime>> getLocation() async {
    try {
      // Gửi yêu cầu API để lấy danh sách các thành phố
      Response response = await get(
          Uri.parse('http://worldtimeapi.org/api/timezone'));

      // Parse dữ liệu trả về
      List<dynamic> data = jsonDecode(response.body);

      // Tạo danh sách WorldTime từ dữ liệu nhận được
      List<WorldTime> locations = [];
      for (var timezone in data) {
        // Lấy tên thành phố từ URL, loai bo ki tu _ thay bang dau cach
        String location = timezone.split('/').last.replaceAll('_', ' ');
        locations.add(WorldTime(location: location, url: timezone));
      }
      return locations;
    }
    catch(e){
      print('Lỗi xảy ra: $e');
      return [];
    }
  }

  Future<void> getTime() async {
    try {
      // Gửi yêu cầu API
      Response response = await get(
          Uri.parse('http://worldtimeapi.org/api/timezone/$url'));
      Map data = jsonDecode(response.body);

      // Lấy dữ liệu
      String datetime = data['datetime'];
      String offset = data['utc_offset'].substring(1, 3);

      // Tạo đối tượng DateTime
      DateTime now = DateTime.parse(datetime);
      now = now.add(Duration(hours: int.parse(offset)));

      // Gán giá trị cho time
      isDayTime = now.hour>=6 && now.hour<=18 ? true : false;
      time = DateFormat('HH:mm:ss').format(now);
    }
    catch(e){
      print('Caught error: $e');
    }
  }
}
