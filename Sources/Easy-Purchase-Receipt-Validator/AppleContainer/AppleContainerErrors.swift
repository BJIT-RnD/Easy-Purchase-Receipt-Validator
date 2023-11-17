/**
 File Name: `ContainerError.swift`

 Description: This file defines the `ContainerError` enum, which enumerates possible errors related to container operations. It conforms to the `Error` protocol.

 ## Error Cases

 1. `invalid`: Indicates that the container is invalid.
 2. `parsingIssue`: Indicates an issue with parsing the container data.
*/

import Foundation

enum ContainerError: Error {
    case invalid
    case parsingIssue
}
