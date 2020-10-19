import Foundation
import SwiftUI
import Combine

class ColorSeglerViewModel {
    
    let color: Color = Color(red: 200/255, green: 0/255, blue: 0/255)
    let uIColor: UIColor = UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
    
    let warningRowColor = Color(red: 245/255, green: 174/255, blue: 174/255)
    let correctRowColor = Color.white
}
