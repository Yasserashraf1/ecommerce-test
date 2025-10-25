import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:naseej/core/class/statusrequest.dart';
import 'package:naseej/core/functions/checkinternet.dart';
import 'package:http/http.dart' as http;

class Crud {
  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        print("========== Sending Request to: $linkurl");
        print("========== Request Data: $data");

        var response = await http.post(Uri.parse(linkurl), body: data);

        print("========== Response Status Code: ${response.statusCode}");
        print("========== Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("========== Error in Crud.postData: $e");
      return const Left(StatusRequest.serverException);
    }
  }
}