class User {
  String _domain;
  String _username;
  String _apiKey;
  DateTime _apiExpiry;
  String _name;


  /// default constructor
  User(
    this._username,
    this._domain,
    this._apiExpiry,
    this._apiKey,
    this._name
  );

  /// the object we create when logging in.
  /// we update it later with name_processed
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

  /// converts a dynamic map from JSON to an
  /// actual User object
  factory User.fromJSON(dynamic data) => new User(
    data["username"],
    data["domain"],
    DateTime.parse(data["expiry"]),
    data["key"],
    data["name"],
  );

  /// GETTERS
  String get username => _username;
  String get domain => _domain;
  String get apiKey => _apiKey;
  String get name => _name;
  DateTime get apiExpiry => _apiExpiry;


  /// converts a User object to a JSON
  /// ready map structure.
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["domain"] = _domain;
    map["key"] = _apiKey;
    map["expiry"] = _apiExpiry.toString();
    map["name"] = _name;

    return map;
  }


  /// updates the users name after 
  /// an API request for it.
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