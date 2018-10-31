class User {
  String _domain;
  String _username;
  String _apiKey;
  DateTime _apiExpiry;

  User(
    this._username,
    this._domain,
    this._apiExpiry,
    this._apiKey
  );

  User.map(dynamic data, String username, String domain) {
    this._apiKey = data["key"];
    this._apiExpiry = DateTime.parse(data["expiry"]);
    this._domain = domain;
    this._username = username;
  }

  String get username => _username;
  String get domain => _domain;
  String get apiKey => _apiKey;
  DateTime get apiExpiry => _apiExpiry;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["domain"] = _domain;
    map["api_key"] = _apiKey;
    map["api_expiry"] = _apiExpiry.toString();

    return map;
  }
}