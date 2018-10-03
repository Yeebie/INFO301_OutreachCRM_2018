import 'package:flutter/material.dart';
import 'package:outreachcrm_app/SupportClasses.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

///Used for API Key Retrieval
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; //Converts Json into Map

//Define "root widget"
//one-line function

class viewContact extends StatelessWidget {
  String _apiKey;
  String _domain;
  String _oid;


  //Placeholder static values
  final homePh = "07 645 8524";
  final mobilePh = '027 452 4318';
  final workPh = '07 868 9678';
  final emailAd = 'namerson@gmail.com';
  final client = 'Thomas Green Industries';
  final color = const Color(0xFF0085CA);

  ViewContactFields viewContactFields = new ViewContactFields();

  viewContact(String apiKey, String domain, String oid) {
    this._apiKey = apiKey;
    this._domain = domain;
    this._oid = oid;
  }

  @override
  Widget build(BuildContext context) {
    getContactDetails(_apiKey, _domain, _oid);

    //build function returns a "Widget"
    var card = new Card(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new ListTile(
            leading: new Icon(
              Icons.account_box,
              color: color,
              size: 36.0,
            ),
            title: new Text(
              client,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            subtitle: new Text("Organisation"),

          ),
          new Divider(
            color: color,
            indent: 16.0,
          ),
          new ListTile(
            leading: new IconButton(
                icon: new Icon(
                  Icons.email,
                  color: color,
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
              style: new TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
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
          new ListTile(
            leading: new IconButton(
              icon: new Icon(
                Icons.note,
                color: color,
                size: 36.0,
              ),
              tooltip: 'View client notes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientNotes()),
                );
              },
            ),
            title: Text(
              'Client Notes',
              style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 18.0),
            ),
          ),
        ],
      ),
    );

    final sizedBox = new Container(
      decoration: new BoxDecoration(boxShadow: [
        new BoxShadow(color: Colors.grey, blurRadius: 8.0, spreadRadius: 6.0),
      ]
      ),
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

    return new MaterialApp(
        title: "",
        home: new Scaffold(
          appBar: new AppBar(
              title: new Text("Contact Details"),
              backgroundColor: color,
              leading: IconButton(
                tooltip: "Previous page",
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          body: center,
        ));
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
        viewContactFields.setBusinessPhone(data.getBusinessPhone()); //DDI Field
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
      print(
          "o_company_main_phone:   " + viewContactFields.o_company_main_phone);
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
      print("o_business_street_2:    " + viewContactFields.o_business_street_2);
      print("o_business_street_3:    " + viewContactFields.o_business_street_3);
      print("o_business_city:        " + viewContactFields.o_business_city);
      print("o_business_state:       " + viewContactFields.o_business_state);
      print("o_business_postal_code: " +
          viewContactFields.o_business_postal_code);
      print("o_po_box:               " + viewContactFields.o_po_box);
      print("o_business_country:     " + viewContactFields.o_business_country);
      print("\n");

      print("Home");
      print("o_home_street:          " + viewContactFields.o_home_street);
      print("o_home_street_2:        " + viewContactFields.o_home_street_2);
      print("o_home_street_3:        " + viewContactFields.o_home_street_3);
      print("o_home_city:            " + viewContactFields.o_home_city);
      print("o_home_state:           " + viewContactFields.o_home_state);
      print("o_home_postal_code:     " + viewContactFields.o_home_postal_code);
      print("o_spouse:               " + viewContactFields.o_spouse);
      print("o_home_country:         " + viewContactFields.o_home_country);
      print("o_email_2_address:      " + viewContactFields.o_email_2_address);
      print("\n");
      print('\n \n');
    });
  }
}

class ClientNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
    child: Scaffold(
        appBar: AppBar(
          title: Text("Thomas Green Industries"),
        ),

        body: new Card(

          child: new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: <Widget>[

              const ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Additional Information'),
                subtitle: const Text(
                    'What the info is'),
              ),
              new Divider(
                color: Colors.blue,
                indent: 16.0,
              ),

              new ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('View note'),
                      onPressed: () {/* ... */},
                    ),
                  ],
                ),

              ),
            ],
          ),

        ),

    ),

      //this is messed up because the container is around the scaffold
      decoration: new BoxDecoration(boxShadow: [
    //new BoxShadow(color: Colors.grey, blurRadius: 8.0, spreadRadius: 6.0),
    ]

    ),

    );

  }
}
