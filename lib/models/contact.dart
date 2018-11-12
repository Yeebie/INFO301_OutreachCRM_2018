

class Contact {
  String _name;
  String _uid;

  String get name => _name;
  String get uid => _uid;

  Contact({String name, String uid}) {
    this._uid = uid;
    this._name = name;
  }

  Contact.map(dynamic data) {
    this._name = data["name_processed"];
    this._uid = data["oid"];
  }
}