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

///***************************************************************************
///                  V I E W   C O N T A C T   D A T A
///***************************************************************************

class ViewContactJson {
  //Datafields
  List<ViewContactData> data;

  //Constructor
  ViewContactJson({this.data});

  //Sort of like a method that'll be executed somewhere
  factory ViewContactJson.fromJson(Map<String, dynamic> json) {
    var list = json["data"] as List;
    List<ViewContactData> dataList =
        list.map((i) => ViewContactData.fromJson(i)).toList();
    return ViewContactJson(data: dataList);
  }
}

///Data inside JSON data list
class ViewContactData {
  String oid;
  String o_title;
  String o_first_name;
  String o_middle_name;
  String o_last_name;
  String o_suffix;
  String name_mailing;

  String fullName;
  String company;

  String o_mobile_phone;
  String o_company_main_phone;
  String o_business_phone; //DDI Field
  String o_home_phone;
  String o_email_address;
  String o_web_page;
  String o_business_fax;
  String o_home_fax;

  String o_job_title;
  String o_department;
  String o_business_street;
  String o_business_street_2;
  String o_business_street_3;
  String o_business_city;
  String o_business_state;
  String o_business_postal_code;
  String o_po_box;
  String o_business_country;

  String o_home_street;
  String o_home_street_2;
  String o_home_street_3;
  String o_home_city;
  String o_home_state;
  String o_home_postal_code;
  String o_spouse;
  String o_home_country;
  String o_email_2_address;

  //Constructor
  ViewContactData({
    this.oid,
    this.o_title,
    this.o_first_name,
    this.o_middle_name,
    this.o_last_name,
    this.o_suffix,
    this.name_mailing,
    this.fullName,
    this.company,
    this.o_mobile_phone,
    this.o_company_main_phone,
    this.o_business_phone,
    this.o_home_phone,
    this.o_email_address,
    this.o_web_page,
    this.o_business_fax,
    this.o_home_fax,
    this.o_job_title,
    this.o_department,
    this.o_business_street,
    this.o_business_street_2,
    this.o_business_street_3,
    this.o_business_city,
    this.o_business_state,
    this.o_business_postal_code,
    this.o_po_box,
    this.o_business_country,
    this.o_home_street,
    this.o_home_street_2,
    this.o_home_street_3,
    this.o_home_city,
    this.o_home_state,
    this.o_home_postal_code,
    this.o_spouse,
    this.o_home_country,
    this.o_email_2_address,
  });

  String getOid() {
    return oid;
  }

  String getTitle() {
    return o_title;
  }

  String getFirstName() {
    return o_first_name;
  }

  String getMiddleName() {
    return o_middle_name;
  }

  String getLastName() {
    return o_last_name;
  }

  String getSuffix() {
    return o_suffix;
  }

  String getNameMailing() {
    return name_mailing;
  }

  String getFullName() {
    return fullName;
  }

  String getCompany() {
    return company;
  }

  String getMobilePhone() {
    return o_mobile_phone;
  }

  String getCompanyMainPhone() {
    return o_company_main_phone;
  }

  String getBusinessPhone() {
    return o_business_phone;
  }

  String getHomePhone() {
    return o_home_phone;
  }

  String getEmailAddress() {
    return o_email_address;
  }

  String getWebPage() {
    return o_web_page;
  }

  String getBusinessFax() {
    return o_business_fax;
  }

  String getHomeFax() {
    return o_home_fax;
  }

  String getJobTitle() {
    return o_job_title;
  }

  String getDepartment() {
    return o_department;
  }

  String getBusinessStreet() {
    return o_business_street;
  }

  String getBusinessStreet2() {
    return o_business_street_2;
  }

  String getBusinessStreet3() {
    return o_business_street_3;
  }

  String getBusinessCity() {
    return o_business_city;
  }

  String getBusinessState() {
    return o_business_state;
  }

  String getBusinessPostalCode() {
    return o_business_postal_code;
  }

  String getPOBox() {
    return o_po_box;
  }

  String getBusinessCountry() {
    return o_business_country;
  }

  String getHomeStreet() {
    return o_home_street;
  }

  String getHomeStreet2() {
    return o_home_street_2;
  }

  String getHomeStreet3() {
    return o_home_street_3;
  }

  String getHomeCity() {
    return o_home_city;
  }

  String getHomeState() {
    return o_home_state;
  }

  String getHomePostalCode() {
    return o_home_postal_code;
  }

  String getSpouse() {
    return o_spouse;
  }

  String getHomeCountry() {
    return o_home_country;
  }

  String getEmail2Address() {
    return o_email_2_address;
  }

