import 'package:outreach/models/contact.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/network_util.dart';

class ContactAPI {
  NetworkUtil _netUtil = new NetworkUtil();


  Future getContacts(User user, int page, List<Contact> list){
    String _baseURL = "https://${user.domain}.outreach.co.nz/api/0.2";
    String _contactsURL = "$_baseURL/query/user";
    String _properties = "['name_processed','oid']";
    // ,'o_company' when we are ready for it
    String _conditions = "[['status','=','O'],['oid','>=','100']]";
    String _order = "[['o_first_name','=','DESC'],['o_last_name','=','DESC']]";

    // how many we want to read at a time
    int _contactLimit = 24;
    // multiply the page number by the requested amount to get new start index
    int _startIndex = (_contactLimit * page);
    // add one to it so we move over the last grabbed item
    _startIndex == 0 ? _startIndex = 0 : _startIndex += 1;

    // e.g. [contact limit, start index]
    String _limit = "[$_contactLimit, $_startIndex]";

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
        list.add(c);
        // print("RETREIVING CONTACT {");
        // print("\t${c.name}");
        // print("\t${c.uid}\n}");
      }
    });
  }
}