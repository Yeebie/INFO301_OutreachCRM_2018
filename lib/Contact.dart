///Edited version of contact_data.dart, doesn't use final and const, has getter & setter methods
class Contact {
  String fullName;

  //Constructor
  Contact({this.fullName});

  //Getter method
  String getFullName() {
    return fullName;
  }

  //Setter Method
  void setFullName(String fullName) {
    this.fullName = fullName;
  }
}