import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '500 miles app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LocationPage(),
    );
  }
}

class LocationPage extends StatefulWidget {
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Position? _currentPosition;
  double _distanceKm = 0;
  double _distanceMiles = 0;
  String _textResult  = "";
  //Position goalLocation = Position(latitude: 51.22903628943096, longitude: 4.412060064669845, timestamp: null, accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  Position goalLocation = Position(longitude: 51.22903628943096, latitude: 4.412060064669845, timestamp: null, accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSource(AssetSource("music.mp3"));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
          _distanceKm = Geolocator.distanceBetween(position.latitude, position.longitude, goalLocation.latitude, goalLocation.longitude);
          _distanceKm = _distanceKm / 1000;
          _distanceMiles = 0.621371192 * _distanceKm;
          if(_distanceMiles < 500){
            _textResult = "I wouldn't walk 500 miles!";
          } else if(_distanceMiles < 1000){
            _textResult = "I would walk 500 miles!";
          } else {
            _textResult = "I would walk 500 miles,\nand I would walk 500 more!";
          }
          setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              //Text('KM: ${_distanceKm ?? ""}'),
              //Text('Miles: ${_distanceMiles ?? ""}'),
              Text('${_textResult ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _getCurrentPosition,
                child: const Text("Get Current Location"),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: CircleAvatar(
        radius: 30,
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause: Icons.play_arrow
          ),
          iconSize: 40,
          onPressed: () async {
            if (isPlaying) {
              await audioPlayer.pause();
            } else {
              await audioPlayer.resume();
            }
          },
        ),
      ),
    );
  }
}
