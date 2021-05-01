import UIKit
import SwiftUI

extension UIColor {
  static let seglerRed = UIColor(red: 210.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
}

extension Color {
    static let seglerRowWarning = Color(red: 245/255, green: 174/255, blue: 174/255)
}

extension Color {
    static let seglerRed = Color(red: 210.0/255.0, green: 0/255.0, blue: 0/255.0)
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
