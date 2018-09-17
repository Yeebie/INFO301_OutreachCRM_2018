import 'package:flutter/material.dart';
import 'ContactPage.dart';
import 'package:validate/validate.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

import 'package:outreachcrm_app/SupportClasses.dart';

///***************************************************************************
///                  A P I   K E Y   R E T R I E V A L
///***************************************************************************

///Represents the bits inside the nested json
class APIKeyRetrievalData {
  String key;
  String expiry;
  bool passwordVerify;

  //Constructor
  APIKeyRetrievalData({this.key, this.expiry, this.passwordVerify});

  //Getter method
  String getAPIKey() {
    return key;
  }

  //Getter method
  String getExpiry() {
    return expiry;
  }

  //Getter method
  bool getPasswordVerify() {
    return passwordVerify;
  }

  //Soft of like a method that'll be executed somewhere
  factory APIKeyRetrievalData.fromJson(Map<String, dynamic> json) {
    return APIKeyRetrievalData(
        key: json['key'],
        expiry: json['expiry'],
        passwordVerify: json['password']);
  }
}

///Represents the base json, the data array
class APIKeyRetrievalJson {
  //Datafields
  APIKeyRetrievalData data;

  //Constructor
  APIKeyRetrievalJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory APIKeyRetrievalJson.fromJson(Map<String, dynamic> parsedJson) {
    return APIKeyRetrievalJson(
        data: APIKeyRetrievalData.fromJson(parsedJson['data']));
  }
}

///***************************************************************************
///                  A P I   K E Y   V A L I D A T I O N
///***************************************************************************

///Represents the bits inside the nested json
class APIKeyValidationData {
  bool verify;
  String expiry;
  String oid;

  //Constructor
  APIKeyValidationData({this.verify, this.expiry, this.oid});

  //Getter method
  bool getVerify() {
    return verify;
  }

  //Getter method
  String getExpiry() {
    return expiry;
  }

  //Getter method
  String getOid() {
    return oid;
  }

  //Soft of like a method that'll be executed somewhere
  factory APIKeyValidationData.fromJson(Map<String, dynamic> json) {
    return APIKeyValidationData(
        verify: json['verify'], expiry: json['expiry'], oid: json['oid']);
  }
}

///Data is different between requests, we need to copy this format multiple times
///Represents the base json, the data array
class APIKeyValidationJson {
  //Datafields
  APIKeyValidationData data;

  //Constructor
  APIKeyValidationJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory APIKeyValidationJson.fromJson(Map<String, dynamic> parsedJson) {
    return APIKeyValidationJson(
        data: APIKeyValidationData.fromJson(parsedJson['data']));
  }
}

///***************************************************************************
///             C O N T A C T S   L I S T   R E T R I E V A L
///***************************************************************************

///Data is different between requests, we need to copy this format multiple times
///Represents the base json, the data array
class ContactListJson {
  //Datafields
  List<ContactListData> data;

  //Constructor
  ContactListJson({this.data});

  //Soft of like a method that'll be executed somewhere
  factory ContactListJson.fromJson(Map<String, dynamic> json) {
    var list = json["data"] as List;
    List<ContactListData> dataList =
        list.map((i) => ContactListData.fromJson(i)).toList();
    return ContactListJson(data: dataList);
  }
}

///Represents the bits inside the nested json
class ContactListData {
  //Datafields
  String nameProcessed;
  String oid;
  String o_company;

  //Constructor
  ContactListData({this.nameProcessed, this.oid, this.o_company});

  //Getter method
  String getNameProcessed() {
    return nameProcessed;
  }

//Getter method
  String getOid() {
    return oid;
  }

//Getter method
  String getCompany() {
    return o_company;
  }

  //Soft of like a method that'll be executed somewhere
  factory ContactListData.fromJson(Map<String, dynamic> json) {
    return ContactListData(
        nameProcessed: json["name_processed"],
        oid: json["oid"],
        o_company: json["o_company"]);
  }
}

///***************************************************************************
///                  I N D I V I D U A L   C O N T A C T
///***************************************************************************
class Contact {
  String fullName;
  String oid;
  String company;

  //Constructor
  Contact({this.fullName, this.oid, this.company});

  //Getter method
  String getFullName() {
    return fullName;
  }

  //Getter method
  String getOid() {
    return oid;
  }

  //Getter method
  String getCompany() {
    return company;
  }

  //Setter Method
  void setFullName(String fullName) {
    this.fullName = fullName;
  }

  //Setter Method
  void setOid(String oid) {
    this.oid = oid;
  }

  //Setter Method
  void setCompany(String company) {
    this.company = company;
  }
}