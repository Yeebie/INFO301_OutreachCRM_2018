import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/network_util.dart';

class ContactAPI {
  NetworkUtil _netUtil = new NetworkUtil();

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
    int x = _startIndex + _contactLimit;
    int i = _startIndex;
    // e.g. [contact limit, start index]
    String _limit = "[$_contactLimit, $_startIndex]";

    // if we haven't got the recents yet
    if(!recentsRequested) _order = "[['modified','DESC']]";

    return _netUtil.post(_contactsURL, body: {
      "apikey": user.apiKey,
      "properties": _properties,
      "conditions": _conditions,
      "order": _order,
      "limit": _limit
    }).then((dynamic res) {
      if(res['data'].toString() == '[]') throw new Exception("no more contacts");
      for(final contact in res["data"]) {
        Contact c = Contact.map(contact);
        print("${i++} ${c.name}");
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

    return _netUtil.post(_searchURL, body: {
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
}