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
1. Press long tap on the preferred location on the map, to drop a pin.
2. Tap on the pin, and the app will transition to next view to show downloaded images for assocatied location.
3. Press New Collection button at bottom of view, to download next set of images from Flickr service.
4. Tap Edit to delete a pin or image by tapping on it.

