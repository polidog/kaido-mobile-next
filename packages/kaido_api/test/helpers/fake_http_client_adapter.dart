import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef ResponseBuilder = ResponseBody Function(RequestOptions options);

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter({required this.onRequest});

  final ResponseBuilder onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody jsonResponse(
    Object? data, {
    int statusCode = 200,
  }) {
    final jsonStr = json.encode(data);
    return ResponseBody.fromString(jsonStr, statusCode, headers: {
      'content-type': ['application/json'],
    });
  }
}
