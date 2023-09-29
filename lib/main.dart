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
      debugShowCheckedModeBanner: false,
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
  String _gifResult = "";
  final Position _locationAxxes = const Position(
      latitude: 51.22903628943096,
      longitude: 4.412060064669845,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);
  final Position _locationMallorca = const Position(
      latitude: 39.6553963967368,
      longitude: 2.930623088750286,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);
  final Position _locationMadagascar = const Position(
      latitude: -20.06729548400306,
      longitude: 46.88297593721642,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<void> _getCurrentPositionAxxes() async {
    await setAudio(WALK);
    audioPlayer.resume();
    return _getCurrentPosition(_locationAxxes);
  }

  Future<void> _getCurrentPositionMallorca() async {
    await setAudio(FIVEHUNDRED);
    audioPlayer.resume();
    return _getCurrentPosition(_locationMallorca);
  }

  Future<void> _getCurrentPositionMadagascar() async {
    await setAudio(FIVEHUNDRED_MORE);
    audioPlayer.resume();
    return _getCurrentPosition(_locationMadagascar);
  }

   _refresh() {
    _gifResult = "";
    setState(() => _currentPosition = null);
  }

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  final String WALK = "walk.mp3";
  final String FIVEHUNDRED = "500.mp3";
  final String FIVEHUNDRED_MORE = "500more.mp3";

  @override
  void initState() {
    super.initState();

    audioPlayer.setVolume(100.0);
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_){
      getCurrenLocation();
    });
  }

  Future setAudio(String fileName) async {
    audioPlayer.setSource(AssetSource(fileName));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> getCurrenLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position currentPosition) {
      //setState(() => );
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getCurrentPosition(Position position) async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position currentPosition) {
      _distanceKm = Geolocator.distanceBetween(currentPosition.latitude,
          currentPosition.longitude, position.latitude, position.longitude);
      _distanceKm = _distanceKm / 1000;
      _distanceMiles = 0.621371192 * _distanceKm;
      if (_distanceMiles < 500) {
        _gifResult = "iwouldwalk";
      } else if (_distanceMiles < 1000) {
        _gifResult = "iwouldwalk500miles";
      } else {
        _gifResult = "iwouldwalk500milesandmore";
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
          content: Text(
              'Location services are disabled. Please enable the services')));
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
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How far do I need to walk?"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _gifResult != "" ?
                Image.asset(
                  "assets/$_gifResult.gif",
                  height: 350.0,
                  width: 350.0,
                ) :
                const SizedBox(height: 350),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _getCurrentPositionAxxes,
                child: const Text("Axxes kantoor"),
              ),
              ElevatedButton(
                onPressed: _getCurrentPositionMallorca,
                child: const Text("Mallorca"),
              ),
              ElevatedButton(
                  onPressed: _getCurrentPositionMadagascar,
                  child: const Text("Madagascar"))
            ],
          ),
        ),
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _refresh,
      ),
    );
  }
}
