import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:universal_html/html.dart';
import 'package:uuid/uuid.dart';

import '../../library/data_api.dart';
import '../../library/qr_code_generation.dart';

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

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cellphoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  final ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  bool busy = false;
  Prefs prefs = GetIt.instance<Prefs>();
  User? selectedUser;

  void _setup() async {
    country = prefs.getCountry();

    if (widget.user != null) {
      lastNameController.text = widget.user!.lastName!;
      firstNameController.text = widget.user!.firstName!;
      emailController.text = widget.user!.email!;
      cellphoneController.text = widget.user!.cellphone!;
      setState(() {});
    }
    if (selectedUser != null) {
      lastNameController.text = selectedUser!.lastName!;
      firstNameController.text = selectedUser!.firstName!;
      emailController.text = selectedUser!.email!;
      cellphoneController.text = selectedUser!.cellphone ?? '';
      setState(() {});
    }
  }

  List<User> users = [];
  String? userType;

  Widget getDropDown() {
    var drop = DropdownButton<String>(
      hint: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
    setState(() {
      busy = true;
    });
    try {
      var allUsers = await listApiDog.getAssociationUsers(
          widget.association.associationId!, true);
      pp('$mm association users found: ${users.length}');

      for (var u in allUsers) {
        if ((u.firstName!.contains('admin') && u.lastName!.contains('admin')) ||
            (u.firstName!.contains('vehicle') &&
                u.lastName!.contains('vehicle')) || (u.firstName!.contains('ASSOCIATION') && u.lastName!.contains('ASSOCIATION'))) {
          pp('$mm ignore user: ${u.firstName} ${u.lastName}');
        } else {
          users.add(u);
        }
      }
      users.sort((a, b) => a.firstName!.compareTo(b.firstName!));
      if (users.isEmpty) {
        _showEditor = true;
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
      selectedUser = User(
          userId: Uuid().v4(),
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


        var res = await dataApiDog.addUser(selectedUser!);
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
  PlatformFile? thumbFile;

  List<User> usersFromCsv = [];
  PlatformFile? userFile;
  CloudStorageBloc storage = GetIt.instance<CloudStorageBloc>();

  _pickProfilePicture(User user) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.media, dialogTitle: 'Staff Profile Picture');

    if (result != null) {
      userFile = result.files.first;
      pp('$mm _pickProfilePicture: userFile picked: ${userFile?.bytes!.length} bytes');
      _showUploadDialog(user);
    } else {
      pp('$mm Error: File bytes are null');
      if (mounted) {
        showErrorToast(message: 'The file is not cool', context: context);
      }
    }
  }

  _showUploadDialog(User user) async {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Upload Profile Picture'),
            content: Text('Confirm the profile picture upload'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startProfileUpload(user);
                  },
                  child: Text('Upload File')),
            ],
          );
        });
  }

  _startProfileUpload(User user) async {
    pp('$mm ..................... _startProfileUpload ...');
    setState(() {
      busy = true;
    });
    try {
      // thumbFile = await getPhotoThumbnail(file: userFile!);
      // await dataApiDog.upl(
      //     file: userFile!, thumb: userFile!, userId: user.userId!);
      _getUsers();
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    pp('$mm profile picture uploaded: ${userFile!.bytes?.length} bytes');
    setState(() {
      busy = false;
    });
  }

  String? csvString;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, dialogTitle: 'Staff Data File');

    if (result != null) {
      csvFile = result.files.first;
      pp('$mm csvFile exists: ${csvFile?.bytes!.length} bytes');
      csvString = utf8.decode(csvFile!.bytes!);
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

  AddUsersResponse addUsersResponse = AddUsersResponse([], []);

  _sendFile() async {
    setState(() {
      busy = true;
    });
    addUsersResponse = AddUsersResponse([], []);
    try {
      usersFromCsv = getUsersFromCsv(
          csv: csvString!,
          countryId: widget.association.countryId!,
          associationId: widget.association.associationId!,
          associationName: widget.association.associationName!);

      pp('$mm  upload the Users found in File ... 🍎 ${users.length} 🍎');

      for (var user in usersFromCsv) {
        setState(() {
          firstNameController.text = user.firstName!;
          lastNameController.text = user.lastName!;
          emailController.text = user.email!;
          cellphoneController.text = user.cellphone!;
          passwordController.text = user.password ?? 'pass123';
        });
        try {
          user.userId = Uuid().v4();
          user.password = 'pass123';

          var res = await dataApiDog.addUser(user);
          addUsersResponse.users.add(res);
        } catch (e) {
          pp('😈😈😈😈😈 $e\n$e');
          addUsersResponse.errors.add(user);
        }
      }

      firstNameController.text = '';
      lastNameController.text = '';
      emailController.text = '';
      cellphoneController.text = '';
      passwordController.text = '';

      pp('$mm  users registered: 🍎 ${addUsersResponse.users.length}');
      pp('$mm  😈😈 users fucked up: 🍎 ${addUsersResponse.errors.length}');

      _getUsers();
      if (mounted) {
        if (addUsersResponse.errors.isNotEmpty) {
          showErrorToast(
              message:
                  'Upload encountered ${addUsersResponse.errors.length} errors',
              context: context);
        } else {
          var msg = '🌿 Staff uploaded OK: ${addUsersResponse.users.length}';

          showOKToast(message: msg, context: context);
        }
      }
    } catch (e, s) {
      pp('$mm 😈😈😈😈😈$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  int? userIndex;
  bool _showTools = false;
  bool _showEditor = false;

  _showToolbar(int index) {
    setState(() {
      userIndex = index;
      _showTools = !_showTools;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                _showEditor
                    ? SizedBox(
                        width: 480,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                gapH32,
                                gapH32,
                                Text(
                                  'Pick the Staff Members File',
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
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.all(16)),
                                          textStyle: WidgetStatePropertyAll(
                                              myTextStyleMediumLargeWithColor(
                                                  context, Colors.pink, 16))),
                                      onPressed: () {
                                        _pickFile();
                                      },
                                      child: Text('Get File')),
                                ),
                                gapH16,
                                csvFile == null
                                    ? gapH4
                                    : SizedBox(
                                        width: 400,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                // backgroundColor: WidgetStatePropertyAll(
                                                //     Colors.blue.shade800),
                                                backgroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(Colors.blue),
                                                // Change button color
                                                foregroundColor:
                                                    WidgetStateProperty.all<
                                                        Color>(Colors.white),
                                                elevation:
                                                    WidgetStatePropertyAll(8),
                                                padding: WidgetStatePropertyAll(
                                                    EdgeInsets.all(24)),
                                                textStyle: WidgetStatePropertyAll(
                                                    myTextStyleMediumLargeWithColor(
                                                        context,
                                                        Colors.blue,
                                                        18))),
                                            onPressed: () {
                                              _sendFile();
                                            },
                                            child: Text('Send Users File')),
                                      ),
                                gapH16,
                                usersFromCsv.isEmpty
                                    ? gapW16
                                    : Row(
                                        children: [
                                          const Text('Number of User in File'),
                                          gapW32,
                                          Text(
                                            '${usersFromCsv.length}',
                                            style: myTextStyleMediumLarge(
                                                context, 24),
                                          ),
                                        ],
                                      ),
                                csvFile == null ? gapH8 : gapH16,
                                gapH16,
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
                                gapH16,
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
                                gapH16,
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
                                gapH16,
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
                                gapH16,
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
                                gapH16,
                                getDropDown(),
                                gapH32,
                                userType == null
                                    ? gapW8
                                    : SizedBox(
                                        height: 64,
                                        child: Center(
                                          child: Text(
                                            '$userType',
                                            style:
                                                myTextStyleMediumLargeWithSize(
                                                    context, 20),
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
                                              elevation:
                                                  WidgetStatePropertyAll(8),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            onPressed: () {
                                              _onSubmit();
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Text('Submit',
                                                    style: myTextStyle(
                                                        color: Colors.white)))),
                                      ),
                              ],
                            )),
                      )
                    : gapH32,
                _showEditor ? gapH8 : gapH32,
                gapH32,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemCount: users.length,
                        itemBuilder: (_, index) {
                          var user = users[index];
                          return GestureDetector(
                            onTap: () {
                              selectedUser = user;
                              _setup();
                              _showToolbar(index);
                            },
                            child: Card(
                              elevation: 8,
                              child: SizedBox(
                                height: 360,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showToolbar(index);
                                      },
                                      child: UserProfilePicture(
                                        user: user,
                                      ),
                                    ),
                                    gapH8,
                                    Text(
                                      '${user.firstName} ${user.lastName}',
                                      style: myTextStyle(
                                          weight: FontWeight.normal,
                                          fontSize: 14),
                                    ),
                                    gapH4,
                                    Text(
                                      '${user.userType}',
                                      style: myTextStyle(
                                          weight: FontWeight.w200,
                                          fontSize: 10),
                                    ),
                                    if (_showTools && userIndex == index)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 4),
                                        child: Card(
                                          elevation: 8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    pp('$mm ... get and upload profile picture');
                                                    _pickProfilePicture(user);
                                                  },
                                                  icon: Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Colors.pink)),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.teal,
                                                  )),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.email,
                                                      color: Colors.blue)),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            top: 16,
            child: Row(
              children: [
                Text(
                  'Staff Members',
                  style: myTextStyle(weight: FontWeight.w900, fontSize: 20),
                ),
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
                gapW32,
                gapW32,
                _showEditor
                    ? IconButton(
                        tooltip: 'Close Editor Form',
                        onPressed: () {
                          setState(() {
                            _showEditor = false;
                          });
                        },
                        icon: Icon(Icons.close))
                    : IconButton(
                        tooltip: 'Open Editor Form',
                        onPressed: () {
                          setState(() {
                            _showEditor = true;
                          });
                        },
                        icon: Icon(Icons.edit))
              ],
            ),
          ),
          busy
              ? Positioned(
                  child: Center(
                      child: TimerWidget(
                          title: 'Loading data ...', isSmallSize: true)),
                )
              : gapW32,
        ],
      )),
    );
  }
}

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    if (user.profileUrl == null) {
      return SizedBox(
        width: 64,
        height: 64,
        child: Image.asset(
          'assets/avatar1.png',
          height: 64,
          width: 64,
          fit: BoxFit.cover,
        ),
      );
    }
    return SizedBox(
        width: 64,
        height: 64,
        child: CircleAvatar(
          backgroundImage: NetworkImage(user.profileUrl!),
          radius: 64,
        ));
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
