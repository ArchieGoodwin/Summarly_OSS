//
//  Contants.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation

// MARK: - Constants

/// Constants hardcoded or read from plist config files.
@objcMembers public class Constants: NSObject {

    public static var aiToken: () -> String = { Bundle.main.getValue(for: "AIToken") }

}



public extension Bundle {
    /// Returns defined value for the given key in the info.plist file.
    func getValue(for key: String) -> String {
        guard let value = infoDictionary?[key] as? String else {
            fatalError("Key \(key) is not defined in the info.plist file.")
        }
        return value
    }
}
