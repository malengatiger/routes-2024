import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/error_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';

class DataApi {
  static const mm = '🌎🌎🌎🌎🌎🌎 DataApi: 🌎🌎';
  static const timeOutInSeconds = 360;
  String? token;
  late http.Client client;
  late AppAuth appAuth;
  late CacheManager cacheManager;
  late Prefs prefs;
  late ErrorHandler errorHandler;
  late SemCache semCache;

  DataApi() {
    init();
  }

  void init() async {
    url = KasieEnvironment.getUrl();
    appAuth = AppAuth(firebaseAuth: auth.FirebaseAuth.instance);
    client = http.Client();
    prefs = Prefs(await SharedPreferences.getInstance());
    semCache = SemCache();
    errorHandler = ErrorHandler(DeviceLocationBloc(), prefs);
  }

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> zipHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/zip',
  };
  late String url;

  Future<AddCarsResponse?> importVehiclesFromCSV(
      PlatformFile file, String associationId) async {
    pp('$mm importVehiclesFromCSV: 🌿 associationId: $associationId');

    var url = KasieEnvironment.getUrl();
    var mUrl =
        '${url}vehicle/importVehiclesFromCSV?associationId=$associationId';

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    headers['Authorization'] = 'Bearer $token';

    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    }
    if (kIsWeb) {
      // For web, read bytes as string
      final fileContents = utf8.decode(file.bytes!);
      pp('$mm 🌿🌿🌿🌿File contents:\n$fileContents 🌿');
    } else {
      // For mobile/desktop, read file from path
      final fileContents = await io.File(file.path!).readAsString();
      pp('$mm 🌿🌿🌿🌿 File contents:\n$fileContents File');
    }
    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = AddCarsResponse.fromJson(mJson);
      for (var c in result.cars) {
        pp('$mm car added: ${c.vehicleReg}');
      }
      for (var c in result.errors) {
        pp('$mm car fucked up: ${c.vehicleReg}');
      }
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Vehicles File upload failed');
  }

  Future<AddUsersResponse?> importUsersFromCSV(
      PlatformFile file, String associationId) async {
    pp('$mm importUsersFromCSV: 🌿 associationId: $associationId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}user/importUsersFromCSV?associationId=$associationId';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    }
    if (kIsWeb) {
      // For web, read bytes as string
      final fileContents = utf8.decode(file.bytes!);
      pp('$mm 🌿🌿🌿🌿File contents:\n$fileContents 🌿');
    } else {
      // For mobile/desktop, read file from path
      final fileContents = await io.File(file.path!).readAsString();
      pp('$mm 🌿🌿🌿🌿 File contents:\n$fileContents File');
    }
    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = AddUsersResponse.fromJson(mJson);
      for (var c in result.users) {
        pp('$mm user added: ${c.firstName} ${c.lastName} - ${c.userType}');
      }
      for (var c in result.errors) {
        pp('$mm user fucked up: ${c.firstName} ${c.lastName} - ${c.userType}');
      }
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Users File upload failed');
  }

  Future<VehiclePhoto> uploadVehiclePhoto(
      {required PlatformFile file,
      required PlatformFile thumb,
      required String vehicleId,
      required double latitude,
      required double longitude}) async {
    pp('$mm importVehicleProfile: 🌿........... userId: $vehicleId');

    var url = KasieEnvironment.getUrl();
    var mUrl =
        '${url}storage/uploadVehiclePhoto?vehicleId=$vehicleId&latitude=$latitude&longitude=$longitude';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        file.bytes!,
        filename: file.name,
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'thumbFile',
        thumb.bytes!,
        filename: thumb.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files
          .add(await http.MultipartFile.fromPath('imageFile', file.path!));
      request.files
          .add(await http.MultipartFile.fromPath('thumbFile', thumb.path!));
    }

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('\n\n$mm Yebo! Vehicle photo file uploaded successfully! 🥬🥬🥬🥬🥬\n');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = VehiclePhoto.fromJson(mJson);
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Vehicle photo file upload failed');
  }

  Future<User> importUserProfile(
      {required PlatformFile file,
      required PlatformFile thumb,
      required String userId}) async {
    pp('$mm importUserProfile: 🌿 userId: $userId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}storage/uploadUserProfilePicture?userId=$userId';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        file.bytes!,
        filename: file.name,
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'thumbFile',
        thumb.bytes!,
        filename: thumb.name,
      ));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('imageFile', file.path!));
      request.files
          .add(await http.MultipartFile.fromPath('thumbFile', thumb.path!));
    }

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('\n\n$mm File uploaded successfully! 🥬🥬🥬🥬🥬\n');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = User.fromJson(mJson);
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Users File upload failed');
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final bag = vehicle.toJson();
    final cmd = '${url}vehicle/updateVehicle';

    final res = await _callPost(cmd, bag);

    ListApiDog dog = GetIt.instance<ListApiDog>();
    var photos = await dog.getVehiclePhotos(vehicle, true);
    var videos = await dog.getVehicleVideos(vehicle, true);
    vehicle.photos = photos;
    vehicle.videos = videos;

    // semCache.saveVehicles([vehicle]);
    pp('$mm vehicle added or updated on Atlas database and local cache : 🥬 🥬 🥬 '
        ' ${vehicle.vehicleReg}');
    return res;
  }

  Future<User> addUser(User user) async {
    final bag = user.toJson();
    final cmd = '${url}user/addUser';
    final res = await _callPost(cmd, bag);
    // semCache.saveUsers([user]);
    pp('$mm user added to database: 🥬 🥬 ');
    return User.fromJson(res);
  }

  static const dev = '👿👿👿';

  Future<String?> getAuthToken() async {
    pp('$mm getAuthToken: ...... Getting Firebase token ......');
    try {
      var m = await appAuth.getAuthToken();
      if (m == null) {
        pp('$mm Unable to get Firebase token');
        return null;
      } else {
        pp('$mm Firebase token retrieved OK ✅ ');
        return m;
      }
    } catch (e, s) {
      pp('$mm $e $s');
      rethrow;
    }
  }

  Future _callPost(String mUrl, dynamic bag) async {
    pp('$mm  ......... _callWebAPIPost calling: $mUrl');

    String? mBag;
    mBag = json.encode(bag);
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var start = DateTime.now();
    token ??= await getAuthToken();
    if (token == null) {
      throw Exception('token not found');
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .post(
              Uri.parse(mUrl),
              body: mBag,
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        pp('$mm  _callWebAPIPost RESPONSE: 👌👌👌 statusCode: ${resp.statusCode} 👌👌👌 for $mUrl');

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          try {
            var mJson = json.decode(resp.body);
            return mJson;
          } catch (e) {
            pp("$mm $dev  $dev  json.decode failed, returning response body");
            return resp.body;
          }
        } else {
          if (resp.statusCode == 401 || resp.statusCode == 403) {
            pp('$mm  $dev  _callWebAPIPost: 🔆 statusCode:  ${resp.statusCode} $dev for $mUrl');
            pp('$mm metadata: ${resp.body}');
            pp('$mm  $dev  _callWebAPIPost: 🔆 Firebase ID token may have expired, trying to refresh ... 🔴🔴🔴🔴🔴🔴 ');
            token = await getAuthToken();

            pp('$mm Throwing my toys!!! : 💙 statusCode: ${resp.statusCode} $dev  ');
            final gex = KasieException(
                message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
                url: mUrl,
                translationKey: 'serverProblem',
                errorType: KasieException.socketException);
            errorHandler.handleError(exception: gex);
            throw Exception('The status is BAD, Boss!');
          } else {
            if (resp.statusCode == 400 || resp.statusCode == 500) {
              final gex = KasieException(
                  message:
                      'Bad status code: ${resp.statusCode} - ${resp.body}, please try again',
                  url: mUrl,
                  translationKey: 'serverProblem',
                  errorType: KasieException.socketException);
              errorHandler.handleError(exception: gex);
              throw Exception('The status is BAD, Boss!');
            }
          }
        }
        var end = DateTime.now();
        pp('$mm  _callWebAPIPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆 $mUrl');
      } on io.SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on io.HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }

  Future _sendHttpGET(String mUrl) async {
    pp('$mm _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var token = await appAuth.getAuthToken();
    if (token != null) {
      pp('$mm _sendHttpGET: 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 ');
    } else {
      pp('$mm Firebase token missing ${E.redDot}${E.redDot}${E.redDot}${E.redDot}');
      final gex = KasieException(
          message: 'Firebase Authentication token missing',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .get(
              Uri.parse(mUrl),
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        pp('$mm http GET call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
        var end = DateTime.now();
        pp('$mm http GET call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

        if (resp.body.contains('not found')) {
          return false;
        }

        if (resp.statusCode == 403) {
          var msg =
              '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
          pp(msg);
          final gex = KasieException(
              message: 'Forbidden call',
              url: mUrl,
              translationKey: 'serverProblem',
              errorType: KasieException.httpException);
          errorHandler.handleError(exception: gex);
          throw gex;
        }

        if (resp.statusCode != 200) {
          var msg =
              '😡 😡 The response is not 200; it is ${resp.statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
          pp(msg);
          final gex = KasieException(
              message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
              url: mUrl,
              translationKey: 'serverProblem',
              errorType: KasieException.socketException);
          errorHandler.handleError(exception: gex);
          throw gex;
        }
        var mJson = json.decode(resp.body);
        return mJson;
      } on io.SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on io.HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }
}
