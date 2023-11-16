import "package:flutter/material.dart";
import 'package:flutter/material.dart';
import 'package:odd_job_app/pages/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _jobDeadlineDateController = TextEditingController();
  final _jobDeadLineTimeController = TextEditingController();
  final _jobStartingBidController = TextEditingController();

  late Timestamp jobTime;
  String enterYourAddressHere = 'Enter your address here';
  DateTime? _selectedDate = DateTime.now();

  //9999999999
  late LatLng location;
  late String address = '';

  void upDateLocation(String chosenAddress, LatLng coordinates) {
    location = coordinates;
    address = chosenAddress;
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _jobDeadlineDateController.dispose();
    _jobDeadLineTimeController.dispose();
    _jobStartingBidController.dispose();

    super.dispose();
  }

  // Post job to database
  Future postJob() async {
    GeoPoint g = GeoPoint(location.latitude, location.longitude);
    addJobDetails(
      _jobTitleController.text.trim(),
      _jobDescriptionController.text.trim(),
      _selectedDate!,
      _jobStartingBidController.text.trim(),
      g,
      address,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const JobPostedSuccessfullyPage(),
      )
    );
  }

  // Add job details to database
  Future addJobDetails(String title, String description, DateTime date,
      String bid, GeoPoint coords, String address) async {
    CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');
    return jobs
        .add({
          'title': title,
          'description': description,
          'deadline': date,
          'address': address,
          'longlat': coords,
          'startingBid': bid,
        })
        .then((value) => print("Job posted"))
        .catchError((error) => print("Failed to post job: $error"));
  }

  // Select date deadline
  Future<void> _selectDeadLineDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime twoMonthsFuture =
        currentDate.add(const Duration(days: 60)); // 60 days in the future

    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: currentDate, // Set initialDate to today
      firstDate: currentDate, // Set firstDate to today
      lastDate: twoMonthsFuture, // Set lastDate to 2 months in the future
    );

    // ignore: use_build_context_synchronously
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: DateTime.now().hour, minute: DateTime.now().minute));

    if (pickedDay == null) {
      //throw error message on screen
    }

    if (pickedTime == null) {
      //throw error message on screen
    }

    final DateTime picked = DateTime(
      pickedDay!.year,
      pickedDay.month,
      pickedDay.day,
      pickedTime!.hour,
      pickedTime.minute,
    );

    if (picked != null && picked != _selectedDate) {
      jobTime = Timestamp.fromDate(picked);
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  late final PanelController _panelController = PanelController();

  void _openSlidingPanel() {
    _panelController.open();
  }

  void handleVariableChange(LatLng newLocation, String newAddress) {
    location = newLocation;
    address = newAddress;
    enterYourAddressHere = address;
    setState(() {
      enterYourAddressHere;
    });
    _panelController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
     appBar: AppBar(
              title: const Text('Post a Job',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        defaultPanelState: PanelState.CLOSED,
        maxHeight: MediaQuery.of(context).size.height - 100,
        minHeight: 0,
        controller: _panelController,
        panel: SearchLocationScreen(onVariableChanged: handleVariableChange),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Column(children: [
                          TextFormField(
                            controller: _jobTitleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter job title',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                              controller: _jobDescriptionController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter job description',
                              ),
                              maxLines: 11),
                          const SizedBox(height: 16),
                          // Row(
                          //   children: [
                          //     const Text('Add Tags'),
                          //     const SizedBox(
                          //         width:
                          //             16), // Add spacing between the text and the TextFormField
                          //     Expanded(
                          //       child: TextFormField(
                          //         controller: _jobDescriptionController,
                          //         decoration: const InputDecoration(
                          //           border: OutlineInputBorder(),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              _openSlidingPanel();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0x00ffffff)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons
                                      .location_on, // Use the appropriate address icon
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    enterYourAddressHere,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons
                                      .arrow_forward, // Use the appropriate arrow icon
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      'Deadline Date:',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      _selectedDate != null
                                          ? '${_selectedDate!.toLocal().month}-${_selectedDate!.toLocal().day}-${_selectedDate!.year}'
                                          : 'Select a date',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        await _selectDeadLineDate(context);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Starting Bid'),
                              const SizedBox(
                                  width:
                                      16), // Add spacing between the text and the TextFormField
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _jobStartingBidController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter a Number',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: postJob,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 51, 154, 214)),
                            ),
                            child: const Text('Post Job'),
                          )
                        ]);
                      })),
            ],
          ),
        ),
      ),
    );
  }
}


class JobPostedSuccessfullyPage extends StatelessWidget {
  const JobPostedSuccessfullyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post a Job',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Check Mark
            AnimatedCheckMark(),

            // Success Message
            SizedBox(height: 16),
            Text(
              'Your job has been successfully posted!',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCheckMark extends StatefulWidget {
  const AnimatedCheckMark({super.key});

  @override
  _AnimatedCheckMarkState createState() => _AnimatedCheckMarkState();
}

class _AnimatedCheckMarkState extends State<AnimatedCheckMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Opacity Animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
