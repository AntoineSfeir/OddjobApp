import "package:flutter/material.dart";
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:odd_job_app/jobs/address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore_for_file: library_private_types_in_public_api

class PostJobPage extends StatefulWidget {
  final user currentUser;
  const PostJobPage({super.key, required this.currentUser});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final db = FirebaseFirestore.instance;
  List<user> users = [];
  late String displayName;
  late String userID;
  late int totalPostedJobs = widget.currentUser.jobsPosted;

  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _jobDeadlineDateController = TextEditingController();
  final _jobDeadLineTimeController = TextEditingController();
  final _jobStartingBidController = TextEditingController();

  late Timestamp jobTime;
  String enterYourAddressHere = 'Address';
  DateTime? _selectedDate = DateTime.now();

  //9999999999
  late LatLng location;
  late String address = '';

  List<Job> firstList = [];
  List<Job> secondList = [];
  late String jobID;

  final List<String> possibleJobs = [
    'Lawn Care',
    'Power Washing',
    'House Cleaning',
    'Baby Sitting',
    'Car Washing',
    'House Painting',
    'Tutoring',
    'Moving Assistance',
    'Pet Sitting',
    'Plumbing',
    'Computer Repair',
    'Programming',
    'Technology Services',
    'Graphic Design',
    'Car Repair',
    'Other',
    'Appliance Troubleshooting',
    'Woodworking',
    'Delivery',
    'Furniture Cleaning',
    'Gardening',
    'Photography',
    'Sewing and Alterations',
    'Organization',
    'Art',
    'Music',
    'Pet Training',
    'Construction'
  ];

  Autocomplete<String> _buildJobTitleAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return possibleJobs
            .where((String option) => option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()))
            .toList();
      },
      onSelected: (String selectedJob) {
        setState(() {
          _jobTitleController.text = selectedJob;
        });
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter job title',
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future allJobs(bool whichList) async {
    if (whichList == true) {
      await db
          .collection('jobs')
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                Job i = Job.fromSnapshot(element);
                i.ID = element.id;
                firstList.add(i);
              }));
    } else {
      await db
          .collection('jobs')
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                Job i = Job.fromSnapshot(element);
                i.ID = element.id;
                secondList.add(i);
              }));
    }
    // final jobData = snapshot.docs.map((e) => Job.fromSnapshot(e)).toList();
    // jo = jobData;
  }

  Future compareLists() async {
    for (int i = 0; i < secondList.length; i++) {
      if (!firstList.contains(secondList[i])) {
        jobID = secondList[i].ID;
      }
    }
    return jobID;
  }

  Future getUsers() async {
    await db
        .collection('users')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              user i = user.fromSnapshot(element);
              i.ID = element.id;
              users.add(i);
            }));
  }

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
    await getUsers();
    await allJobs(true);
    late user current;
    for (int i = 0; i < users.length; i++) {
      if (users[i].email == userEmail) {
        displayName =
            "${users[i].firstName} ${users[i].lastName.characters.first.toUpperCase()}.";
        userID = users[i].ID;
        current = users[i];
      }
    }

    totalPostedJobs++;

    await FirebaseFirestore.instance.collection('users').doc(userID).set({
      "totalPostedJobs": totalPostedJobs,
    }, SetOptions(merge: true)).then(
        ((value) => print("Total Posted Jobs Updated")));

    GeoPoint g = GeoPoint(location.latitude, location.longitude);
    addJobDetails(
      _jobTitleController.text.trim(),
      _jobDescriptionController.text.trim(),
      _selectedDate!,
      _jobStartingBidController.text.trim(),
      g,
      address,
    );
    await addJobToUserCollection(current);
    //await addBidsToJobFile();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const JobPostedSuccessfullyPage(),
    ));
  }

  // Future addBidsToJobFile() async {
  //   CollectionReference jobDoc = FirebaseFirestore.instance
  //       .collection('jobs')
  //       .doc(jobID)
  //       .collection('currentBids');

  //   jobDoc
  //       .add({
  //         'userID': 'PLACEHOLDER',
  //         'bidAmount': 'PLACEHOLDER',
  //       })
  //       .then((value) => print("job put in userPosted"))
  //       .catchError(
  //           (error) => print("Failed to put job in UserPoster: $error"));
  // }

  Future addJobToUserCollection(user current) async {
    await allJobs(false);
    await compareLists();
    print("JOB ID = " + jobID);
    user thisUser = current;
    print("USER ID = ${thisUser.ID}");
    CollectionReference postedJobs = FirebaseFirestore.instance
        .collection('users')
        .doc(thisUser.ID)
        .collection('postedJobs');
    print('ABOUT TO POST \n\n\n\n');

    return postedJobs
        .add({
          'ID': jobID,
        })
        .then((value) => print("job put in userPosted"))
        .catchError(
            (error) => print("Failed to put job in UserPoster: $error"));
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
          'jobPoster': userEmail,
          'displayName': displayName,
          'posterID': userID,
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
    print(address);
    print('LOCATION = ${location.latitude}, ${location.longitude}');
    print('WE DIDIDIDIDIDIDIDIDI IT RAHHHHHHHHHHHHHHHHHH');
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
                          const Text(
                            'Job Title:',
                            style: TextStyle(fontSize: 18),
                          ),
                          _buildJobTitleAutocomplete(),
                          // TextFormField(
                          //   controller: _jobTitleController,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     hintText: 'Enter job title',
                          //   ),
                          // ),
const SizedBox(height: 16),
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      'Job Description:',
      style: TextStyle(
        fontSize: 34, // Set font size to 30pt
        fontWeight: FontWeight.bold, // Set font weight to bold
      ),
    ),
    const SizedBox(height: 8),
    TextFormField(
      controller: _jobDescriptionController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter job description',
      ),
      maxLines: 11,
      style: TextStyle(
        fontSize: 14, // Set font size to 18pt for the TextFormField
      ),
    ),
  ],
),
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
Center(
  child: ElevatedButton(
    onPressed: () {
      _openSlidingPanel();
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        const Color(0xFF2598D7),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(double.infinity, 50), // Adjust the height as needed
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 24),
      ),
      alignment: Alignment.center, // Center the text within the button
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on,
          color: Colors.white,
          size: 30, // Increased icon size
        ),
        const SizedBox(width: 8),
        Container(
          width: 200,
          child: Text(
            enterYourAddressHere,
            textAlign: TextAlign.center, // Center the text within the container
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Increased font size
            ),
          ),
        ),
        const SizedBox(width: 24), // Add this to align with the icon of the TextButton beneath
      ],
    ),
  ),
),




