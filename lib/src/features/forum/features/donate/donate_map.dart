import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DonationScreen extends StatefulWidget {
   const DonationScreen({super.key});
  @override
  State<DonationScreen> createState() => _DonationScreenState();
}


class _DonationScreenState extends State<DonationScreen> {
  final locationController=Location();

  static const Donation_Center_1 = LatLng(30.2690, 77.9916);
  static const Donation_Center_2 = LatLng(22.6708,  71.5724);
  static const Support_Outreach_Point_1 = LatLng(30.2892, 77.9987);
  static const Support_Outreach_Point_2 = LatLng(30.2915, 78.0543);
  BitmapDescriptor? donationCenterIcon;
  BitmapDescriptor? userIcon;
  BitmapDescriptor? supportOutreachIcon;
  

LatLng? currentPosition;
Map <PolylineId, Polyline> polylines={};


  @override
  void initState() {
    loadIcons(); 
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkLocationStatus();
        await initializeMap(); // Call initializeMap after checking location status
    });
  }
  
  Future <void> initializeMap() async {
    await fetchlocationUpdates();
    final coordinates= await fetchPolylinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  @override
   // ignore: prefer_const_constructors
   Widget build(BuildContext context)=> Scaffold(
      body:currentPosition == null
      ?const Center(child: CircularProgressIndicator())
      : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition?? Donation_Center_1,
          zoom: 17,
        ),
        markers: {
          Marker(
              markerId: MarkerId('user'),
              icon :userIcon ?? BitmapDescriptor.defaultMarker,
              position: currentPosition!,
          ),
          Marker(
            markerId: MarkerId('Donation_Center_1'),
            icon :donationCenterIcon ?? BitmapDescriptor.defaultMarker,
            position: Donation_Center_1,
            infoWindow: InfoWindow(
                      title: 'Children of India Donation Collection Center',
                      snippet: 'Near Graphic era, Clement town,Dehradun Ph no - 1234567890'
                    ),
          ),
           Marker(
              markerId: MarkerId('Donation Point 2'),
              icon: donationCenterIcon ?? BitmapDescriptor.defaultMarker,
              position: Donation_Center_2,
              infoWindow: InfoWindow(
                        title: 'Poverty Fund Donation Collection Center',
                        snippet:
                            'Gujrat - 1234567890'),
            ),
            Marker(
                    markerId: MarkerId('Support_Outreach_Point_1'),
                    icon: supportOutreachIcon ?? BitmapDescriptor.defaultMarker,
                    position: Support_Outreach_Point_1,
                    infoWindow: InfoWindow(
                        title: '[Support Outreach] ISBT Dehradun',
                        snippet:
                            'Donate your old clothes, toys, books or provide food to the needy'
                  ),
            ),
            Marker(
                    markerId: MarkerId('Support_Outreach_Point_2'),
                    icon: supportOutreachIcon ?? BitmapDescriptor.defaultMarker,
                    position: Support_Outreach_Point_2,
                    infoWindow: InfoWindow(
                        title: '[Support Outreach] Rispana Dehradun',
                        snippet:
                            'Donate your old clothes, toys, books or provide food to the needy'
                            ),
                  ),
          },
          polylines:Set<Polyline>.of(polylines.values),
      ),
   );
Future<void> loadIcons() async {
    donationCenterIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/Donation_center.png',
    );
    userIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/userLocation.png',
    );
    supportOutreachIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/support_Outreach.png',
    );
  }
  Future<void> checkLocationStatus() async {
    bool serviceEnabled;
    Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Show dialog or snackbar to prompt the user to enable GPS
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Enable Location'),
            content: Text('Please enable location services to Find donation centers and support outreach points near you.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  location.requestService();
                },
                child: Text('Enable Location and Find'),
              ),
            ],
          ),
        );
      }
    }
  }

Future<void> fetchlocationUpdates () async {
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  serviceEnabled = await locationController.serviceEnabled();
  if(serviceEnabled){
    serviceEnabled= await locationController.requestService();
  }
  else {
    return;
  }

  permissionGranted = await locationController.hasPermission();
  if(permissionGranted==PermissionStatus.denied){
    permissionGranted=await locationController.requestPermission();
    if(permissionGranted!=PermissionStatus.granted){
      return;
    }
  }

  locationController.onLocationChanged.listen((currentLocation){
    if(currentLocation.latitude!=null &&
          currentLocation.longitude!=null){
            setState(() {
              currentPosition=LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
            });
          }
  });
}

Future<List<LatLng>> fetchPolylinePoints() async {
  final polylinePoints=PolylinePoints();
  const googleMapsApiKey="AIzaSyCaWReheCbeGeRxq8tNnuLuTmJQ3r7VGxU";
  final result = await polylinePoints.getRouteBetweenCoordinates(
    googleMapsApiKey,
    PointLatLng(currentPosition!.latitude,currentPosition!.longitude) ,
     PointLatLng(Donation_Center_1.latitude, Donation_Center_1.longitude)
    );
    if(result.points.isNotEmpty){
      return result.points
      .map((point)=> LatLng(point.latitude, point.longitude))
      .toList();
    }
    else {
      debugPrint(result.errorMessage);
      return [];
    }
}

Future<void> generatePolyLineFromPoints( 
  List<LatLng> polylineCoordinates) async{
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId:id,
      color: Colors.blue,
      points:polylineCoordinates,
      width: 3,
    );
  setState(()=> polylines[id]=polyline);

  }
}

  
  
