import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  String location; // Tên địa điểm
  String? time; // Thời gian tại địa điểm đó
  String url; // Địa chỉ cho endpoint
  bool isDayTime = true;

  WorldTime({required this.location, required this.url});

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
      isDayTime = now.hour>6 && now.hour<18 ? true : false;
      time = DateFormat('HH:mm:ss').format(now);
    }
    catch(e){
      print('Caught error: $e');
    }
  }
}
