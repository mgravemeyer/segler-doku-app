import Swift
import BarcodeScanner
import UIKit
import SwiftUI
import ProgressHUD

struct BarcodeScannerSegler : UIViewControllerRepresentable {
    
    typealias UIViewControllerType = BarcodeScannerViewController
    
    @ObservedObject var userVM: UserViewModel
    
    var sourceType : Int
    
    @ObservedObject var mediaVM: MediaViewModel
    @ObservedObject var orderVM: OrderViewModel
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(sourceType: self.sourceType, userVM: _userVM, mediaVM : _mediaVM, orderVM : _orderVM)
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
            var foundA : Bool = false
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
        @ObservedObject var userVM : UserViewModel
        @ObservedObject var mediaVM : MediaViewModel
        @ObservedObject var orderVM : OrderViewModel
        var sourceType : Int
        
        
        init(sourceType: Int, userVM: ObservedObject<UserViewModel>,mediaVM : ObservedObject<MediaViewModel>, orderVM : ObservedObject<OrderViewModel>) {
            _userVM = userVM
            self.sourceType = sourceType
            _mediaVM = mediaVM
            _orderVM = orderVM
        }
        
        func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
            
            controller.cameraViewController.title = "Hallo"
        
            //SOURCETYPE 0 MEANS orderNr
            if code != "" && sourceType == 0 {
                ProgressHUD.showSuccess("Barcode erkannt")
                let splitted = splitOrderNrAndOrderPosition(code)
                orderVM.orderNr = splitted.0
                orderVM.orderPosition = splitted.1
                mediaVM.showImageScanner = false
                controller.dismiss(animated: true, completion: nil)
            } else if sourceType == 0 {
                ProgressHUD.showError("Barcode nicht erkannt")
                mediaVM.showImageScanner = false
                controller.dismiss(animated: true, completion: nil)
            } else {
                controller.dismiss(animated: true, completion: nil)
                mediaVM.showImageScanner = false
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
                mediaVM.loginShowImageScannner = false
                controller.dismiss(animated: true, completion: nil)
            } else if sourceType == 1 {
                ProgressHUD.showError("Falscher Barcode")
                userVM.loggedIn = false
                controller.dismiss(animated: true, completion: nil)
                mediaVM.loginShowImageScannner = false
            } else {
                controller.dismiss(animated: true, completion: nil)
                mediaVM.loginShowImageScannner = false
            }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            controller.resetWithError()
            }
        }
            
        func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
            print(error)
        }
            
        func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
            mediaVM.showImageScanner = false
            mediaVM.loginShowImageScannner = false
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
