import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/country_selection.dart';

class AssociationEdit extends StatefulWidget {
  const AssociationEdit({super.key, this.association});

  final Association? association;

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
      adminLastNameController.text = widget.association!.adminUserLastName!;
      adminFirstNameController.text = widget.association!.adminUserFirstName!;
      emailController.text = widget.association!.adminEmail!;
      cellphoneController.text = widget.association!.adminCellphone!;
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
    if (widget.association == null) {
      association = Association(
        associationId: '${DateTime.now().millisecondsSinceEpoch}',
        associationName: nameController.text,
        countryId: country!.countryId,
        countryName: country!.name,
        adminUserFirstName: adminFirstNameController.text,
        adminUserLastName: adminLastNameController.text,
        adminCellphone: cellphoneController.text,
        adminEmail: emailController.text,
        password: passwordController.text,
      );

      try {
        var res = await dataApiDog.registerAssociation(association!);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Association',
          style: myTextStyleMediumLarge(context, 24),
        ),
      ),
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
                        'Select the country',
                        style: myTextStyleMediumLarge(context, 20),
                      ),
                      gapH16,
                      CountryChooser(
                          onSelected: (c) {
                            pp('$mm ... country: ${c.toJson()}');
                            setState(() {
                              country = c;
                            });
                          },
                          hint: 'Select Country',
                          refreshCountries: false),
                      gapH32,
                      country == null
                          ? gapH32
                          : Text(
                              country!.name!,
                              style: myTextStyleMediumLarge(context, 28),
                            ),
                      country == null ? gapH8 : gapH32,
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          label: Text('Association Name'),
                          hintText: 'Enter Association Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Association Name';
                          }
                        },
                      ),
                      gapH8,
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
                        },
                      ),
                      gapH8,
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
                        },
                      ),
                      gapH8,
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
                        },
                      ),
                      gapH8,
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
                        },
                      ),
                      gapH32,
                      gapH32,
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
          )
        ],
      )),
    );
  }
}
