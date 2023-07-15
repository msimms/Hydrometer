# Hydrometer

A simple SwiftUI application that reads from [Tilt](https://tilthydrometer.com/) hydrometers (used in homebrewing) and logs the readings to a .csv file stored on the user's iCloud drive.

## Rationale

I wanted to leave an iPad within Bluetooth range of my brewing equipment and have it periodically update a file on my iCloud drive with the temperature and specific gravity data from the hydrometer. 

## Architecture

The Tilt hydrometer sends temperature and specific gravity measurements using iBeacon. The data is encoded in the `major` and `minor` fields of the Beacon packet. Apple operating systems use CoreLocation to deliver iBeacon packets, even though iBeacon is built on top of Bluetooth Low Energy (BTLE).

## Building
This app is built using Apple XCode. Every attempt is made to stay up-to-date with the latest version of XCode and the latest version of iOS. In theory, if you have cloned the source code repository and initialized the submodules, then you should be able to open the project in XCode, build, and deploy.
```
git clone https://github.com/msimms/Hydrometer
cd Hydrometer
git submodule update --init
```

## Version History
1.0 - Initial release
