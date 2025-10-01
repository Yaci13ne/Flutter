import 'package:flutter/material.dart';
import 'page6.dart';
import 'page4.dart';

class WeightHeightScreen extends StatefulWidget {
  final int age;
  final String gender;

  const WeightHeightScreen({
    super.key, 
    required this.gender,
    required this.age,
  });

  @override
  _WeightHeightScreenState createState() => _WeightHeightScreenState();
}

class _WeightHeightScreenState extends State<WeightHeightScreen> {
  int _selectedWeight = 65;
  double _height = 170;

  @override
  Widget build(BuildContext context) {
    print('[WeightHeightScreen] Received gender: ${widget.gender}, age: ${widget.age}');

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/4.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset(
                      "pictures/GymFitXnutrition-removebg-preview.png",
                      height: 150,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),

                    // **Weight Section**
                    Text(
                      "What is Your weight ?",
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'bolditalic',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

                    // **Weight Picker**
                    SizedBox(
                      height: 100,
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                            initialItem: _selectedWeight - 45),
                        itemExtent: 45,
                        physics: FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedWeight = index + 45;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            int weight = 45 + index;
                            bool isSelected = weight == _selectedWeight;
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: isSelected ? 120 : 90,
                              height: isSelected ? 60 : 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade600
                                    : Colors.green.shade300,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$weight Kg",
                                style: TextStyle(
                                  fontSize: isSelected ? 26 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                          childCount: 51,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // **Height Section**
                    Text(
                      "What is Your Height ?",
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'bolditalic',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    // **Height Slider**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(11, (index) {
                            int value = 250 - ((250 - 50) ~/ 10 * index); 
                            return SizedBox(
                              height: 22.7,
                              child: Text(
                                "$value",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(width: 5),
                        SizedBox(
                          height: 250,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 5,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                              ),
                              child: Slider(
                                value: _height,
                                min: 50,
                                max: 250,
                                divisions: null, 
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey.shade300,
                                thumbColor: Colors.blue,
                                onChanged: (value) {
                                  setState(() {
                                    _height = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          _height.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // **Height Display Box**
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_height.round()} cm",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // **Navigation Buttons**
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // **Previous Button**
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenderSelectionScreen(
                              age: widget.age,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        fixedSize: Size(110, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset("pictures/carbon_nextleft.png", width: 20, height: 20),
                          SizedBox(width: 5),
                          Text(
                            "Previous",
                            style: TextStyle(
                              color: Color(0xFF47DF7C),
                              fontSize: 16,
                              fontFamily: 'interregular',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // **Next Button**
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedWeight < 45 || _selectedWeight > 95 || _height < 50 || _height > 250) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please select a valid weight (45-95 Kg) and height (50-250 cm)."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BMIScreen(
                                weight: _selectedWeight,
                                height: _height.round(),
                                gender: widget.gender,
                                age: widget.age,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        fixedSize: Size(110, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 5),
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Color(0xFF47DF7C),
                              fontSize: 16,
                              fontFamily: 'interregular',
                            ),
                          ),
                          Image.asset("pictures/carbon_nextright.png", width: 25, height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
