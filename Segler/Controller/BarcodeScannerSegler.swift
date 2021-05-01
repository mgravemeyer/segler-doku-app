import Swift
import BarcodeScanner
import UIKit
import SwiftUI
import ProgressHUD

struct BarcodeScannerView : UIViewControllerRepresentable {
    
    typealias UIViewControllerType = BarcodeScannerViewController
    
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var showBarcodeScannerView: Bool
    
    var sourceType : Int
    
    @EnvironmentObject var mediaVM: MediaViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(sourceType: self.sourceType, userVM: _userVM, mediaVM : _mediaVM, orderVM : _orderVM, showBarcodeScannerView: self.$showBarcodeScannerView)
    }
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        viewController.codeDelegate = context.coordinator
        viewController.errorDelegate = context.coordinator
        viewController.dismissalDelegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        
    }
    
    class Coordinator: BarcodeScannerDismissalDelegate, BarcodeScannerErrorDelegate, BarcodeScannerCodeDelegate {
        
        func splitOrderNrAndOrderPosition(_ code: String) -> (String, String) {
            
            var foundP : Bool = false
            let foundA : Bool = false
            var orderNr : String = ""
            var orderPosition : String = ""
            
            for char in code {
                
                if char == "A" {
                    
                } else if char == "P" {
                    foundP = true
                } else if !foundP {
                    orderNr.append(char)
                } else if foundP {
                    orderPosition.append(char)
                }
            }
            if !foundP && !foundA == true {
                ProgressHUD.showError("Keine Auftrags-Nr oder Positions-Nr erkannt.")
                return ("", "")
            }
                return (orderNr, orderPosition)
        }
        @EnvironmentObject var userVM: UserViewModel
        @EnvironmentObject var mediaVM : MediaViewModel
        @EnvironmentObject var orderVM : OrderViewModel
        var sourceType : Int
        
        @Binding var showBarcodeScannerView: Bool
        
        
        init(sourceType: Int, userVM: EnvironmentObject<UserViewModel>,mediaVM : EnvironmentObject<MediaViewModel>, orderVM : EnvironmentObject<OrderViewModel>, showBarcodeScannerView: Binding<Bool>) {
            _userVM = userVM
            self.sourceType = sourceType
            _mediaVM = mediaVM
            _orderVM = orderVM
            _showBarcodeScannerView = showBarcodeScannerView
        }
        
        func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            
            controller.cameraViewController.title = "Hallo"
        
            //SOURCETYPE 0 MEANS orderNr
            if code != "" && sourceType == 0 {
                ProgressHUD.showSuccess("Barcode erkannt")
                let splitted = splitOrderNrAndOrderPosition(code)
                orderVM.orderNr = splitted.0
                orderVM.orderPosition = splitted.1
                self.showBarcodeScannerView = false
                controller.dismiss(animated: true, completion: nil)
            } else if sourceType == 0 {
                ProgressHUD.showError("Barcode nicht erkannt")
                self.showBarcodeScannerView = false
                controller.dismiss(animated: true, completion: nil)
            } else {
                controller.dismiss(animated: true, completion: nil)
                self.showBarcodeScannerView = false
            }
            
            var found_ = false
            
            //SOURCETYPE 1 Means UserName/LoginName
            if code != "" && sourceType == 1 && code.prefix(1) == "U" {
                ProgressHUD.showSuccess("Barcode erkannt")
                
                for char in code {
                    
                    if found_ {
                        userVM.username.append(char)
                    }
                    
                    if char == "." {
                        found_ = true
                    }
                }

                userVM.loggedIn = true
                self.showBarcodeScannerView = false
                controller.dismiss(animated: true, completion: nil)
            } else if sourceType == 1 {
                ProgressHUD.showError("Falscher Barcode")
                userVM.loggedIn = false
                controller.dismiss(animated: true, completion: nil)
                self.showBarcodeScannerView = false
            } else {
                controller.dismiss(animated: true, completion: nil)
                self.showBarcodeScannerView = false
            }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            controller.resetWithError()
            }
        }
            
        func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
            print(error)
        }
            
        func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
            self.showBarcodeScannerView = false
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
