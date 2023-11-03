import Foundation

/// An enumeration representing possible decoding errors.
enum DecoderError: Error {
    /// An error indicating a parsing failure during decoding.
    case parseError
    /// An error indicating that a buffer bound was exceeded during decoding.
    case BufferBoundError
    /// An error indicating an unknown or unexpected error during decoding.
    case unknownError
}

