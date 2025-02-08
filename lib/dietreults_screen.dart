import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/foods.dart';
import 'package:heart_app/models/user.dart';
import 'package:provider/provider.dart';

class DietResultsScreen extends StatelessWidget {
  final String predictedResult;

  DietResultsScreen({required this.predictedResult});

  @override
  Widget build(BuildContext context) {
    // Parse the JSON string into a map
    Map<String, dynamic> resultMap = Map.from(jsonDecode(predictedResult));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<RegUser>().updateUserName('', '', '');
              Navigator.pushNamed(context, '/login');
            },
            icon: Icon(
              Icons.logout,
              color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
            ),
          ),
        ],
        title: Text(
          'Diet Plan Overview',
          style: TextStyle(
            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                          Color(int.parse(ThemeColors.themes['theme01']?['secondary_accent']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(10.0), // Padding around the text
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Diet Results",
                                style: TextStyle(
                                    fontSize: 24,
                                    color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                "Enter a Image of your Meal Below",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10, // Adjust the width of the gap between text and image
                        ),
                        // Replace the Image.asset with your desired image
                        Image.asset(
                          'assets/meal.png',
                          width: 100, // Adjust image width as needed
                          height: 100, // Adjust image height as needed
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  )
              ),
              SizedBox(height: 5,),

              SizedBox(height: 10),
              // Display prediction results
              Expanded(
                child: ListView.builder(
                  itemCount: resultMap.length,
                  itemBuilder: (context, index) {
                    String foodName = resultMap.keys.elementAt(index);
                    String foodQuantity = resultMap.values.elementAt(index).toString();

                    // Find the corresponding food item
                    Map<String, dynamic> foodItem = FoodItems.foodItems.firstWhere(
                          (item) => item['name'] == foodName,
                      orElse: () => {'image': '', 'calories': 0, 'forHeart': false, 'forDiabetes': false},
                    );

                    String imageName = foodItem['image'];
                    int calories = foodItem['calories'];
                    bool forCholesterol = foodItem['forHeart'];
                    bool forDiabetes = foodItem['forDiabetes'];

                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          'assets/foods/$imageName',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Calories: ${calories*(int.parse(foodQuantity))}',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Suitable for Cholesterol: ${forCholesterol ? 'Yes' : 'No'}',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Suitable for Diabetes: ${forDiabetes ? 'Yes' : 'No'}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        subtitle: Text('x $foodQuantity'),
                      ),
                    );
                  },
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
