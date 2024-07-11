import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:just_run/manager/fonts.dart';
import 'package:just_run/manager/locale_provider.dart';
import 'package:just_run/services/data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final DataService _dataService = DataService();

  User? _currentUser;
  Map<String, dynamic>? _currentUserData;
  String currentUserAge = '', currentUserHeight = '', currentUserWeight = '';
  bool isConnected = true;
  StreamSubscription ? _internetConnection;

  final List<String> languageItems = [
    'English',
    'Tiếng Việt',
  ];

  @override
  void initState() {
    super.initState();
    _internetCheck();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _internetConnection?.cancel();
    super.dispose();
  }

  void _internetCheck() {
    _internetConnection = InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnected = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnected = false;
          });
          break;
        default:
          setState(() {
            isConnected = false;
          });
          break;
      }
    });
  }

  void _showInternetStatus(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.internetStatus),
      ),
    );
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUser != null) {
        var userData = await _dataService.loadUserData(context, _currentUser!.uid);
        setState(() {
          _currentUserData = userData;
          currentUserWeight = userData?['weight']?.toString() ?? 'no data';
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LocaleProvider localeProvider = Provider.of<LocaleProvider>(context);
    String currentLanguage = localeProvider.locale?.languageCode == 'en' ? 'English' : 'Tiếng Việt';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.settingCardTitle,
            style: TextStyle(color: Colors.black, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.redAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/default.png'),
                        foregroundImage: NetworkImage(_currentUser!.photoURL!),
                        radius: 45,
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 35),
                        Text(
                          _currentUser?.displayName ?? AppLocalizations.of(context)!.offlineModeTitle,
                          style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentUser?.email ?? AppLocalizations.of(context)!.offlineModeTitle,
                          style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: Fonts.display_font),
                        ),
                      ],
                    ),
                  ]
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildInformationCard(AppLocalizations.of(context)!.ageTitle, () {
              _changeInformation(currentUserAge);
            }),
            _buildInformationCard(AppLocalizations.of(context)!.heightTitle, () {
              _changeInformation(currentUserHeight);
            }),
            _buildInformationCard(AppLocalizations.of(context)!.weightTitle, () {
              _changeInformation(currentUserWeight);
            }),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(40, 0, 27, 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLocalizations.of(context)!.languageTitle, style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: Fonts.display_font))
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: DropdownButtonFormField2<String>(
                value: currentLanguage,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: languageItems.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                  ),
                )).toList(),
                onChanged: (value) {
                  if (value == 'English') {
                    localeProvider.setLocale(Locale('en'));
                  } else if (value == 'Tiếng Việt') {
                    localeProvider.setLocale(Locale('vi'));
                  }
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.only(right: 8),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  iconSize: 30,
                ),
                dropdownStyleData: DropdownStyleData(
                  offset: Offset(0, -5),
                  elevation: 0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(String title, VoidCallback onTap) {
    String currentValue = '';
    if (_currentUserData != null) {
      if (title == AppLocalizations.of(context)!.ageTitle) {
        currentValue = _currentUserData!['age']?.toString() ?? 'no data';
      } else if (title == AppLocalizations.of(context)!.heightTitle) {
        currentValue = _currentUserData!['height']?.toString() ?? 'no data';
      } else if (title == AppLocalizations.of(context)!.weightTitle) {
        currentValue = _currentUserData!['weight']?.toString() ?? 'no data';
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50.0,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        margin: EdgeInsets.symmetric(vertical: 2.0),
        child: Card(
          color: Colors.grey[300],
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentValue,
                  style: TextStyle(fontFamily: Fonts.display_font, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeInformation(String field) {
    isConnected ? showDialog(
      context: context,
      builder: (BuildContext context) {
        String? ageValue = _currentUserData?['age']?.toString() ?? '';
        String? heightValue = _currentUserData?['height']?.toString() ?? '';
        String? weightValue = _currentUserData?['weight']?.toString() ?? '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.changeInformationTitle,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey[850],
              fontFamily: Fonts.display_font,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: ageValue),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  ageValue = value;
                },
                decoration: InputDecoration(labelText: 'Age', labelStyle: TextStyle(fontFamily: Fonts.display_font)),
              ),
              TextField(
                controller: TextEditingController(text: heightValue),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  heightValue = value;
                },
                decoration: InputDecoration(labelText: 'Height (cm)', labelStyle: TextStyle(fontFamily: Fonts.display_font)),
              ),
              TextField(
                controller: TextEditingController(text: weightValue),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  weightValue = value;
                },
                decoration: InputDecoration(labelText: 'Weight (kg)', labelStyle: TextStyle(fontFamily: Fonts.display_font)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.cancelButton,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey[850],
                  fontFamily: Fonts.display_font,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Update user data
                if (_currentUser != null) {
                  await _dataService.saveUserData(
                    context, _currentUser!.uid,
                    int.tryParse(ageValue ?? '0') ?? 0,
                    double.tryParse(heightValue ?? '0.0') ?? 0.0,
                    double.tryParse(weightValue ?? '0.0') ?? 0.0,
                  );
                  _loadUserData();
                }
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.okButton,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[850],
                  fontFamily: Fonts.display_font,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) : _showInternetStatus(context);
  }

}
