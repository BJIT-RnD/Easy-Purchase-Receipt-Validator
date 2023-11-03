import Foundation

extension Data {
    /// Get the UInt64 value from the data, interpreting it as a little-endian binary representation.
    ///
    /// - Returns: The UInt64 value if the data is suitable for conversion, otherwise nil.
    public var uint64Value: UInt64? {
        guard count <= 8, !isEmpty else {
            // Check if the data is suitable for converting to UInt64 (up to 8 bytes in length)
            return nil
        }
        var value: UInt64 = 0
        for (index, byte) in self.enumerated() {
            // Iterate through the data bytes, interpreting them as little-endian, and build the UInt64 value.
            value += UInt64(byte) << UInt64(8 * (count - index - 1))
        }
        return value
    }
}

