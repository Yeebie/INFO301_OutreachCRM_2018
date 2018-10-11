import 'package:flutter/material.dart';
import 'package:outreachcrm_app/SupportClasses.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:outreachcrm_app/ContactPage.dart';

//Used for Wifi check
import 'package:outreachcrm_app/util.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'dart:convert';

//Define "root widget"
//one-line function

///StatelessWidget call
class ViewContactApp extends StatelessWidget {
  String _apiKey;
  String _domain;
  String _oid;
  String _username;

  ViewContactApp(this._apiKey, this._domain, this._oid, this._username);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Contact Details",
        home: ViewContactState(_apiKey, _domain, _oid, _username));
  }
}

///Stateful Widget Call
class ViewContactState extends StatefulWidget {
  String _apiKey;
  String _domain;
  String _oid;
  String _username;

  ViewContactState(this._apiKey, this._domain, this._oid, this._username);

  @override
  ViewContact createState() =>
      new ViewContact(_apiKey, _domain, _oid, _username);
}

class ViewContact extends State<ViewContactState> {
  String _apiKey;
  String _domain;
  String _oid;
  String _username;

  String nameProcessed = "";
  String homePh = "";
  String mobilePh = "";
  String workPh = "";
  String emailAd = "";
  String o_company = "";

  ViewContactFields viewContactFields = new ViewContactFields();

  ViewContact(this._apiKey, this._domain, this._oid, this._username);

