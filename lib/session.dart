import 'dart:io';
import 'dart:convert';
import './debug.dart';


/* used builtin class instead of lib:http.dart cuz it doesn't provide history of
  redirects. Location header is used to figure out whether the login/logout was
  successful or not.*/


class Session {
  HttpClient client = HttpClient();
  Map<String, String> headers = {};

  Session({Map<String, String>? headers = null}) {
    if (headers != null) {
      this.headers = {...this.headers, ...headers};
    }
  }

  void close([HttpClientResponse? response]) {
    response?.drain();
    client.close(force: true);
  }

  Future<HttpClientResponse> get(String url) async {
    // warning: always read the returned response or .drain() to prevent memory leaks.
    debug('GET: $url');
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    headers.forEach((String name, String value) {
      request.headers.set(name, value);
    });
    // send the request and wait for a response
    HttpClientResponse response = await request.close();
    return response;
  }

  Future<String> getAndText(String url) async {
    String body = '';
    HttpClientResponse response = await get(url);
    await response
        .transform(utf8.decoder)
        .listen((String contents) {
            // comes in stream. hence append.
            body += contents;
        })
        .asFuture();
    return body;
  }

  Future<HttpClientResponse> post(String url,
      {Map<String, String>? body: null}) async {
    debug('POST: $url');
    debug('BODY: $body');
    // warning: always read the returned response or .drain() to prevent memory leaks.
    HttpClientRequest request = await client.postUrl(Uri.parse(url));
    headers.forEach((String name, String value) {
      request.headers.set(name, value);
    });
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
    // requests is chunked by default. disable it. then provide content length too.
    request.headers.chunkedTransferEncoding = false;

    // prepare urlencoded body
    List<String> forms = [];
    if (body != null)
      body.forEach((String k, String v) =>
          forms.add(Uri.encodeComponent(k) + '=' + Uri.encodeComponent(v)));
    String requestBody = forms.join('&');
    debug('BODY(encoded): $requestBody');
    // manually provide content-length cuz chunked transfer is disabled
    request.contentLength = requestBody.length;

    // write to body
    request.write(requestBody);
    print('URL: ' + url);
    print('BODY: ' + requestBody);
    // send the request and wait for a response
    HttpClientResponse response = await request.close();
    return response;
  }

  Future<String> postAndText(String url,
      {Map<String, String>? body: null}) async {
    String responseBody = '';
    HttpClientResponse response = await post(url, body: body);
    await response
        .transform(utf8.decoder)
        .listen((String contents) {
          responseBody += contents;
        })
        .asFuture();
    return responseBody;
  }
}
