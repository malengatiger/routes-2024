import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/country_selection.dart';
import 'package:uuid/v4.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssociationEdit extends StatefulWidget {
  const AssociationEdit({super.key, this.association, required this.onClose});

  final Association? association;
  final Function onClose;

  @override
  AssociationEditState createState() => AssociationEditState();
}

class AssociationEditState extends State<AssociationEdit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🌎🌎 🌎🌎 AssociationEdit  🌎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController =
      TextEditingController(text: 'Development Taxi Association');
  TextEditingController adminFirstNameController =
      TextEditingController(text: 'Administrator');
  TextEditingController adminLastNameController =
      TextEditingController(text: 'ADMIN');
  TextEditingController emailController =
      TextEditingController(text: 'admin1@association.com');
  TextEditingController cellphoneController =
      TextEditingController(text: '+27999990001');
  TextEditingController passwordController =
      TextEditingController(text: 'pass123');
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  bool busy = false;
  Prefs prefs = GetIt.instance<Prefs>();

  void _setup() async {
    if (widget.association != null) {
      nameController.text = widget.association!.associationName!;
      adminLastNameController.text = widget.association!.adminUser!.lastName!;
      adminFirstNameController.text = widget.association!.adminUser!.firstName!;
      emailController.text = widget.association!.adminUser!.email!;
      cellphoneController.text = widget.association!.adminUser!.cellphone!;
      country = prefs.getCountry();
      setState(() {});
    }
  }

  _onSubmit() async {
    pp('$mm on submit wanted ...');
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (country == null) {
      showErrorToast(
        message: 'Please select the country',
        context: context,
      );
      return;
    }
    setState(() {
      busy = true;
    });
    String id = UuidV4().generate();
    if (widget.association == null) {
      User a = User(
        firstName: adminFirstNameController.text,
        lastName: adminLastNameController.text,
        email: emailController.text,
        cellphone: cellphoneController.text,
        password: passwordController.text,
        userType: Constants.ADMINISTRATOR_ASSOCIATION,
        countryId: country!.countryId,
        associationId: id,
        associationName: nameController.text,
      );
      association = Association(
          associationId: '${DateTime.now().millisecondsSinceEpoch}',
          associationName: nameController.text,
          countryId: country!.countryId,
          countryName: country!.name,
          adminUser: a);

      try {
        await dataApiDog.registerAssociation(association!);
        var s = SettingsModel(
            associationId: association!.associationId!,
            locale: 'en',
            created: DateTime.now().toUtc().toIso8601String(),
            refreshRateInSeconds: 300,
            themeIndex: 0,
            geofenceRadius: 500,
            commuterGeofenceRadius: 500,
            vehicleSearchMinutes: 10,
            heartbeatIntervalSeconds: 300,
            loiteringDelay: 60,
            commuterSearchMinutes: 10,
            commuterGeoQueryRadius: 500,
            vehicleGeoQueryRadius: 10000,
            numberOfLandmarksToScan: 0,
            geofenceRefreshMinutes: 30,
            distanceFilter: 500);

        await dataApiDog.addSettings(s);

        if (mounted) {
          showOKToast(
              message: 'Association registered on KasieTransie',
              context: context);
        }
      } catch (e, s) {
        pp('$e $s');
        if (mounted) {
          showErrorToast(message: '$e', context: context);
        }
      }
    } else {
      //TODO - update the Association
      pp('$mm  update the Association ...');
    }
    setState(() {
      busy = false;
    });
  }

  Country? country;
  Association? association;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 480,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const FaIcon(FontAwesomeIcons.xmark))
                  ],
                ),
                gapH32,
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        gapH16,
                        gapH16,
                        Text(
                          'Association Details',
                          style: myTextStyleMediumLarge(context, 28),
                        ),
                        gapH16,
                        CountryChooser(
                            onSelected: (c) {
                              pp('$mm ... country: ${c.toJson()}');
                              setState(() {
                                country = c;
                              });
                            },
                            hint: '   Select Country',
                            refreshCountries: false),
                        gapH16,
                        country == null
                            ? gapH16
                            : Text(
                                country!.name!,
                                style: myTextStyleMediumLarge(context, 36),
                              ),
                        country == null ? gapH8 : gapH16,
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          style: myTextStyle(
                              fontSize: 20, weight: FontWeight.w900),
                          decoration: InputDecoration(
                            label: Text('Association Name'),
                            hintText: 'Enter Association Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Association Name';
                            }
                            return null;
                          },
                        ),
                        gapH32,
                        TextFormField(
                          controller: adminFirstNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            label: Text('Administrator Name'),
                            hintText: 'Enter Administrator Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Administrator Name';
                            }
                            return null;
                          },
                        ),
                        gapH16,
                        TextFormField(
                          controller: adminLastNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            label: Text('Administrator Surname'),
                            hintText: 'Enter Administrator Surname',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Administrator Surname';
                            }
                            return null;
                          },
                        ),
                        gapH16,
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            label: Text('Administrator Email'),
                            hintText: 'Enter Administrator Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Administrator Email';
                            }
                            return null;
                          },
                        ),
                        gapH16,
                        TextFormField(
                          controller: cellphoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            label: Text('Administrator Cellphone'),
                            hintText: 'Enter Administrator Cellphone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Administrator Cellphone';
                            }
                            return null;
                          },
                        ),
                        gapH32,
                        gapH32,
                        busy
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  backgroundColor: Colors.pink,
                                ),
                              )
                            : SizedBox(
                                width: 400,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        elevation: WidgetStatePropertyAll(8),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Theme.of(context).primaryColor)),
                                    onPressed: () {
                                      _onSubmit();
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text(
                                          'Submit',
                                          style: myTextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ))),
                              ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 24, right: 24,
            child: ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text('Done'))),
      ],
    );
  }
}
