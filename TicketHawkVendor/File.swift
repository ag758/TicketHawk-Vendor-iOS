import Foundation
import UIKit  // don't forget this

class CustomUITextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "paste:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
