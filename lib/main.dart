import 'package:flutter/material.dart';
import 'package:bmicalculator/Controller/bmi_db.dart';

void main() => runApp(BMICalculatorApp());

class BMICalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      home: BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  BMIDatabase _bmiDatabase = BMIDatabase();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bmiController = TextEditingController();
  TextEditingController averageBMIController = TextEditingController();
  String gender = 'Male';

  @override
  void initState() {
    super.initState();
    // Fetch the latest data from the database and update the text controllers
    updateTextFields();
  }

  Future<void> updateTextFields() async {
    print("Fetching latest data...");
    List<Map<String, dynamic>> allData = await _bmiDatabase.getAllData();
    print("Fetched data: $allData");

    if (allData.isNotEmpty) {
      Map<String, dynamic> latestData = allData.last;

      setState(() {
        fullNameController.text = latestData[_bmiDatabase.colUsername];
        heightController.text = latestData[_bmiDatabase.colHeight].toString();
        weightController.text = latestData[_bmiDatabase.colWeight].toString();
        gender = latestData[_bmiDatabase.colGender];
        calculateBMI();
      });
    }
  }

  Future<void> calculateAverageBMI() async {
    List<Map<String, dynamic>> allData = await _bmiDatabase.getAllData();

    if (allData.isNotEmpty) {
      double totalBMI = 0;

      for (Map<String, dynamic> data in allData) {
        double weight = data[_bmiDatabase.colWeight];
        double height = data[_bmiDatabase.colHeight];
        double bmi = weight / ((height / 100) * (height / 100));
        totalBMI += bmi;
      }

      double averageBMI = totalBMI / allData.length;

      setState(() {
        averageBMIController.text = averageBMI.toStringAsFixed(2);
      });
    } else {
      setState(() {
        averageBMIController.text = 'No data available';
      });
    }
  }

  void calculateBMI() async {
    double height = double.tryParse(heightController.text) ?? 0.0;
    double weight = double.tryParse(weightController.text) ?? 0.0;

    if (height > 0 && weight > 0) {
      double bmi = weight / ((height / 100) * (height / 100));
      bmiController.text = bmi.toStringAsFixed(2);

      // Determine BMI status based on gender
      String bmiStatus = '';
      if (gender == 'Male') {
        bmiStatus = getBMIStatusForMale(bmi);
      } else {
        bmiStatus = getBMIStatusForFemale(bmi);
      }

      // Adding Data to Database
      int insertedRowId = await _bmiDatabase.insertData(
        fullNameController.text,
        weight,
        height,
        gender,
        bmiStatus,
      );

      //Checking if data insertion was successful
      if (insertedRowId != -1) {
        calculateAverageBMI();
        // Data inserted successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BMI Status: $bmiStatus'),
          ),
        );

      } else {
        // Data insertion failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to insert data into the database.'),
          ),
        );
      }
    } else {
      bmiController.text = '';
    }
  }

  String getBMIStatusForMale(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight. Careful during strong wind!';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return 'That’s ideal! Please maintain';
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      return 'Overweight! Work out please';
    } else {
      return 'Whoa Obese! Dangerous mate!';
    }
  }

  String getBMIStatusForFemale(double bmi) {
    if (bmi < 16) {
      return 'Underweight. Careful during strong wind!';
    } else if (bmi >= 16 && bmi <= 22) {
      return 'That’s ideal! Please maintain';
    } else if (bmi >= 22 && bmi <= 27) {
      return 'Overweight! Work out please';
    } else {
      return 'Whoa Obese! Dangerous mate!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Your Full Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Height (cm)'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight (KG)'),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: calculateBMI,
                child: Text('Calculate BMI'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: bmiController,
                enabled: false,
                decoration: InputDecoration(labelText: 'BMI Value'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: averageBMIController,
                enabled: false,
                decoration: InputDecoration(labelText: 'BMI Average'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}