//
//  Function.swift
//  EthersWallet
//
//  Created by Johan Sellström on 2017-07-26.
//  Copyright © 2017 ethers.io. All rights reserved.
//

import Gloss
import SwiftKeccak
import ethers

struct IOParameter: Glossy {
    
    let indexed: Bool?
    let name: String
    let type: String
    
    init?(json: JSON) {
        
        guard let name: String = "name" <~~ json,
            let type: String = "type"  <~~ json
            else {
                print("IOParameter fail")
                return nil
        }
        
        self.name = name
        self.type = type
        self.indexed = "indexed"  <~~ json
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "type" ~~> self.type
            ])
    }
}

func truncateAndPad(bn: BigNumber) -> String {
    let hexStr = bn.hexString
    let startIndex = hexStr?.index((hexStr?.startIndex)!, offsetBy: 2)
    let truncated = hexStr?.substring(from: startIndex!)
    return (truncated?.leftPad(toWidth: 64))!
}

struct Function: Glossy {
    
    let anonymous: Bool?
    let constant: Bool?
    let inputs: [IOParameter]?
    let name: String?
    let outputs: [IOParameter]?
    let payable: Bool?
    let type: String
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let type: String = "type"  <~~ json
            else {
                print("Function failed")
                return nil
        }
        self.inputs  =  "inputs"  <~~ json
        self.outputs = "outputs"  <~~ json
        self.name = "name" <~~ json
        self.constant = "constant"  <~~ json
        self.anonymous = "anonymous"  <~~ json
        self.payable = "payable"  <~~ json
        self.type = type
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "constant" ~~> self.name,
            "inputs" ~~> self.inputs,
            "name" ~~> self.name,
            "outputs" ~~> self.outputs,
            "anonymous" ~~> self.anonymous,
            "payable" ~~> self.payable,
            "type" ~~> self.type
            ])
    }
    
    func rawEncode(parameterTypes:Array<IOParameter>, parameters:Array<String>) -> String
    {
        return parameterSignature(values: parameters)!
        
    }
    
    func methodID(name:String,parameterTypes:Array<IOParameter>) -> String
    {
        var i=0
        var pack = ""
        for parameterType in parameterTypes {
            if i==0 {
                pack = parameterType.type
            }
            else
            {
                pack = pack+","+parameterType.type
            }
            i = i+1
        }
        
        let signature = name+"("+pack+")"
        let signatureHash = (signature.data(using: String.Encoding.utf8)!.keccak()).hexEncodedString()
        let indx = signatureHash.index(signatureHash.startIndex, offsetBy: 8)
        let methodSignature = signatureHash.substring(to:indx)
        
        return methodSignature
    }
    
    func encode(values: Array<String>) -> String? {
        
        var i=0
        var encoding = ""
        for input in inputs! {
            if i==0 {
                encoding = input.type
            }
            else
            {
                encoding = encoding+","+input.type
            }
            i = i+1
        }
        
        let signature = name!+"("+encoding+")"
        let signatureHash = (signature.data(using: String.Encoding.utf8)!.keccak()).hexEncodedString()
        let indx = signatureHash.index(signatureHash.startIndex, offsetBy: 8)
        let methodSignature = signatureHash.substring(to:indx)
        return "0x"+methodSignature+parameterSignature(values: values)!
    }
    
    func parameterSignature(values: Array<String>) -> String? {
        
        var i=0
        var parameterSignature = ""
        for input in inputs! {
            
            print("input:",input)
            print("value:", values[i])
            
            let matched = matches(for: "^((u?int|bytes)([0-9]*)|(address|bool|string)|([([0-9]*)]))", in: input.type)
            
            var bn : BigNumber = BigNumber()
            
            for match in matched {
                
                switch match {
                case "int","int8","int16","int32","int64","int128","int256": // Probably works now for both positive and negative
                    
                    bn = BigNumber(decimalString: values[i])
                    if bn.isNegative {
                        
                        let bn1 = bn.complement()
                        let bn2 = bn1?.add(BigNumber.constantOne())
                        bn = bn2!
                    }
                    print("encoded:",truncateAndPad(bn: bn))
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                case "uint","uint8","uint16","uint32","uint64","uint128","uint256": // Tested and working
                    bn = BigNumber(decimalString: values[i])
                    if bn.isNegative { // This is an error
                        return nil
                    }
                    print("encoded:",truncateAndPad(bn: bn))
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                case "address": // Tested and working
                    // just left pad with zeros
                    bn = BigNumber(hexString: values[i])
                    print("encoded:",truncateAndPad(bn: bn))
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                    
                case "string":
                    
                    print("string:",values[i])
                    
                    
                    let utf8 = String(values[i].utf8)
                    
                    print("utf8:",utf8)
                    /* enc(X) = enc(enc_utf8(X)), i.e. X is utf-8 encoded and this value is interpreted as of bytes type and encoded further. Note that the length used in this subsequent encoding is the number of bytes of the utf-8 encoded string, not its number of characters. */
                    
                    let str = values[i]
                    let data = str.data(using: .utf8)!
                    let hexString = data.map{ String(format:"%02x", $0) }.joined()
                    
                    print("hexString:",hexString)
                    
                    let startIndex = hexString.index((hexString.startIndex), offsetBy: 2)
                    let truncated = hexString.substring(from: startIndex)
                    
                    /*
                     bytes, of length k (which is assumed to be of type uint256):
                     
                     enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a uint256 followed by the actual value of X as a byte sequence, followed by the minimum number of zero-bytes such that len(enc(X)) is a multiple of 32.*/
                    
                    print("encoded:", truncated.rightPad())
                    parameterSignature = parameterSignature + truncated.rightPad()
                    
                    break
                case "bytes":
                    
                    let hexString = values[i]
                    /*let str = values[i]
                     let data = str.data(using: .utf8)!
                     let hexString = data.map{ String(format:"%02x", $0) }.joined()
                     */
                    let startIndex = hexString.index((hexString.startIndex), offsetBy: 2)
                    let truncated = hexString.substring(from: startIndex)
                    
                    /*
                     bytes, of length k (which is assumed to be of type uint256):
                     
                     enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a uint256 followed by the actual value of X as a byte sequence, followed by the minimum number of zero-bytes such that len(enc(X)) is a multiple of 32.*/
                    
                    
                    print("encoded:", truncated.rightPad())
                    parameterSignature = parameterSignature + truncated.rightPad()
                    break
                case "bytes32":
                    
                    var hexString:String
                    
                    let str = values[i]
                    let index = str.index((str.startIndex), offsetBy: 2)
                    let prefix = str.substring(to: index)
                    
                    if prefix == "0x" {
                        let startIndex = str.index((str.startIndex), offsetBy: 2)
                        hexString = str.substring(from: startIndex)
                    } else {
                        hexString = str
                    }
                    
                    print("encoded:",hexString.rightPad32())
                    parameterSignature = parameterSignature + hexString.rightPad32()
                    
                    
                    break
                default: break
                }
                i = i + 1
            }
        }
        return parameterSignature
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
        let hexStr = self
        let startIndex = hexStr.index((hexStr?.startIndex)!, offsetBy: 2)
        let truncated = hexStr.substring(from: startIndex!)
        return truncated
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
        
        let bn = BigNumber(integer: len)
        
        let lenStr = truncateAndPad(bn: bn!)
        
        print("rightPad", len)
        
        let add = len%32 == 0 ? 0: 32 - len%32
        
        var padString = String()
        
        for _ in 0 ..< add {
            padString += paddingString
        }
        
        return [lenStr, self, padString].joined(separator: "")
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
