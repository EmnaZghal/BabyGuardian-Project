class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? endpoint;
  final String? rawBody;

  ApiException(
    this.statusCode,
    this.message, {
    this.endpoint,
    this.rawBody,
  });

  String debugString() {
    return 'HTTP $statusCode\n'
        'ENDPOINT: ${endpoint ?? "-"}\n\n'
        'MESSAGE:\n$message\n\n'
        'RAW BODY:\n${rawBody?.isEmpty ?? true ? "(empty body)" : rawBody}';
  }

  @override
  String toString() => message;
}
