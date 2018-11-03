class User {
  String _domain;
  String _username;
  String _apiKey;
  DateTime _apiExpiry;
  String _name;

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

    print("CREATING USER OBJECT { "
    "\n\tapi_key: $_apiKey"
    "\n\tapi_expiry: $_apiExpiry"
    "\n\tusername: $_username"
    "\n\tdomain: $_domain"
    "\n}");
  }

  String get username => _username;
  String get domain => _domain;
  String get apiKey => _apiKey;
  String get name => _name;
  DateTime get apiExpiry => _apiExpiry;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["domain"] = _domain;
    map["api_key"] = _apiKey;
    map["api_expiry"] = _apiExpiry.toString();
    map["name"] = _name;

    return map;
  }

  void updateNameFromJSON(dynamic data) {
    var list = data['data'] as List;
    var name = list[0]["name_processed"];
    
    name == null 
    ? this._name = ""
    : this._name = name;
      print("UPDATING USER OBJECT {"
       "\n\tname: $_name"
       "\n}");
  }
}