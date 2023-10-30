

import Foundation

extension Data {
    public var uint64Value: UInt64? {
        guard count <= 8, !isEmpty else { // check if suitable for UInt64
            return nil
        }
        var value: UInt64 = 0
        for (index, byte) in self.enumerated() {
            value += UInt64(byte) << UInt64(8 * (count - index - 1))
        }
        return value
    }
}
