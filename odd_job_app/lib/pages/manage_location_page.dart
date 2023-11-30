import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:odd_job_app/location/get_location.dart';
import 'package:odd_job_app/location/change_settings.dart';
import 'package:odd_job_app/location/listen_location.dart';
import 'package:odd_job_app/location/service_enabled.dart';
import 'package:odd_job_app/location/permission_status.dart';
import 'package:odd_job_app/location/change_notification.dart';
import 'package:odd_job_app/location/enable_in_background.dart';


class ManageLocationInfoPage extends StatefulWidget {
  const ManageLocationInfoPage({super.key, this.title});
  final String? title;

  @override
  _ManageLocationInfoPageState createState() => _ManageLocationInfoPageState();
}

class _ManageLocationInfoPageState extends State<ManageLocationInfoPage> {
  final Location location = Location();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
         backgroundColor: Colors.black,
        title: const Text("Manage Location Info"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
       
          child: const Column(

            children: [
              PermissionStatusWidget(),
              Divider(height: 32),
              ServiceEnabledWidget(),
              Divider(height: 32),
              GetLocationWidget(),
              Divider(height: 32),
              ListenLocationWidget(),
              Divider(height: 32),
              ChangeSettings(),
              Divider(height: 32),
              EnableInBackgroundWidget(),
              Divider(height: 32),
              ChangeNotificationWidget()
            ],
          ),
        ),
      ),
    );
  }
}