// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CRDT",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "CRDTKit", targets: ["CRDTKit"]),
        .library(name: "CRDTUI", targets: ["CRDTUI"]),
        .library(name: "Multipeer", targets: ["Multipeer"]),
    ],
    dependencies: [
    ],
    targets: [

        .target(name: "CRDTKit"),
        
        .testTarget(
            name: "CRDTKitTests",
            dependencies: [
                "CRDTKit"
            ]),

        .target(
            name: "CRDTUI",
            dependencies: [
                "CRDTKit",
                "Multipeer",
            ]),
        
        .target(name: "Multipeer"),
    ]
)
