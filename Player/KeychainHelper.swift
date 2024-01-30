
import Foundation
import Security

extension Data {
    init(from value: Bool) {
        var value = value
        self = withUnsafePointer(to: &value) { pointer -> Data in
            Data(bytes: pointer, count: MemoryLayout<Bool>.size)
        }
    }

    func toBool() -> Bool? {
        guard count == MemoryLayout<Bool>.size else { return nil }
        return withUnsafeBytes { $0.load(as: Bool.self) }
    }
}

class KeychainHelper {
    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ] as [String: Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    static func saveBoolean(key: String, value: Bool) -> OSStatus {
        let data = Data(from: value)
        return save(key: key, data: data)
    }

    static func loadBoolean(key: String) -> Bool? {
        guard let data = load(key: key) else { return nil }
        return data.toBool()
    }
}
