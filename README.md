# Segler Doku App

<p align="center">
    <img src="https://github.com/mgravemeyer/Segler/blob/master/readmeImg/AppPreview.png" max-height="500">
</p>

### Client 🚤
This project is produced as i worked as a freelancer for the company [Segler](https://www.segler.eu/home.html). It is a middle sized company based near osnabrück, germany and they are producing conveyor systems.

### Goal 🎯
The goal was to build an app that helps the engineers to track mistakes that were made in the factory producing process. They should take a picture, write some comments about what is wrong with the part and then send it to a server. On this server the data will get scanned by a python algorythm and it will getting send to the right instituiton in segler that they can work things out.

### Features 📱
* Scanning Barcodes from employes for login.
* Scanning Barcodes from Drawings and fill that into the form.
* Taking multiple photos.
* Sending Photos, Videos or edited PDF's to a FTP Server with additional information stored in a JSON File.

### Challenges 🧨
A requierement was to send the images with additional comments over the internal network via SFTP.
Two ways could be:
    send the data on the image via meta-data. 
    send a json file along the image.
The company already worked with JSON so the IT-Department and I decided to use JSON along with the Image. One problem could be if the Image successfully was transfered but the JSON not, there could be problems on the Server. Therefor the Server searches for both files and if one is not existing then it will throw an error to the IT-Department. The Server-side stuff was not written by me.

### Program Sequence 🟢
![sequence segler app](https://i.ibb.co/3BXScjq/SE.png)

##### 1. Getting Server Connetion and Download config.json
The Application needs to get configured on the first time the user starts the app. Therefore the User has to fill out server connection credentials. Then the App will search for a file named: config.json. When it finds the file it will download it. There also files mentioned in the config.json that the app tries then to download. (currently only pdf's)

##### 2. User Login
The app loads a user default value and checks if the option "use standard user" is true. An admin can setup this setting in the app through the admin menu. If "use standard user" is true -> it goes immediatly to the AppView and loads the stored username. If the option is false, a user can scan a barcode to login. The barcode must have the following form: U_xnamex. Example: U_Max.

##### 3. Submit a problem / use the app
After that the User can scan again barcodes to fill out automatically some fields, or manually type in something. After that the user can send images, videos, pdf's to the server via FTP.

##### 4. Beyond the app / what the server recives

The Server gets a JSON File, named like for example: 
```543271_10_20200708_160956_0.json ```
Order-Nr, Positions-Nr, Date, Time, Counter for multiple Images

The sended JSON is structured in the following way:

```diff
{
    "Meldungstyp": "Material fehlt",
    "User": "Max",
    "Freitext": "Freitext",
    "Bereich": "Sägen"
}
```

## Install 💿
Just download the Project and open Segler.xcworkspace
If there is an error, the pods need to be rebuild. This is because one of the pods causes sometimes a compiler error for newer xcode versions. Just download cocoapods 
```sudo gem install cocoapods```
Go to the Folder of the Project (Segler-Master)
```pod deintegrate```
```pod install```

## Techonologies used 🧑🏼‍💻
* [Swift](https://developer.apple.com/swift/) with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
* [UIKit](https://developer.apple.com/documentation/uikit) (UIViewRepresentable for SwiftUI)
* [PDFKit](https://developer.apple.com/documentation/pdfkit)
* Design Pattern: started as MVC now it is [MVVM](https://www.wintellect.com/model-view-viewmodel-mvvm-explained/)
* Used [CocoaPods](https://cocoapods.org) as dependency manager with the following frameworks:
    * [BarcodeScanner](https://cocoapods.org/pods/BarcodeScanner) - using the CODE-128 encryption
    * [ProgressHUD](https://cocoapods.org/pods/ProgressHUD) - Displaying App feedback success or failure
    * [NMSSH](https://cocoapods.org/pods/NMSSH) - SFTP connection via SSH protocol
