import 'package:outreach/util.dart';

///Used to utilise REST operations
import 'package:outreach/util/network_util.dart';

class ConnectionException implements Exception {
  String error = "Please connect to the internet to continue";
}

class ApiAuth {
// next three lines makes this class a Singleton
  static ApiAuth _instance = new ApiAuth.internal();
  ApiAuth.internal();
  factory ApiAuth() => _instance;

  final NetworkUtil _netUtil = new NetworkUtil();



  /// Checks if the user entered domain is valid
  /// 
  /// @param domain - the domain to be checked
  /// 
  /// @return - whether domain is valid
  Future<bool> validateDomain(String domain) async {
    String url = "https://${domain}.outreach.co.nz";
    
    print("VALIDATING DOMAIN {"
    "\n\tdomain: $domain");
    
    var wifiEnabled = await Util.getWifiStatus();
    if (!wifiEnabled) throw new ConnectionException();

    try{
      await _netUtil.get(url, true);
      print("\tvalidated: true" "\n}");
      return true;
    } on Exception catch(e) {
        print(e.toString());
        print("\tvalidated: false" "\n}");
        return false;
    }
  }


  Future<bool> validateAPIKey(String domain,
                    String key, DateTime expiry) async {
    String baseURL = "https://$domain.outreach.co.nz/api/0.2";
    String verifyURL = "$baseURL/auth/verify/";
    
    print("VALIDATING API KEY {"
    "\n\tkey: $key");

    // check we are not past key expiry
    if(DateTime.now().isAfter(expiry)) {
      print("\tvalidated: false" "\n}");
      throw new Exception("Key expired");
    }

    try{
      return _netUtil.post(verifyURL, body: {
        "apikey": key,
      }).then((dynamic result) {
        print("\t${result.toString()}");
        if(result["error"] != "") {
          throw new Exception(result["error"].toString());
        }
        print("\tvalidated: true" "\n}");
        return true;
      });
    } on Exception catch(e) {
        print(e.toString());
        print("\tvalidated: false" "\n}");
        return false;
    }
  }
}