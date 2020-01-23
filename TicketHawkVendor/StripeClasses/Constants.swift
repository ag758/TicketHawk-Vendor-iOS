

import Foundation
import Firebase
import FirebaseDatabase

enum Constants {
  static let publishableKey = "pk_live_Es4NfgnJnDuJpaz2IWEEY1N000Unj0FodD"
  static let baseURLString = "https://secret-river-64641.herokuapp.com"
  static let defaultCurrency = "usd"
  static let defaultDescription = "Purchase from TicketHawk"
    
  static let privacyPolicyURL = "https://www.tickethawkapp.com/privacy-policy"
  static let termsOfServiceURL = "https://www.tickethawkapp.com/terms-conditions"
  static let howToReportURL = "https://www.tickethawkapp.com/report"
    
    static let stripeConnectedAccountAgreementURL = "https://stripe.com/connect-account/legal"
    static let stripe_success_url = "https://www.tickethawkapp.com/verification-success"
    static let stripe_failure_url = "https://www.tickethawkapp.com/verification-failure"
    
    static let stripeAccountCreateURL = "https://infinite-brushlands-30316.herokuapp.com"
    static let stripeAccountUpdateURL = "https://pacific-headland-27171.herokuapp.com"
    
    static let stripeBankTokenGenerateURL = "https://limitless-crag-73993.herokuapp.com"
    static let stripeBankSetURL = "https://pure-mountain-40233.herokuapp.com"
    
    static let ref = Database.database().reference()
    static var greenColor: UIColor = hexStringToUIColor(hex: "#77FF73")
    static var almostBlack: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)

}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
