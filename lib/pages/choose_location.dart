import 'package:flutter/material.dart';
import 'package:ngocapp/services/world_time.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChooseLocation extends StatefulWidget {
  //khai bao bgColor
  final Color? bgColor;
  ChooseLocation({Key? key, this.bgColor}) : super(key: key);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  static List<WorldTime> locations = [];
  List<WorldTime> filteredLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (locations.isEmpty) {
      loadTimezones();
    } else {
      setState(() {
        filteredLocations = locations;
        isLoading = false;
      });
    }
  }

  void loadTimezones() async {
    setState(() {
      isLoading = true;
    });

    List<WorldTime> timezones = await WorldTime.getLocation();
    setState(() {
      locations = timezones;
      filteredLocations = timezones;
      isLoading = false;
    });
  }

  void updateTime(index) async {
    WorldTime instance = filteredLocations[index];
    await instance.getTime();
    Navigator.of(context).maybePop ({
      'location': instance.location,
      'time': instance.time,
      'isDayTime': instance.isDayTime
    });
  }

  void filterLocation(String query){
    List<WorldTime> filtered = locations.where((location){
      return location.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredLocations = filtered;
    });
  }

  Future <void> _refreshData() async {
    loadTimezones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        backgroundColor: widget.bgColor,
        title: Text('Choose a location', style: TextStyle(fontFamily: 'Anton')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                onChanged: (value){
                  filterLocation(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontFamily: 'Anton'),
                  //labelStyle: TextStyle(fontFamily: 'Anton'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //borderSide: BorderSide(color: Colors.white, width: 2)
                  ),
                ),
              ),
          ),
          Expanded(
            child: isLoading
            ? Center(
              child: SpinKitThreeBounce(
                color: Colors.black,
                size: 30,
              )
            )
            : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            updateTime(index);
                          },
                          title: Text(filteredLocations[index].location, style: TextStyle(fontFamily: 'Anton')),
                        ),
                      ),
                    );
                  },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
