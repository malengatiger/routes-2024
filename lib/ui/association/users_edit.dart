import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;

class UsersEdit extends StatefulWidget {
  const UsersEdit({super.key, required this.association, this.user});

  final Association association;
  final User? user;

  @override
  UsersEditState createState() => UsersEditState();
}

class UsersEditState extends State<UsersEdit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🌎🌎 🌎🌎 UsersEdit  🌎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setup();
    _getUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController firstNameController =
      TextEditingController();
  TextEditingController lastNameController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController cellphoneController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  bool busy = false;
  Prefs prefs = GetIt.instance<Prefs>();
  User? user;

  void _setup() async {
    if (widget.user != null) {
      lastNameController.text = widget.user!.lastName!;
      firstNameController.text = widget.user!.firstName!;
      emailController.text = widget.user!.email!;
      cellphoneController.text = widget.user!.cellphone!;
      country = prefs.getCountry();
      user = widget.user;
      setState(() {});
    }
  }

  List<User> users = [];
  String? userType;

  Widget getDropDown() {
    var drop = DropdownButton<String>(
      hint: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('  Select Staff Type'),
        ],
      ),
      items: [
        DropdownMenuItem<String>(
          value: Constants.ASSOCIATION_OFFICIAL,
          child: Text(Constants.ASSOCIATION_OFFICIAL),
        ),
        DropdownMenuItem<String>(
            value: Constants.AMBASSADOR, child: Text(Constants.AMBASSADOR)),
        DropdownMenuItem<String>(
            value: Constants.MARSHAL, child: Text(Constants.MARSHAL)),
        DropdownMenuItem<String>(
            value: Constants.ADMINISTRATOR_ASSOCIATION,
            child: Text(Constants.ADMINISTRATOR_ASSOCIATION)),
        DropdownMenuItem<String>(
            value: Constants.ROUTE_BUILDER,
            child: Text(Constants.ROUTE_BUILDER)),
        DropdownMenuItem<String>(
            value: Constants.DRIVER, child: Text(Constants.DRIVER)),
      ],
      onChanged: (value) {
        setState(() {
          userType = value;
        });
      },
    );

    return drop;
  }

  void _getUsers() async {
    users = await listApiDog.getAssociationUsers(
        widget.association.associationId!, true);
    pp('$mm association users found: ${users.length}');
    setState(() {});
  }

  _onSubmit() async {
    pp('$mm on submit wanted ...');
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (userType == null) {
      showErrorToast(
        message: 'Please select the user type',
        context: context,
      );
      return;
    }
    setState(() {
      busy = true;
    });
    if (widget.user == null) {
      user = User(
          userId: '${DateTime.now().millisecondsSinceEpoch}',
          associationId: widget.association.associationId!,
          associationName: widget.association.associationName!,
          countryId: widget.association.countryId,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          cellphone: cellphoneController.text,
          password: passwordController.text,
          userType: userType);

      try {
        var res = await dataApiDog.addUser(user!);
        pp('$mm user: $res');
        _getUsers();
        if (mounted) {
          showOKToast(
              message: 'Staff member registered on KasieTransie',
              context: context);
        }
      } catch (e, s) {
        pp('$e $s');
        if (mounted) {
          showErrorToast(message: '$e', context: context);
        }
      }
    } else {
      //TODO - update the user
      pp('$mm  update the user ...');
    }
    setState(() {
      busy = false;
    });
  }

  PlatformFile? csvFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      csvFile = result.files.first;
      pp('$mm csvFile exists: ${csvFile?.bytes!.length} bytes');
      setState(() {});
    } else {
      pp('$mm Error: File bytes are null');
      if (mounted) {
        showErrorToast(message: 'The file is not cool', context: context);
      }
    }
  }

  Country? country;
  Association? association;

  _sendFile() async {
    pp('$mm  send the User File ...');
    setState(() {
      busy = true;
    });

    try {
      var result = await dataApiDog.importUsersFromCSV(
          csvFile!, widget.association.associationId!);
      _getUsers();
      if (mounted) {
        var msg =
            '🌿 Users added: ${result!.users.length} errors: ${result.errors.length}';
        showOKToast(message: msg, context: context);
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 480,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      gapH32,
                      gapH32,
                      Text(
                        'Pick the Staff Members CSV File',
                        style: myTextStyleMediumLarge(context, 20),
                      ),
                      gapH16,
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                // backgroundColor: WidgetStatePropertyAll(
                                //     Colors.pink.shade800),
                                // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Change button color
                                // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                elevation: WidgetStatePropertyAll(8),
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.all(16)),
                                textStyle: WidgetStatePropertyAll(
                                    myTextStyleMediumLargeWithColor(
                                        context, Colors.pink, 16))),
                            onPressed: () {
                              _pickFile();
                            },
                            child: Text('Get File')),
                      ),
                      gapH32,
                      csvFile == null
                          ? gapH32
                          : SizedBox(
                              width: 400,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      // backgroundColor: WidgetStatePropertyAll(
                                      //     Colors.blue.shade800),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.blue),
                                      // Change button color
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      elevation: WidgetStatePropertyAll(8),
                                      padding: WidgetStatePropertyAll(
                                          EdgeInsets.all(24)),
                                      textStyle: WidgetStatePropertyAll(
                                          myTextStyleMediumLargeWithColor(
                                              context, Colors.blue, 18))),
                                  onPressed: () {
                                    _sendFile();
                                  },
                                  child: Text('Send Users File')),
                            ),
                      csvFile == null
                          ? gapH8
                          : SizedBox(
                              height: 28,
                            ),
                      gapH8,
                      TextFormField(
                        controller: firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          label: Text('First Name'),
                          hintText: 'Enter First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter First Name';
                          }
                          return null;
                        },
                      ),
                      gapH8,
                      TextFormField(
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          label: Text('Last Name'),
                          hintText: 'Enter Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Last Name';
                          }
                          return null;
                        },
                      ),
                      gapH8,
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          label: Text('Email Address'),
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email Address';
                          }
                          return null;
                        },
                      ),
                      gapH8,
                      TextFormField(
                        controller: cellphoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          label: Text('Cellphone'),
                          hintText: 'Enter Cellphone',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Cellphone';
                          }
                          return null;
                        },
                      ),
                      gapH8,
                      TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          label: Text('Password'),
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                      ),
                      gapH8,
                      getDropDown(),
                      gapH32,
                      userType == null
                          ? gapW8
                          : SizedBox(height: 64,
                            child: Center(
                              child: Text(
                                  '$userType',
                                  style:
                                      myTextStyleMediumLargeWithSize(context, 20),
                                ),
                            ),
                          ),
                      busy
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 8,
                                backgroundColor: Colors.pink,
                              ),
                            )
                          : SizedBox(
                              width: 400,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(8),
                                  ),
                                  onPressed: () {
                                    _onSubmit();
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text('Submit'))),
                            ),
                    ],
                  )),
            ),
          ),
          Positioned(
            right: 24,
            top: 24,
            child: Row(
              children: [
                Text('Staff Members'),
                gapW32,
                bd.Badge(
                  badgeContent: Text(
                    '${users.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                  badgeStyle: bd.BadgeStyle(
                    badgeColor: Colors.green.shade800,
                    elevation: 12,
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: users.length,
          itemBuilder: (_, index) {
            var car = users[index];
            return Card(
              elevation: 8,
              child: SizedBox(
                height: 80,
                child: Column(
                  children: [
                    Text(
                      '${car.firstName}',
                      style: myTextStyleMediumLargeWithSize(context, 20),
                    ),
                    Text(
                      '${car.lastName}',
                      style: myTextStyleMediumLargeWithSize(context, 20),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
