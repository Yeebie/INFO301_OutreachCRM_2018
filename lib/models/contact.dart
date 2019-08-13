

class Contact {
  String _name;
  String _uid;

  // details updated on contact selection
  bool hasDetails = false;

  String firstName;
  String middleName;
  String lastName;
  String mobilePhone;
  String homePhone;
  String businessPhone;
  String email;
  String homeFax;

  String homeStreet;
  String homeCity;
  String homeState;
  String homePostcode;
  String homeCountry;

  String company;
  String companyPhone;
  String website;
  String businessFax;
  String jobTitle;
  String department;
  String businessStreet;
  String businessCity;
  String businessState;
  String businessPostcode;
  String businessCountry;


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

  addDetails(dynamic data) {
    this.hasDetails = true;

    this.firstName = data["o_first_name"] == "" ? null : data['o_first_name'];
    this.middleName = data["o_middle_name"] == "" ? null : data['o_middle_name'];
    this.lastName = data["o_last_name"] == "" ? null : data['o_last_name'];

    // personal contact details
    this.mobilePhone = data["o_mobile_phone"] == "" ? null : data['o_mobile_phone'];
    this.homePhone = data["o_home_phone"] == "" ? null : data['o_home_phone'];
    this.businessPhone = data["o_business_phone"] == "" ? null : data['o_business_phone'];
    this.homeFax = data['o_home_fax'] == "" ? null : data['o_home_fax'];
    this.email = data["o_email_address"] == "" ? null : data['o_email_address'];

    // personal address
    this.homeStreet = data["o_home_street"] == "" ? null : data['o_home_street'];
    this.homeState = data["o_home_state"] == "" ? null : data['o_home_state'];
    this.homeCity = data["o_home_city"] == "" ? null : data['o_home_city'];
    this.homePostcode = data["o_home_postal_code"] == "" ? null : data['o_home_postal_code'];
    this.homeCountry = data["o_home_country"] == "" ? null : data['o_home_country'];

    // business address
    this.businessStreet = data["o_business_street"] == "" ? null : data['o_business_street'];
    this.businessState = data["o_business_state"] == "" ? null : data['o_business_state'];
    this.businessCountry = data["o_business_country"] == "" ? null : data['o_business_country'];
    this.businessPostcode = data["o_business_postal_code"] == "" ? null : data['o_business_postal_code'];
    this.businessCity = data["o_business_city"] == "" ? null : data['o_business_city'];

    // business details
    this.company = data["o_company"] == "" ? null : data['o_company'];
    this.companyPhone = data["o_company_main_phone"] == "" ? null : data['o_company_main_phone'];
    this.department = data["o_department"] == "" ? null : data['o_department'];
    this.website = data["o_web_page"] == "" ? null : data['o_web_page'];
    this.jobTitle = data["o_job_title"] == "" ? null : data['o_job_title'];
    this.businessFax = data["o_business_fax"] == "" ? null : data['o_business_fax'];
  }

 var s = ['o_home_fax', 'o_business_street_2','o_business_street_3','o_business_city','o_po_box','o_business_country','o_home_street','o_home_street_2','o_home_street_3','o_home_city','o_home_state','o_home_postal_code','o_spouse','o_home_country','o_email_2_address'];
}