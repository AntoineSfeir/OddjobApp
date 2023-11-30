import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/myBidsTab.dart';
import 'package:odd_job_app/pages/search_page.dart';
import 'package:odd_job_app/jobs/post_job_page.dart';
import 'package:odd_job_app/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/activeJobsTab.dart';
import 'package:odd_job_app/pages/messages_page.dart';
import 'package:odd_job_app/pages/user_posted_jobs_view.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final db = FirebaseFirestore.instance;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  late user currentUser;

  List<user> users = [];
  List<Job> allJobsInDB = [];
  List<Job> allActiveJobs = [];
  List<Job> finalListForPostedJobsPanel = [];
  List<Job> allPostedJobs = [];
  List<bid> myBids = []; //bids that I have placed
  List<bid> bidsOnMyJobs = []; //bids that others have placed on the jobs I have posted
  List<String> dontShowTheseOnSearchPage = [];
  List<String> docIDs = [];

  bool firstLoad = false;

  Future setfinalListForPostedJobsPanel() async {
    finalListForPostedJobsPanel = allPostedJobs;

    for (int i = 0; i < finalListForPostedJobsPanel.length; i++) {
//
      for (int j = 0; j < bidsOnMyJobs.length; j++) {
//
        if (finalListForPostedJobsPanel[i].ID ==
            bidsOnMyJobs[j].jobThatWasBidOn.ID) {
//
          finalListForPostedJobsPanel[i].bids.add(bidsOnMyJobs[j]);
        }
      }
    }
  }

  Future getCurrentUser() async {
    await db.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((element) {
            user i = user.fromSnapshot(element);
            i.ID = element.id;
            users.add(i);
          }),
        );

    for (int i = 0; i < users.length; i++) {
      if (users[i].email == userEmail) {
        currentUser = users[i];
        print("Current Username: ${currentUser.username}");
        print("Current User first name: ${currentUser.firstName}");
        print("Current User last name: ${currentUser.lastName}");
      }
    }
  }

  late Job b;
  Future sortJobs() async {
    await db
        .collection('users')
        .doc(currentUser.ID)
        .collection('ActiveJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              for (int i = 0; i < allJobsInDB.length; i++) {
                if (element['jobID'] == allJobsInDB[i].ID) {
                  print("ELEMENT jobID = ${element.id}");
                  b = allJobsInDB[i];
                  b.working = element['Working'];
                  print(b.working);
                  print("JOBPOSTER = ${b.displayName}");
                  b.contractorID = element['contractorID'];
                  
                  b.workerID = element['workerID'];
                  allActiveJobs.add(b);
                  break;
                }
              }
            }));

    for (int i = 0; i < allActiveJobs.length; i++) {

    }
    //Grab all of my bids
    await db
        .collection('users')
        .doc(currentUser.ID)
        .collection('currentBids')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              String bidAmount = element['bidAmount'];
              String jobID = element['jobID'];
              late Job thisJob;
              //late user thisUser;
              for (int i = 0; i < allJobsInDB.length; i++) {
                if (allJobsInDB[i].ID == jobID) {
                  thisJob = allJobsInDB[i];
                }
              }
              // for (int i = 0; i < users.length; i++) {
              //   if (users[i].ID == thisJob.posterID) {
              //     thisUser = users[i];
              //   }
              // }

              bid b = bid(
                  bidder: currentUser,
                  amount: bidAmount,
                  jobThatWasBidOn: thisJob);
              b.bidID = element.id;

              myBids.add(b);
            }));
    List<Job> jobsIHavePosted = [];
    print("BEFORE SECOND DB CALL");

    //grabbing all of my posted Jobs
    await db
        .collection('users')
        .doc(currentUser.ID)
        .collection('postedJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              String jobID = element['ID'];

              for (int i = 0; i < allJobsInDB.length; i++) {
                if (allJobsInDB[i].ID == jobID) {
                  jobsIHavePosted.add(allJobsInDB[i]);
                }
              }
            }));
    print("BEFORE DB LOOP");

    //grabbing all the currentBids from this job
    for (int i = 0; i < jobsIHavePosted.length; i++) {
      await db
          .collection('jobs')
          .doc(jobsIHavePosted[i].ID)
          .collection('currentBids')
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                String otherUserID = element['userID'];
                String theirBidAmount = element['bidAmount'];
                late user otherUser;
                for (int j = 0; j < users.length; j++) {
                  if (users[j].ID == otherUserID) {
                    otherUser = users[j];
                    bid b = bid(
                        bidder: otherUser,
                        amount: theirBidAmount,
                        jobThatWasBidOn: jobsIHavePosted[i]);

                    bidsOnMyJobs.add(b);
                  }
                }
              }));
    }

    for (int i = 0; i < bidsOnMyJobs.length; i++) {
      await db
          .collection('users')
          .doc(bidsOnMyJobs[i].bidder.ID)
          .collection('currentBids')
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                for (int j = 0; j < bidsOnMyJobs.length; j++) {
                  if (element['jobID'] == bidsOnMyJobs[j].jobThatWasBidOn.ID) {
                    bidsOnMyJobs[j].bidID = element.id;
                  }
                }
              }));
    }

    //every currentbid of every user thats bid on my jobs

    print("JOBSIHAVEPOSTEDLENGTH =  ${jobsIHavePosted.length}");
    allPostedJobs = jobsIHavePosted;
    await setfinalListForPostedJobsPanel();

    for (int i = 0; i < allPostedJobs.length; i++) {
      print("adding to dontshow : ${allPostedJobs[i].ID}");
      dontShowTheseOnSearchPage.add(allPostedJobs[i].ID);
    }
    for (int i = 0; i < allActiveJobs.length; i++) {
      dontShowTheseOnSearchPage.add(allActiveJobs[i].ID);
    }
    for (int i = 0; i < myBids.length; i++) {
      dontShowTheseOnSearchPage.add(myBids[i].jobThatWasBidOn.ID);
    }

    currentUser.dontShow = dontShowTheseOnSearchPage;
  }

  Future allJobs() async {
    if (!firstLoad) {
      await getCurrentUser();
      await db.collection('jobs').get().then(
            (snapshot) => snapshot.docs.forEach((element) {
              Job i = Job.fromSnapshot(element);
              i.ID = element.id;
              allJobsInDB.add(i);
            }),
          );
      firstLoad = true;
      print("BEFORE SORTJOBS");
      await sortJobs();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<String?> getProfilePictureUrl(String documentId) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('profilePictures/$documentId.jpg');
      final result = await ref.getDownloadURL();
      return result;
    } catch (e) {
      // The file does not exist
      return null;
    }
  }

  Widget buildStarRating(int userRating) {
    List<Icon> stars = [];
    userRating = (userRating / 2).round();

    for (int i = 0; i < 5; i++) {
      stars.add(
        Icon(
          Icons.star,
          color: i < userRating ? Colors.amber : Colors.grey,
          size: 16, // Adjusted star size
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: stars,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: FutureBuilder(
          future: allJobs(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      expandedHeight: 200,
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.black,
                      flexibleSpace: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          bool isExpanded = constraints.maxHeight >
                              200; // Adjust this threshold as needed
                          return FlexibleSpaceBar(
                            centerTitle: true,
                            collapseMode: CollapseMode.pin,
                            title: isExpanded
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FutureBuilder<String?>(
                                        future:
                                            getProfilePictureUrl(currentUser.ID),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // You can display a loading indicator here if needed
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError ||
                                              snapshot.data == null) {
                                            return const CircleAvatar(
                                              backgroundColor:
                                                  Color(0xFFC9D0D4),
                                            );
                                          } else {
                                            return CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFFC9D0D4),
                                              backgroundImage:
                                                  NetworkImage(snapshot.data!),
                                            );
                                          }
                                        },
                                      ),
                                      Text(
                                        currentUser.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      buildStarRating(
                                          currentUser.averageRating.toInt()),
                                    ],
                                  )
                                : Text(
                                    currentUser.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                            background: Image.network(
                              "https://cdn.discordapp.com/attachments/1156019469907394671/1178809496936648704/VJ-71054__39080.png?ex=65777ee5&is=656509e5&hm=3bb5f84edf9e8cc0652e6cff74c076dd8b283e05082c6cf86ac4bc1d4bdf2091&",
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: Colors.indigo,
                          unselectedLabelColor: Colors.grey,
                          tabs: _tabs,
                        ),
                      ),
                      pinned: false,
                    ),
                  ];
                },
                body: TabBarView(
                  children: _tabs.map((tab) {
                    if (tab.text == "Posted Jobs") {
                      return UsersPostedJobsView(
                        myJobs: finalListForPostedJobsPanel,
                      );
                    } else if (tab.text == "Active Jobs") {
                      return activeJobsViewTab(activeJobs: allActiveJobs);
                    } else if (tab.text == "My Bids") {
                      //return Placeholder();
                      return MyBidsViewTab(myBids: myBids);
                    } else {
                      return const Placeholder();
                    }
                  }).toList(),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  color: Colors.grey,
                  iconSize: 40.0,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(currentUser: currentUser),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigo,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    iconSize: 35.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostJobPage(currentUser: currentUser),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessagesPage(
                                currentUser: currentUser,
                              )),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                currentUser: currentUser,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _tabs = [
  Tab(icon: Icon(Icons.assignment), text: "Posted Jobs"),
  Tab(icon: Icon(Icons.money), text: "My Bids"),
  Tab(icon: Icon(Icons.incomplete_circle), text: "Active Jobs"),
];

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
