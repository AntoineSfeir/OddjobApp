import 'package:flutter/material.dart';

class MegaNutz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Value Selector',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<int> selectedValues = [0, 0, 0, 0]; // For each column
  List<List<bool>> selectedIndexes =
      List.generate(4, (index) => List.generate(10, (i) => false));

  void _showValueSelectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Value'),
          content: Container(
            width: double.maxFinite,
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (columnIndex) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            10,
                            (index) {
                              final value = index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    for (var i = 0; i < 10; i++) {
                                      selectedIndexes[columnIndex][i] =
                                          i == index;
                                      if (i == index) {
                                        selectedValues[columnIndex] = value;
                                      }
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: selectedIndexes[columnIndex][index]
                                          ? Colors
                                              .blue // Change color if selected
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Update the main value using the selected values from each column
                  selectedValues.forEach((value) =>
                      print(value)); // Replace this line with your logic
                });
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Value Selector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _showValueSelectorDialog();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Place a bid: ${selectedValues[0]}${selectedValues[1]}${selectedValues[2]}${selectedValues[3]}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
