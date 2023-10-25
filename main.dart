import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPriceChart(),
    );
  }
}

class StockPriceChart extends StatefulWidget {
  @override
  _StockPriceChartState createState() => _StockPriceChartState();
}

class _StockPriceChartState extends State<StockPriceChart> {
  // Define variables to store data and settings
  String stockCode = "PG"; // Change this to your stock code
  bool isEvenNIM = true; // Change based on your NIM
  int year = 2021; // Change based on your graduation year

  // Define variable to store stock price data
  List<Map<String, dynamic>> stockPriceData = [];

  // Function to fetch stock data from Polygon API
  Future<List<Map<String, dynamic>>> fetchData() async {
    final apiKey = 'YOUR_API_KEY';
    final response = await http.get(Uri.parse(
      'https://api.polygon.io/v2/aggs/ticker/$stockCode/range/1/day/2023-01-09/2023-02-09?apiKey=$apiKey',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        List<dynamic> results = data['results'];
        List<Map<String, dynamic>> dataList =
            results.map((item) => item as Map<String, dynamic>).toList();
        return dataList;
      } else {
        return [];
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price Chart'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Stock Code: $stockCode'),
            ElevatedButton(
              onPressed: () async {
                final data = await fetchData();
                setState(() {
                  stockPriceData = data;
                });
              },
              child: Text('Refresh Data'),
            ),
            LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: stockPriceData.length.toDouble() - 1,
                minY: 0,
                maxY: 100, // Change the maximum value as needed

                lineBarsData: [
                  LineChartBarData(
                    spots: stockPriceData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final price = entry.value[
                          'c']; // Replace with the appropriate attribute ('o', 'c', 'h', or 'l')
                      return FlSpot(index.toDouble(), price.toDouble());
                    }).toList(),
                    isCurved: true,
                    colors: [
                      year == 2020 ? Colors.yellow : Colors.yellow
                    ], // Change colors based on the year
                    dotData: FlDotData(
                      show: !isEvenNIM, // Show dots for odd NIM
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
