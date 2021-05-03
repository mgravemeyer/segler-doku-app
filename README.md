# Segler Doku App

<p align="center">
    <img src="https://github.com/mgravemeyer/Segler/blob/master/readmeImg/AppPreview.png" max-height="500">
</p>

### Client 🚤
This project is produced as I worked as a freelancer for the company [Segler](https://www.segler.eu/home.html). It is a middle-sized company based near osnabrück, Germany and they are producing conveyor systems.

### Goal 🎯
The goal was to build an app that helps the engineers to track mistakes that were made in the factory producing process. They should be able to take a picture or video, write some comments about what is wrong with the broken part and then send it to a server. On this server, the data will get processed by a python function and it will send the image with the additional information (JSON) to the right institution in segler that they can work things out.

### Features 📱
* Scanning Barcodes from employees for login.
* Scanning Barcodes from Drawings and fill that into the form.
* Sending Photos, Videos, PDFs (also editing) to an FTP Server with additional information stored in a JSON File. (Photos and Videos will be getting compressed)

## Techonologies used 🧑🏼‍💻
* [Swift](https://developer.apple.com/swift/) with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
* [UIKit](https://developer.apple.com/documentation/uikit) (UIViewRepresentable for SwiftUI)
* [PDFKit](https://developer.apple.com/documentation/pdfkit)
* Design Pattern: started as MVC now it is [MVVM](https://www.wintellect.com/model-view-viewmodel-mvvm-explained/)
* Used [CocoaPods](https://cocoapods.org) as dependency manager with the following frameworks:
    * [BarcodeScanner](https://cocoapods.org/pods/BarcodeScanner) - using the CODE-128 encryption
    * [ProgressHUD](https://cocoapods.org/pods/ProgressHUD) - Displaying App feedback success or failure
    * [NMSSH](https://cocoapods.org/pods/NMSSH) - SFTP connection

### Challenges 🧨
A requirement was to send the images with additional comments over the internal network via SFTP.
Two ways could be:
    send the data on the image via meta-data.
    send a JSON file along with the image.
The company already worked with JSON and FTP connections so the IT-Department and I decided to send a JSON file via FTP along with the images and/or videos that are captured + an optional pdf file.
SwiftUI was not bug-free when I started using it. Therefore, there were a lot of refactorings involved because when SwiftUI was released, there was nearly every week update that changed a lot. That's why here and there in the app there could be some old code, but I refactored as much as I could do till today so far.

### Program Sequence 🟢
<p align="center">
    <img src="https://i.ibb.co/3BXScjq/SE.png" max-height="500">
</p>

##### 1. Getting Server Connection and Download config.json
The Application needs to get configured the first time the user starts the app. Therefore the User has to fill out one time the server connection credentials. Then the App will search for a file named: config.json. When it finds the file it will download it. There also files mentioned in the config.json that the app tries then to download. (example: pdfs)

##### 2. User Login
The app loads a user default value and checks if the option "use standard user" is true. An admin can set up this setting in the app through the admin menu. If "use standard user" is true -> it goes immediately to the AppView and loads the stored username. If the option is false, a user can scan a barcode to log in. The barcode must have the following form: U.name. Example: U.Max.

<p align="center">
    <img src="https://i.ibb.co/12RQYk9/Unknown-1.gif" max-height="500">
</p>

##### 3. Submit a problem / use the app
After that, the User can scan again barcodes to fill out automatically some fields, or manually type in something. After that the user can take pictures, videos or open and edit pdfs. After selecting/taking the pictures, videos, or/and images, the data is getting compressed. Images are using the standard swift jpeg compress method. I'm getting the compression rate (0.1-1.0) from the config.json. (I agreed with the client that they wanted to have a compression rate for each type of device that they could use, iPad, iPhone, iPod). Videos are using a custom function that compressed the audio and video bits and converts the video (that is first a .mov) to a .mp4. 
[I found therefore an article that had already a good basis and I extended that algorithm with my custom logic for my needs.](https://medium.com/samkirkiles/swift-using-avassetwriter-to-compress-video-files-for-network-transfer-4dcc7b4288c5)
When the user clicks on "Abschicken" the compression and transfer will be loaded in a side thread, the main thread displays a loading indicator. After successfully transferring all data, the user will get a prompt that shows him what he sent.

####Barcode that a user can scan to automatically fill out some form fields:
<p align="center">
    <img src="https://i.ibb.co/HqNGfN9/Screenshot-2021-05-03-at-23-02-31.png" max-height="500">
</p>

##### 4. Beyond the app / what the server receives

The Server gets a JSON File, named like for example: 
```543271_10_20200708_160956_0.json ```
Order-Nr, Positions-Nr, Date, Time, Counter for multiple Images

The sent JSON is structured in the following way:

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
If there is an error, the pods need to be rebuild. This is because one of the pods causes sometimes a compiler error for newer Xcode versions. Just download cocoa pods 
```sudo gem install cocoapods```
Go to the Folder of the Project (Segler-Master)
```pod deintegrate```
```pod install```

## What's next?
* Storing the downloaded PDFs in the FileManager system, with that, I don't need to redownload every pdf.
* Storing Server Credentials not in UserDefaults, instead of in CoreData. (UserDefaults is not encrypted so it is currently a security risk)!
* Eventually: refactoring the whole state process management. Back then, SwiftUI had really limited capabilities to work with it. (example: had to pass EnvironmentObjects manually to every child's view (what a mess!)). Now, I refactored already a lot to use newer and better techniques.
* Creating a bidirectional system to transfer data. We are currently exploring the capabilities of WebSockets to transfer real-time data. Idea is, use types something into the project number search field, the app suggests to him already what kind of projects he can choose and which ones are valid/existing.
* Refactoring the whole Images and Video structs. I currently have 4 structs, ImageCamera, Image, Video, VideoCamera. I will combine them with an enum + switch case method to simply adapt methods to the needs of the object. Sadly, hadn't enough time yet to refactor that.


## Other App
If you want to see an implementation of CoreData and fetching APIs, I also have another project called Chimp. It is a MacOS App, but it uses the same methods, functions, and components with SwiftUI as an iOS App. Therefore, there is not a huge difference and it could run also on an iPhone without too much effort (the benefit of SwiftUI). CoreData has here again the following benefits:
Better structured data then UserDefaults (UserDefaults can only store primitive datatypes)
Encrypted Data therefore better security