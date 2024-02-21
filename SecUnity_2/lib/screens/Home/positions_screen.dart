import 'package:flutter/material.dart';
import '../../constants/positions _style.dart';

class PositionChartPage extends StatefulWidget {
  final String squadUid;

  PositionChartPage({required this.squadUid});

  @override
  _PositionChartPageState createState() => _PositionChartPageState();
}

class _PositionChartPageState extends State<PositionChartPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If loading, show a loading indicator with gradient background
      return Scaffold(
        backgroundColor: PositionStyles.backgroundColor1,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white, // Set color of the circular progress indicator
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PositionStyles.backgroundColor1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PositionStyles.backgroundColor1,
              PositionStyles.backgroundColor2,
              PositionStyles.backgroundColor3,
              PositionStyles.backgroundColor4,
              PositionStyles.backgroundColor5,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Position',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Table(
              columnWidths: {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.black),
              children: [
                TableRow(
                  children: [
                    _buildPositionCell('Position 1'),
                    _buildPositionCell('Position 2'),
                    _buildPositionCell('Position 3'),
                    _buildPositionCell('Position 4'),
                    _buildPositionCell('Position 5'),
                  ],
                ),
                TableRow(
                  children: [
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                  ],
                ),
                TableRow(
                  children: [
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                  ],
                ),
                TableRow(
                  children: [
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                  ],
                ),
                TableRow(
                  children: [
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                    _buildCellContent(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCell(String position) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        position,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCellContent() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        'Empty',
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Simulating a loading delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