  //Soft of like a method that'll be executed somewhere
  factory ViewContactData.fromJson(Map<String, dynamic> json) {
    return ViewContactData(
      oid: json['oid'],
      o_title: json['o_title'],
      o_first_name: json['o_first_name'],
      o_middle_name: json['o_middle_name'],
      o_last_name: json['o_last_name'],
      o_suffix: json['o_suffix'],
      name_mailing: json['name_mailing'],
      fullName: json['name_processed'],
      company: json['o_company'],
      o_mobile_phone: json['o_mobile_phone'],
      o_company_main_phone: json['o_company_main_phone'],
      o_business_phone: json['o_business_phone'],
      o_home_phone: json['o_home_phone'],
      o_email_address: json['o_email_address'],
      o_web_page: json['o_web_page'],
      o_business_fax: json['o_business_fax'],
      o_home_fax: json['o_home_fax'],
      o_job_title: json['o_job_title'],
      o_department: json['o_department'],
      o_business_street: json['o_business_street'],
      o_business_street_2: json['o_business_street_2'],
      o_business_street_3: json['o_business_street_3'],
      o_business_city: json['o_business_city'],
      o_business_state: json['o_business_state'],
      o_business_postal_code: json['o_business_postal_code'],
      o_po_box: json['o_po_box'],
      o_business_country: json['o_business_country'],
      o_home_street: json['o_home_street'],
      o_home_street_2: json['o_home_street_2'],
      o_home_street_3: json['o_home_street_3'],
      o_home_city: json['o_home_city'],
      o_home_state: json['o_home_state'],
      o_home_postal_code: json['o_home_postal_code'],
      o_spouse: json['o_spouse'],
      o_home_country: json['o_home_country'],
      o_email_2_address: json['o_email_2_address'],
    );
  }
}

class ViewContactFields {
  String oid;
  String o_title;
  String o_first_name;
  String o_middle_name;
  String o_last_name;
  String o_suffix;
  String name_mailing;

  String fullName;
  String company;

  String o_mobile_phone;
  String o_company_main_phone;
  String o_business_phone; //DDI Field
  String o_home_phone;
  String o_email_address;
  String o_web_page;
  String o_business_fax;
  String o_home_fax;

  String o_job_title;
  String o_department;
  String o_business_street;
  String o_business_street_2;
  String o_business_street_3;
  String o_business_city;
  String o_business_state;
  String o_business_postal_code;
  String o_po_box;
  String o_business_country;

  String o_home_street;
  String o_home_street_2;
  String o_home_street_3;
  String o_home_city;
  String o_home_state;
  String o_home_postal_code;
  String o_spouse;
  String o_home_country;
  String o_email_2_address;

  void setOid(String oid) {
    this.oid = oid;
  }

  void setTitle(String o_title) {
    this.o_title = o_title;
  }

  void setFirstName(String o_first_name) {
    this.o_first_name = o_first_name;
  }

  void setMiddleName(String o_middle_name) {
    this.o_middle_name = o_middle_name;
  }

  void setLastName(String o_last_name) {
    this.o_last_name = o_last_name;
  }

  void setSuffix(String o_suffix) {
    this.o_suffix = o_suffix;
  }

  void setNameMailing(String name_mailing) {
    this.name_mailing = name_mailing;
  }

  void setFullName(String fullName) {
    this.fullName = fullName;
  }

  void setCompany(String company) {
    this.company = company;
  }

  void setMobilePhone(String o_mobile_phone) {
    this.o_mobile_phone = o_mobile_phone;
  }

  void setCompanyMainPhone(String o_company_main_phone) {
    this.o_company_main_phone = o_company_main_phone;
  }

  void setBusinessPhone(String o_business_phone) {
    this.o_business_phone = o_business_phone;
  }

  void setHomePhone(String o_home_phone) {
    this.o_home_phone = o_home_phone;
  }

  void setEmailAddress(String o_email_address) {
    this.o_email_address = o_email_address;
  }

  void setWebPage(String o_web_page) {
    this.o_web_page = o_web_page;
  }

  void setBusinessFax(String o_business_fax) {
    this.o_business_fax = o_business_fax;
  }

  void setHomeFax(String o_home_fax) {
    this.o_home_fax = o_home_fax;
  }

  void setJobTitle(String o_job_title) {
    this.o_job_title = o_job_title;
  }

  void setDepartment(String o_department) {
    this.o_department = o_department;
  }

  void setBusinessStreet(String o_business_street) {
    this.o_business_street = o_business_street;
  }

  void setBusinessStreet2(String o_business_street_2) {
    this.o_business_street_2 = o_business_street_2;
  }

  void setBusinessStreet3(String o_business_street_3) {
    this.o_business_street_3 = o_business_street_3;
  }

  void setBusinessCity(String o_business_city) {
    this.o_business_city = o_business_city;
  }

  void setBusinessState(String o_business_state) {
    this.o_business_state = o_business_state;
  }

  void setBusinessPostalCode(String o_business_postal_code) {
    this.o_business_postal_code = o_business_postal_code;
  }

  void setPOBox(String o_po_box) {
    this.o_po_box = o_po_box;
  }

  void setBusinessCountry(String o_business_country) {
    this.o_business_country = o_business_country;
  }

  void setHomeStreet(String o_home_street) {
    this.o_home_street = o_home_street;
  }

  void setHomeStreet2(String o_home_street_2) {
    this.o_home_street_2 = o_home_street_2;
  }

  void setHomeStreet3(String o_home_street_3) {
    this.o_home_street_3 = o_home_street_3;
  }

  void setHomeCity(String o_home_city) {
    this.o_home_city = o_home_city;
  }

  void setHomeState(String o_home_state) {
    this.o_home_state = o_home_state;
  }

  void setHomePostalCode(String o_home_postal_code) {
    this.o_home_postal_code = o_home_postal_code;
  }

  void setSpouse(String o_spouse) {
    this.o_spouse = o_spouse;
  }

  void setHomeCountry(String o_home_country) {
    this.o_home_country = o_home_country;
  }

  void setEmail2Address(String o_email_2_address) {
    this.o_email_2_address = o_email_2_address;
  }
}
