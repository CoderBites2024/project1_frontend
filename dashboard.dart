import 'package:flutter/material.dart';
import 'package:p_project1/drawer.dart';
import 'package:p_project1/services/user.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  // Fetch users from API
  void getUsers() async {
    try {
      List<Map<String, dynamic>> fetchedUsers = await fetchUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users!')),
      );
    }
  }
  
  // Fetch user by ID for viewing details
  void getUserById() async {
    final TextEditingController idController = TextEditingController();
    final userId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fetch User by ID'),
        content: TextField(
          controller: idController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Enter User ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(idController.text);
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid ID!')),
                );
              } else {
                Navigator.of(context).pop(id); // Pass the ID back
              }
            },
            child: Text('Fetch'),
          ),
        ],
      ),
    );

    if (userId != null) {
      try {
        User user = await fetchUserById(userId);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('User Details'),
            content: Text(
              'Name: ${user.name}\n'
              'Email: ${user.email}\n'
              'Sent Mails: ${user.sentEmails}\n'
              'Activity Time: ${user.activitiTime}\n'
              'Activity State: ${user.activityState}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found!')),
        );
      }
    }
  }

  // Remove user from API and local state
  void removeUser(BuildContext context, int index) async {
  try {
    int userId = users[index]['id'];

    // Call deleteUser API
    await deleteUser(userId);

    // Update state after deletion
    setState(() {
      if (filteredUsers.isNotEmpty) {
        users.removeWhere((user) => user['id'] == userId);
        filteredUsers.removeAt(index);
      } else {
        users.removeAt(index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User deleted successfully!')),
    );
  } catch (e) {
    print('Error deleting user: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete user!')),
    );
  }
}

  // Update user details
  void updateUser(BuildContext context, int index) async {
    Map<String, dynamic> currentUser = users[index];

    final updatedUser = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UpdateUserDialog(user: currentUser),
    );

    if (updatedUser != null) {
      try {
        User updatedUserData = User(
          id: currentUser['id'],
          name: updatedUser['name'],
          email: updatedUser['e-mail'],
          sentEmails: updatedUser['sent mails'],
          activitiTime: currentUser['activiti_time'], // Don't overwrite time
          activityState: updatedUser['activity state'].toLowerCase(),
        );

        User updatedResponse = await putUser(currentUser['id'], updatedUserData);

        setState(() {
          users[index] = {
            'id': updatedResponse.id,
            'name': updatedResponse.name,
            'e-mail': updatedResponse.email,
            'sent mails': updatedResponse.sentEmails,
            'activity state': updatedResponse.activityState.toString(),
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully!')),
        );
      } catch (e) {
        print('Error updating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Show a search bar dialog
            showSearchDialog(context);
          },
        ),
        if (filteredUsers.isNotEmpty)
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          setState(() {
            filteredUsers = [];
            searchController.clear();
            });
          },
        ),
      ],
    ),
      
      drawer: CustomDrawer(), // Use CustomDrawer instead of Drawer
      body: 
      ListView.builder(
        itemCount: filteredUsers.isNotEmpty ? filteredUsers.length : users.length,
        itemBuilder: (context, index) {
        Map<String, dynamic> user =
        filteredUsers.isNotEmpty ? filteredUsers[index] : users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user['name'][0], // Display the first letter of the name
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue, // Set a background color
                ),
                title: Text(user['name']),
                subtitle: Text(
                  "E-mail: ${user['email']}\nSent Mails: ${user['sent_mails']}\nActivity: ${user['activity_state']}",
                ),
                isThreeLine: true, // Allows for three lines in the subtitle
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () => updateUser(context, index), // Update button
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeUser(context, index), // Delete button
                    ),
                  ],
                ),
                onTap: () {
                  print('Tapped on ${user['name']}');
                },
              ),
            ),
          );
        },
      ),
    );
  }
  void showSearchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Search Users'),
      content: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'search for users',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            filteredUsers = users
                .where((user) =>
                    user['name'].toLowerCase().contains(value.toLowerCase()) ||
                    user['email'].toLowerCase().contains(value.toLowerCase()) ||
                    user['sent_mails']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    user['activity_time']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    user['activity_state']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                .toList();
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              filteredUsers = [];
              searchController.clear();
            });
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
          ),
          ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Search'),
        ),
        ],
      ),
    );
  }
}

// Dialog to update user
class UpdateUserDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  UpdateUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: user['name']);
    final TextEditingController emailController = TextEditingController(text: user['e-mail']);
    final TextEditingController sentMailsController = TextEditingController(text: user['sent mails'].toString());
    final TextEditingController activityStateController = TextEditingController(text: user['activity state']);

    return AlertDialog(
      title: Text('Update User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'E-mail'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: sentMailsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Sent Mails'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: activityStateController,
            decoration: InputDecoration(labelText: 'Activity State'),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Cancel button
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isEmpty ||
                emailController.text.isEmpty ||
                sentMailsController.text.isEmpty ||
                activityStateController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All fields must be filled!")),
              );
              return;
            }

            if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid email address!")),
              );
              return;
            }

            int sentMails = int.tryParse(sentMailsController.text) ?? -1;
            if (sentMails < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid number for Sent Mails!")),
              );
              return;
            }

            Navigator.of(context).pop({
              'name': nameController.text,
              'e-mail': emailController.text,
              'sent mails': sentMails,
              'activity state': activityStateController.text,
            });
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