const SizedBox(height: 16),
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      ElevatedButton(
        onPressed: () async {
          await _selectDeadLineDate(context);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color(0xFF2598D7),
          ),
          minimumSize: MaterialStateProperty.all<Size>(
            Size(double.infinity, 50), // Adjust the height as needed
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 24),
          ),
          alignment: Alignment.center, // Center the text within the button
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 30, // Increased icon size
              color: Colors.white, // Set icon color to white
              semanticLabel: 'Calendar',
            ),
            const SizedBox(width: 8),
            const Text(
              ' Deadline Date:',
              style: TextStyle(
                fontSize: 22, // Increased font size to match the other TextButton
                color: Colors.white, // Set text color to white
              ),
            ),
            Text(
              _selectedDate != null
                  ? ' ${_selectedDate!.toLocal().month}-${_selectedDate!.toLocal().day}-${_selectedDate!.year}'
                  : ' Select a date',
              style: const TextStyle(
                fontSize: 22, // Increased font size to match the other TextButton
                color: Colors.white, // Set text color to white
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
  ),
),







                         const SizedBox(height: 16),
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      'Starting Bid',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 10), // Reduce the height as needed
    TextField(
      keyboardType: TextInputType.number,
      controller: _jobStartingBidController,
      style: TextStyle(fontSize: 30), // Increase the font size
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '\$0.00', // Initial placeholder, customize as needed
        hintStyle: TextStyle(fontSize: 30, color: Colors.grey), // Increase the font size
        border: OutlineInputBorder(
          borderSide: BorderSide.none, // Make the border invisible
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        isDense: true,
      ),
    ),
  ],
),





                          const SizedBox(height: 16),
ElevatedButton(
  onPressed: postJob,
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF1D465D)),
    minimumSize: MaterialStateProperty.all<Size>(
      Size(double.infinity, 50), // Adjust the height as needed
    ),
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      const EdgeInsets.symmetric(horizontal: 24),
    ),
  ),
  child: Text(
    'Post Job',
    style: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
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
  const JobPostedSuccessfullyPage({super.key});

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