  @override
  Widget build(BuildContext context) {
    ///Its guaranteed that a contact'll have a name_processed, use it to do API call only once
    print("ViewContact empty datafields check");
    print("Checking if ViewContact has any data");
    print("nameProcessed length: " + (nameProcessed.length).toString());
    if (nameProcessed.length == 0) {
      print("ViewContact's Data is empty, requesting resupply");
      print("\n\n");
      getContactDetails(_apiKey, _domain, _oid);

      ///The build needs to load some sort of UI, otherwise we'll get a big red screen error while loading contact data
      ///Creates a real basic page so it looks like a half decent transition from ContactPage to ViewContact
      return new MaterialApp(
          debugShowCheckedModeBanner: false,
          home: new Scaffold(
              appBar: new AppBar(
                  backgroundColor: Color(0xFF0085CA),
                  title: new Text(nameProcessed),
                  leading: IconButton(
                    tooltip: "Previous page",
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ))));

      ///Loads when the contact's data has been loaded
    } else {
      print("ViewContact has data, displaying details");
      print("\n\n");
      //build function returns a "Widget"
      var card = new Card(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new ListTile(
              leading: new Icon(
                Icons.account_box,
                color: Color(0xFF0085CA),
                size: 36.0,
              ),
              title: new Text(
                o_company,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              subtitle: new Text("Organisation"),
            ),
            new Divider(
              color: Colors.blue,
              indent: 16.0,
            ),
            new ListTile(
              leading: new IconButton(
                  icon: new Icon(
                    Icons.email,
                    color: Color(0xFF0085CA),
                    size: 36.0,
                  ),
                  tooltip: '',
                  padding: new EdgeInsets.all(0.0),
                  onPressed: () {
                    if (Platform.isAndroid) {
                      launch('mailto:' + emailAd);
                    } else if (Platform.isIOS) {
                      launch('mailto:' + emailAd);
                    }
                  }),
              //leading: new Icon(Icons.email, color: Colors.blue, size: 26.0,),
              title: new Text(
                emailAd,
                style:
                    new TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
              ),
            ),
            new ListTile(
              leading: new IconButton(
                icon: new Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 36.0,
                ),
                tooltip: 'Contact work phone%',
                onPressed: () {
                  if (Platform.isAndroid) {
                    launch('tel:' + workPh);
                  } else if (Platform.isIOS) {
                    //add IOS compatible number here (need to format incoming strings probably)
                    launch('tel:' + workPh);
                  }
                },
              ),
              title: Text(
                workPh,
                style: new TextStyle(color: Colors.black, fontSize: 18.0),
              ),
              subtitle: new Text("Work Phone"),
            ),
            new ListTile(
              leading: new IconButton(
                icon: new Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 36.0,
                ),
                tooltip: 'Contact mobile phone%',
                onPressed: () {
                  if (Platform.isAndroid) {
                    launch('tel:' + mobilePh);
                  } else if (Platform.isIOS) {
                    //add IOS compatible number here (need to format incoming strings probably)
                    launch('tel:' + mobilePh);
                  }
                },
              ),
              title: Text(
                mobilePh,
                style: new TextStyle(color: Colors.black, fontSize: 18.0),
              ),
              subtitle: new Text("Mobie Phone"),
            ),
          ],
        ),
      );

      final sizedBox = new Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(color: Colors.grey, blurRadius: 8.0, spreadRadius: 6.0),
        ]),
        margin: new EdgeInsets.only(left: 10.0, right: 10.0),
        child: new SizedBox.expand(
          //height: 520.0,

          child: card,
        ),
        alignment: Alignment(-1.0, -1.0),
      );

      final center = new Center(
        child: sizedBox,
      );

      final color = const Color(0xFF0085CA);

      return new MaterialApp(
          debugShowCheckedModeBanner: false,
          home: new Scaffold(
            appBar: new AppBar(
                title: new Text(nameProcessed),
                backgroundColor: color,
                leading: IconButton(
                  tooltip: "Previous page",
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ContactsPageApp(_apiKey, _domain, _username),
                        ));
                  },
                )),
            body: center,
          ));
    }
  }

  ///Loading the Contacts List into a Collection
  Future<Contact> getContactDetails(
      String _apiKey, String _domain, String oid) async {
    ///Specify the API Query here, type it according to the API Specification, the app'll convert it to encoded HTML
    String apikey = "?apikey=" + _apiKey;
    String properties = "&properties=" +
        "['oid','o_title','o_first_name','o_middle_name','o_last_name','o_suffix','name_mailing','name_processed','o_company','o_mobile_phone','o_company_main_phone','o_business_phone','o_home_phone','o_email_address','o_web_page','o_business_fax','o_home_fax','o_job_title','o_department','o_business_street','o_business_street_2','o_business_street_3','o_business_city','o_business_state','o_business_postal_code','o_po_box','o_business_country','o_home_street','o_home_street_2','o_home_street_3','o_home_city','o_home_state','o_home_postal_code','o_spouse','o_home_country','o_email_2_address']";
    String conditions =
        "&conditions=" + "[['status','=','O'],['oid','==','" + _oid + "']]";

    print('Retrieving Contact Details');

    ///Specifying the URL we'll make to call the API
    String _requestContactDetails = "https://" +
        _domain +
        ".outreach.co.nz/api/0.2/query/user" +
        (apikey + properties + conditions);

    ///Encoding the String so its HTML safe
    _requestContactDetails = _requestContactDetails.replaceAll("[", "%5B");
    _requestContactDetails = _requestContactDetails.replaceAll("]", "%5D");
    _requestContactDetails = _requestContactDetails.replaceAll("'", "%27");
    _requestContactDetails = _requestContactDetails.replaceAll(">", "%3E");
    print('Get Contact Details URL: ' + _requestContactDetails);

    var wifiEnabled = await Util.getWifiStatus();

    if (wifiEnabled) {
      http.post(_requestContactDetails).then((response) {
        //Print the API Key, just so we can compare it to the subset String
        print("Contact List Response:");
        print(response.body);
        List<ViewContactFields> contactsList = new List();
        //Turning the json into a map
        final viewContactMap = json.decode(response.body);
        ViewContactJson viewContactJson =
            new ViewContactJson.fromJson(viewContactMap);
        print("\n");

        ///Creates a new contact filled with data, adds it to List<Contact>
        for (ViewContactData data in viewContactJson.data) {
          viewContactFields.setOid(data.getOid());
          viewContactFields.setTitle(data.getTitle());
          viewContactFields.setFirstName(data.getFirstName());
          viewContactFields.setMiddleName(data.getMiddleName());
          viewContactFields.setLastName(data.getLastName());
          viewContactFields.setSuffix(data.getSuffix());
          viewContactFields.setNameMailing(data.getNameMailing());

          viewContactFields.setFullName(data.getFullName());
          viewContactFields.setCompany(data.getCompany());

          viewContactFields.setMobilePhone(data.getMobilePhone());
          viewContactFields.setCompanyMainPhone(data.getCompanyMainPhone());
          viewContactFields
              .setBusinessPhone(data.getBusinessPhone()); //DDI Field
          viewContactFields.setHomePhone(data.getHomePhone());
          viewContactFields.setEmailAddress(data.getEmailAddress());
          viewContactFields.setWebPage(data.getWebPage());
          viewContactFields.setBusinessFax(data.getBusinessFax());
          viewContactFields.setHomeFax(data.getHomeFax());

          viewContactFields.setJobTitle(data.getJobTitle());
          viewContactFields.setDepartment(data.getDepartment());
          viewContactFields.setBusinessStreet(data.getBusinessStreet());
          viewContactFields.setBusinessStreet2(data.getBusinessStreet2());
          viewContactFields.setBusinessStreet3(data.getBusinessStreet3());
          viewContactFields.setBusinessCity(data.getBusinessCity());
          viewContactFields.setBusinessState(data.getBusinessState());
          viewContactFields.setBusinessPostalCode(data.getBusinessPostalCode());
          viewContactFields.setPOBox(data.getPOBox());
          viewContactFields.setBusinessCountry(data.getBusinessCountry());

          viewContactFields.setHomeStreet(data.getHomeStreet());
          viewContactFields.setHomeStreet2(data.getHomeStreet2());
          viewContactFields.setHomeStreet3(data.getHomeStreet3());
          viewContactFields.setHomeCity(data.getHomeCity());
          viewContactFields.setHomeState(data.getHomeState());
          viewContactFields.setHomePostalCode(data.getHomePostalCode());
          viewContactFields.setSpouse(data.getSpouse());
          viewContactFields.setHomeCountry(data.getHomeCountry());
          viewContactFields.setEmail2Address(data.getEmail2Address());
        }
        //Retrieving the API Key from the array
        print("Hidden Information");
        print("oid                     " + viewContactFields.oid);
        print("o_title:                " + viewContactFields.o_title);
        print("o_first_name:           " + viewContactFields.o_first_name);
        print("o_middle_name:          " + viewContactFields.o_middle_name);
        print("o_last_name:            " + viewContactFields.o_last_name);
        print("o_suffix:               " + viewContactFields.o_suffix);
        print("name_mailing:           " + viewContactFields.name_mailing);
        print("\n");

        print("Name & Organisation");
        print("fullName:               " + viewContactFields.fullName);
        print("company:                " + viewContactFields.company);
        print("\n");

        print("General");
        print("o_mobile_phone:         " + viewContactFields.o_mobile_phone);
        print("o_company_main_phone:   " +
            viewContactFields.o_company_main_phone);
        print("o_business_phone:       " +
            viewContactFields.o_business_phone); //DDI Field
        print("o_home_phone:           " + viewContactFields.o_home_phone);
        print("o_email_address:        " + viewContactFields.o_email_address);
        print("o_web_page:             " + viewContactFields.o_web_page);
        print("o_business_fax:         " + viewContactFields.o_business_fax);
        print("o_home_fax:             " + viewContactFields.o_home_fax);
        print("\n");

        print("Work");
        print("o_job_title:            " + viewContactFields.o_job_title);
        print("o_department:           " + viewContactFields.o_department);
        print("o_business_street:      " + viewContactFields.o_business_street);
        print(
            "o_business_street_2:    " + viewContactFields.o_business_street_2);
        print(
            "o_business_street_3:    " + viewContactFields.o_business_street_3);
        print("o_business_city:        " + viewContactFields.o_business_city);
        print("o_business_state:       " + viewContactFields.o_business_state);
        print("o_business_postal_code: " +
            viewContactFields.o_business_postal_code);
        print("o_po_box:               " + viewContactFields.o_po_box);
        print(
            "o_business_country:     " + viewContactFields.o_business_country);
        print("\n");

        print("Home");
        print("o_home_street:          " + viewContactFields.o_home_street);
        print("o_home_street_2:        " + viewContactFields.o_home_street_2);
        print("o_home_street_3:        " + viewContactFields.o_home_street_3);
        print("o_home_city:            " + viewContactFields.o_home_city);
        print("o_home_state:           " + viewContactFields.o_home_state);
        print(
            "o_home_postal_code:     " + viewContactFields.o_home_postal_code);
        print("o_spouse:               " + viewContactFields.o_spouse);
        print("o_home_country:         " + viewContactFields.o_home_country);
        print("o_email_2_address:      " + viewContactFields.o_email_2_address);
        print('\n \n');

        nameProcessed = viewContactFields.fullName;
        homePh = viewContactFields.o_home_phone;
        mobilePh = viewContactFields.o_mobile_phone;
        workPh = viewContactFields.o_company_main_phone;
        emailAd = viewContactFields.o_email_address;
        o_company = viewContactFields.company;
        setState(() {});
      });
    }
    else {
       showDialogParent("No Internet Connection",
            "Please connect to the internet to use this application.");
    }
  }
  void showDialogParent(String title, String content) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: [
                new FlatButton(
                  child: const Text("Ok"),
                  onPressed: () => exit(0),
                ),
              ],
            ));
  }
}
