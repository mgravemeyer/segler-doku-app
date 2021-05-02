# Segler Doku App

<p align="center">
    <img src="https://github.com/mgravemeyer/Segler/blob/master/readmeImg/AppPreview.png" max-height="500">
</p>

### Client 🚤
This project is produced as i worked as a freelancer for the company [Segler](https://www.segler.eu/home.html). It is a middle sized company based near osnabrück, germany and they are producing conveyor systems.

### Goal 🎯
The goal was to build an app that helps the engineers to track mistakes that were made in the factory producing process. They should take a picture, write some comments about what is wrong with the broken part and then send it to a server. On this server the data will get processed by a python algorythm and it will send the image with the additonal information (json) to the right instituiton in segler that they can work things out.

### Features 📱
* Scanning Barcodes from employes for login.
* Scanning Barcodes from Drawings and fill that into the form.
* Sending Photos, Videos, PDF's (also editing) to a FTP Server with additional information stored in a JSON File. Al

### Challenges 🧨
A requierement was to send the images with additional comments over the internal network via SFTP.
Two ways could be:
    send the data on the image via meta-data.
    send a json file along the image.
The company already worked with JSON so the IT-Department and I decided to use JSON along with the Image. One problem could be if the Image successfully was transfered but the JSON not, there could be problems on the Server. Therefor the Server searches for both files and if one is not existing then it will throw an error to the IT-Department.
SwiftUI was not really ready when i started using it. Therefore, there where a lot of refactorings involved, because when SwiftUI released, there was nearly every week an update that changed a lot. Thats why here and there in the app there could be some old code, but i reafactored as much as i could possibly do till today so far.

### Program Sequence 🟢
<p align="center">
    <img src="https://i.ibb.co/3BXScjq/SE.png" max-height="500">
</p>

##### 1. Getting Server Connetion and Download config.json
The Application needs to get configured on the first time the user starts the app. Therefore the User has to fill out server connection credentials. Then the App will search for a file named: config.json. When it finds the file it will download it. There also files mentioned in the config.json that the app tries then to download. (currently only pdf's)

##### 2. User Login
The app loads a user default value and checks if the option "use standard user" is true. An admin can setup this setting in the app through the admin menu. If "use standard user" is true -> it goes immediatly to the AppView and loads the stored username. If the option is false, a user can scan a barcode to login. The barcode must have the following form: U_xnamex. Example: U_Max.

##### 3. Submit a problem / use the app
After that the User can scan again barcodes to fill out automatically some fields, or manually type in something. After that the user can take pictures, videos or open and edit pdfs. After selecting/taking the pictures, videos or/and images, the data is getting compressed. Images are using the standard swift jpeg compress method. I'm getting the compression rate (0.0-1.0) from the config.json. (I agreed with the client that they wanted to have a compression rate for each type of device that they could use, iPad, iPhone, iPod). Videos are using a custom function that compressed the audio and video bits and converts the video (that is normaly a .mov in swift) to a .mp4. I found therefore an article that had already a good basis and i extended that alogrithm with my custom logic for my needs. While the user clicks on "Abschicken" the compression and transfer will be loaded in a side thread, the main thread displays a loading indicator. After successfully transfering all data, the user will getting a prompt that show him what he sended.

##### 4. Beyond the app / what the server recives

The Server gets a JSON File, named like for example: 
```543271_10_20200708_160956_0.json ```
Order-Nr, Positions-Nr, Date, Time, Counter for multiple Images

The sended JSON is structured in the following way:

```diff
{
    "AppVersion": "1.6.4",
    "Geraet": "iPhone von Max",
    "Bereich": "Sägen",
    "Meldungstyp": "Material fehlt",
    "User": "Max",
    "Freitext": "Test Text"
}
```

And this is how it looks like in the end on the server:

<p align="center">
    <img src="https://i.ibb.co/pXr2g9V/Screenshot-2021-05-02-at-17-03-22.png" max-height="500">
</p>

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

## What's next?
* Storing the downloaded PDF's in the FileManager system, with that, i dont need to redownload every pdf.
* Storing Server Credentials not in UserDefaults, instead in CoreData. (UserDefaults is not encrypted so it is currently a security risk)!
* Evnetually: refactoring the whole state process management. Back then, SwiftUI had really limited capabilities to work with it. (example: had to pass EnvironmentObjects manually to every child view (what a mess!)). Now, i reafctored already a lot to use newer and better techniques.
* Creating a bidirectional system to transfer data. We are currently exploring the capabilities of websockets to transfer realtime data. Idea is, use types something into the project number search field, the app suggests him already what kind of projects he can choose and wich ones are valid/existing.