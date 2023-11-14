import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odd_job_app/pages/home_page.dart';

class JobTitlePage extends StatefulWidget {
  const JobTitlePage({super.key});

  @override
  State<JobTitlePage> createState() => _JobTitlePageState();
}

class _JobTitlePageState extends State<JobTitlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Post a Job'),
          backgroundColor: const Color(0xFF1D465D),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomerSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search),
            )
          ]),
    );
  }
}

class CustomerSearchDelegate extends SearchDelegate {
  List<String> searchTerms = [
    'Lawn Mowing',
    'House Painting',
    'MegaNutzz',
    'House Cleaning',
    'Cooking',
  ];
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var jobtitles in searchTerms) {
      if (jobtitles.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(jobtitles);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var jobtitles in searchTerms) {
      if (jobtitles.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(jobtitles);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
