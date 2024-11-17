import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/ImageApi_Model.dart';
import 'package:flutterquiz/utils/constants/model.dart';

class Image_Data extends StatefulWidget {
  @override
  State<Image_Data> createState() => _Image_DataState();
}

class _Image_DataState extends State<Image_Data> {
  int _currentIndex = 0; // Current image index
  late List<ImageData> images; // List to store image data
  late Future<ApiResponse> _fetchDataFuture; // Store the future to be used in FutureBuilder

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();

    // Start automatic image switching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSwitch();
    });
  }

  void _startAutoSwitch() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 5));
      if (mounted && images.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % images.length; // Loop through images
        });
      }
      return mounted;
    });
  }
 @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          images = snapshot.data!.data; // Assign images from API response

          return Column(
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: Image.network(
                    images[_currentIndex].image, // Display image URL
                    key: ValueKey<String>(images[_currentIndex].image),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        } else {
          return Center(child: Text('No data found'));
        }
      },
    );
  }
}