import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:mime/mime.dart';

class FuelBrandEditor extends StatefulWidget {
  const FuelBrandEditor({super.key});

  @override
  FuelBrandEditorState createState() => FuelBrandEditorState();
}

class FuelBrandEditorState extends State<FuelBrandEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  final Prefs prefs = GetIt.instance<Prefs>();
  final SemCache semCache = GetIt.instance<SemCache>();
  List<lib.FuelBrand> fuelBrands = [];
  bool busy = false;
  bool showEditor = false;
  static const mm = '🥦🥦🥦🥦🥦 FuelBrandEditor: 🥦🥦';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getFuelBrands(false);
  }

  _getFuelBrands(bool refresh) async {
    pp('$mm _getFuelBrands ....');
    setState(() {
      busy = true;
    });
    fuelBrands = await listApiDog.getFuelBrands(refresh);
    pp('$mm _getFuelBrands .... ${fuelBrands.length}');

    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? url;

  void _getLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    var file = await xFileToPlatformFile(image);
    if (file != null) {
      url = await dataApiDog.uploadFuelBrandLogo(
          file: file, fuelBrandId: DateTime.now().toIso8601String());
      pp('$mm logo file uploaded; url: 🥬 $url 🥬');
      setState(() {});
    }
  }

  Future<PlatformFile?> xFileToPlatformFile(XFile? xFile) async {
    if (xFile == null) {
      return null;
    }

    var mimeType = lookupMimeType(xFile.path);
    final bytes = await xFile.readAsBytes();

    platformFile = PlatformFile(
      name: xFile.name,
      path: xFile.path,
      bytes: bytes,
      size: bytes.length,
      identifier:
          '${DateTime.now().millisecondsSinceEpoch}', // You might want to generate a unique identifier
    );
    return platformFile;
  }

  PlatformFile? platformFile;
  final TextEditingController nameController = TextEditingController();

  void _submit() async {
    if (platformFile == null) {
      return;
    }
    if (nameController.text.isEmpty) {
      return;
    }
    setState(() {
      busy = true;
    });
    var fuelBrand =
        lib.FuelBrand(brandName: nameController.text, logoUrl: url!);
    var res = await dataApiDog.addFuelBrand(fuelBrand);
    pp('$mm result: ${res.toJson()}');
   _getFuelBrands(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Fuel Brands'),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        gapH32,
                        ElevatedButton(
                          style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(8),
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.grey)),
                          onPressed: () {
                            _getLogo();
                          },
                          child: Padding(padding: EdgeInsets.all(8), child: Text(
                            'Get Logo File',
                            style: myTextStyle(color: Colors.white),
                          ),)
                        ),
                        gapH32,

                        platformFile == null
                            ? gapW32
                            : Text(platformFile!.name),
                        gapH32,
                        url == null
                            ? gapW32
                            : CachedNetworkImage(
                                height: 200, width: 200, imageUrl: url!),
                        gapH32,
                        gapH32,
                        SizedBox(
                          height: 64,
                          child: Form(
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                  label: Text('Fuel Brand Name'),
                                  hintText:
                                      'Enter the name of the company providing fuel',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ),
                        gapH32,
                        gapH32,
                        url == null? gapW32: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: WidgetStatePropertyAll(12),
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue)),
                            onPressed: () {
                              _submit();
                            },
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Save Brand',
                                    style: myTextStyle(color: Colors.white))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                gapW32, gapW32,
                Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 400,
                      child: ListView.builder(
                          itemCount: fuelBrands.length,
                          itemBuilder: (_, index) {
                            var b = fuelBrands[index];
                            return Card(
                              child: Row(
                                children: [
                                  SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: CachedNetworkImage(
                                        imageUrl: b.logoUrl!,
                                      )),
                                  gapW32,
                                  Text(b.brandName!),
                                ],
                              ),
                            );
                          }),
                    )),
              ],
            ),
            busy
                ? Positioned(
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.pink,
                    )),
                  )
                : gapW32,
          ],
        )));
  }
}
