import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_project1/drawer.dart';
import 'package:p_project1/services/user.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sentmailsController = TextEditingController();
  final TextEditingController _activitytimeController = TextEditingController();
  final TextEditingController _activitystateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Global key for form validation

  File? _selectedFile;
  String? _selectedavailability;

  // Method to get the current system time
  String getTimeNow() {
    DateTime now = DateTime.now().toUtc();
    String formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now);
    return formattedTime;
  }

  // Method to create a new user
  void createdUser() async {
    try {
      User user = User(
        name: _usernameController.text,
        email: _emailController.text,
        sentEmails: int.parse(_sentmailsController.text),
        activitiTime: getTimeNow(), // Automatically set the current time here
        activityState: _activitystateController.text,
      );

      User createdUser = await createUser(user);

      // Reset form fields
      _usernameController.clear();
      _emailController.clear();
      _sentmailsController.clear();
      _activitytimeController.clear();
      _activitystateController.clear();
      _selectedavailability = null;

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user!')),
      );
    }
  }

  // Function to submit the form and upload the image to the server (you may add image picking logic here)
  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Call the createdUser function to save the data
      createdUser();
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set the current system time when the widget is built, if not set
    if (_activitytimeController.text.isEmpty) {
      _activitytimeController.text = getTimeNow();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Add User')),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Use the global key to validate the form
          child: Column(
            children: [
              // User Name
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a User name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Email (Text Form Field instead of Dropdown)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Sent Mails
              TextFormField(
                controller: _sentmailsController,
                decoration: InputDecoration(
                  labelText: 'Sent Mails',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of sent mails';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Activity Time (automatically filled with the current time)
              TextFormField(
                controller: _activitytimeController,
                decoration: InputDecoration(
                  labelText: 'Activity Time',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true, // Prevent user from editing manually
              ),
              SizedBox(height: 20),

              // Activity State Dropdown for 'Active' and 'Inactive'
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Activity State',
                  border: OutlineInputBorder(),
                ),
                value: _selectedavailability,
                items: [
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Inactive',
                    child: Text('Inactive'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedavailability = value;
                    _activitystateController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an activity state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // File Selection Placeholder (No File Picker Added)
              _selectedFile != null
                  ? Text('Selected file: ${_selectedFile!.path}')
                  : Text('No file selected.'),

              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
