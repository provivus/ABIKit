//
//  utilities.swift
//  ABIKit
//
//  Created by Johan Sellström on 2017-09-09.
//  Copyright © 2017 Johan Sellström. All rights reserved.
//

import Foundation
import EtherKit

public func readJson(fileName:(String)) -> Data? {
    do {
        if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
            let data = try Data(contentsOf: file)
            return data
        } else {
            print("no file")
            return nil
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func truncateAndPad(bn: BigNumber) -> String {
    let hexStr = bn.hexString
    let startIndex = hexStr?.index((hexStr?.startIndex)!, offsetBy: 2)
    let truncated = hexStr?.substring(from: startIndex!)
    return (truncated?.leftPad(toWidth: 64))!
}



let defaultPaddingString = "0"
let defaultPaddingByte = 0 as UInt8


public extension String {
    
    func decodeABI() ->  Array<String> {
        // Split by 64 byte words, remove the 0x
        let startIndex = self.index(self.startIndex, offsetBy: 2)
        let endIndex = self.endIndex
        let words = self[startIndex..<endIndex].split(64)
        
        var strings = [String]()
        for word in words {
            //print(word)
            let hexString = BigNumber(hexString: "0x"+word).hexString
            //print(bn?.hexString)
            strings.append(hexString!)
        }
        
        return strings
    }
    
    
     func deHexPrefix() -> String {
        
        
        let index = self.index((self.startIndex), offsetBy: 2)
        let prefix = self.substring(to: index)
        
        if prefix == "0x" {
            let startIndex = self.index((self.startIndex), offsetBy: 2)
            return self.substring(from: startIndex)
        } else {
            return self
        }
        
     }
    
    
    public func leftPad(toWidth width: Int) -> String {
        return leftPad(toWidth: width, withString: defaultPaddingString)
    }
    
    public func leftPad(toWidth width: Int, withString string: String?) -> String {
        let paddingString = string ?? defaultPaddingString
        
        if self.characters.count >= width {
            return self
        }
        
        let remainingLength: Int = width - self.characters.count
        var padString = String()
        for _ in 0 ..< remainingLength {
            padString += paddingString
        }
        
        return [padString, self].joined(separator: "")
    }
    
    public func rightPad() -> String {
        return rightPad(withString: defaultPaddingString)
    }
    
    public func rightPad(withString string: String?) -> String {
        
        let paddingString = string ?? defaultPaddingString
        
        let len = self.characters.count
        
        print("rightPad", len)
        
        let add = len%64 == 0 ? 0: 64 - len%64
        
        var padString = String()
        
        for _ in 0 ..< add {
            padString += paddingString
        }
        
        return [self, padString].joined(separator: "")
    }
    
    public func rightPad32() -> String {
        return rightPad32(withString: defaultPaddingString)
    }
    
    public func rightPad32(withString string: String?) -> String {
        
        let paddingString = string ?? defaultPaddingString
        
        let len = self.characters.count
        print("rightPad32", len)
        let add = len%64 == 0 ? 0: 64 - len%64
        var padString = String()
        
        for _ in 0 ..< add {
            padString += paddingString
        }
        
        return [self, padString].joined(separator: "")
    }
    
    public func split( _ count: Int) -> [String] {
        return stride(from: 0, to: self.characters.count, by: count).map { i -> String in
            let startIndex = self.index(self.startIndex, offsetBy: i)
            let endIndex   = self.index(startIndex, offsetBy: count, limitedBy: self.endIndex) ?? self.endIndex
            return self[startIndex..<endIndex]
        }
    }
    
    public func hexaData() -> Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}


extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
