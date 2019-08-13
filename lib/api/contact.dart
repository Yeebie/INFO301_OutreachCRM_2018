import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/network_util.dart';

class ContactAPI {
  NetworkUtil _http = new NetworkUtil();

  Future<List<Contact>> getContacts(User user, int page, bool recentsRequested){
    String _baseURL = "https://${user.domain}.outreach.co.nz/api/0.2";
    String _contactsURL = "$_baseURL/query/user";
    String _properties = "['name_processed','oid']";
    // ,'o_company' when we are ready for it
    String _conditions = "[['status','=','O'],['oid','>=','100']]";
    String _order = "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]";

    List<Contact> list = new List();

    // how many we want to read at a time
    int _contactLimit = 25;
    // multiply the page number by the requested amount to get new start index
    int _startIndex = (_contactLimit * page);
    
    // if we arent starting at 0, set limit to 24, add 1 to index
    if(_startIndex != 0) {
      _startIndex += 1;
      _contactLimit = 24;
      // _contactLimit--;
    }

    String _limit = "[$_contactLimit, $_startIndex]";

    if(!recentsRequested) _order = "[['modified','DESC']]";

    return _http.post(_contactsURL, body: {
      "apikey": user.apiKey,
      "properties": _properties,
      "conditions": _conditions,
      "order": _order,
      "limit": _limit
    }).then((dynamic res) {
      if(res['data'].toString() == '[]') throw new Exception("no more contacts");
      for(final contact in res["data"]) {
        Contact c = Contact.map(contact);
        list.add(c);
      }
      return list;
    });
  }


  Future<List<Contact>> searchContacts(String query, User user) {
    String _baseURL = "https://${user.domain}.outreach.co.nz/api/0.2";
    String _searchURL = "$_baseURL/query/user";
    String _properties = "['oid','name_processed','modified']";
    String _search =  "['OR',['o_first_name','like','$query'],"
                      "['o_last_name','like','$query'],"
                      "['name_processed','like','$query']]";
    String _order = "[['modified','DESC'],['o_first_name','=','DESC'],['o_last_name','=','DESC']]";
    String _limit = "[25]";

    List<Contact> contactsFound = new List();

    return _http.post(_searchURL, body: {
      "apikey": user.apiKey,
      "properties": _properties,
      "search": _search,
      "order": _order,
      "limit": _limit
    }).then((dynamic res) {
      // if(res['data'].toString() == '[]') throw new Exception("found no contacts");
      for(final contact in res["data"]) {
        Contact c = Contact.map(contact);
        contactsFound.add(c);
      }
      return contactsFound;
    });    
  }


  Future<Contact> getContactDetails(Contact contact, User user) {
    String _baseURL = "https://${user.domain}.outreach.co.nz/api/0.2";
    String _contactsURL = "$_baseURL/query/user";
    String _properties = "['*']";
    String _props = "['oid','o_title','o_first_name','o_middle_name','o_last_name','o_suffix','name_mailing','name_processed','o_company','o_mobile_phone','o_company_main_phone','o_business_phone','o_home_phone','o_email_address','o_web_page','o_business_fax','o_home_fax','o_job_title','o_department','o_business_street','o_business_street_2','o_business_street_3','o_business_city','o_business_state','o_business_postal_code','o_po_box','o_business_country','o_home_street','o_home_street_2','o_home_street_3','o_home_city','o_home_state','o_home_postal_code','o_spouse','o_home_country','o_email_2_address']";
    String _conditions = "[['status','=','O'],['oid','==', '${contact.uid}']]";

    return _http.post(_contactsURL, body: {
      "apikey": user.apiKey,
      "properties": _properties,
      "conditions": _conditions
    }).then((dynamic result) {
      contact.addDetails(result["data"][0]);
      return contact;
    });
  }
}