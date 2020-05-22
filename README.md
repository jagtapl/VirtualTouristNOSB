# Virtual Tourist
The app allows user to drop pins on a map as if they were stops on a tour. User will be able to download the photos for pin location. And app also persists the location of pin and downloaded images on the local phone.
The app stores the images locally using Core Data, and displays it using Collection View.

This project uses a Core Data framework, to persists the images as collection. Also it saves current view size of visible map using the plist persistence..

- the user interface is build programmatically without storey board.
- downloads public images using Flickr REST api
- user interface communicates the network actiity and image download progress


# Requirements
- Xcode 11.2 or later
- iOS 13.2 or later

# Installatation
1. Download project zip or clone the repo (`git clone https://github.com/jagtapl/VirtualTouristNOSB)
2. Navigate to the project folder in Terminal.
3. Open Virtual PitchPerfect.xcodeproj.
4. Build and Run in iOS Simulator or on your device.

# Overview of the App
1. Record the sound by tapping the microphone icon.
2. Stop recording, and app will push the new scene with button for unique audio type of filter.
3. Select audio filter to play recorded audio by tapping a button like Chipmunk, Parrot etc


