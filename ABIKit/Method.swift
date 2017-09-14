//
//  Function.swift
//  EthersWallet
//
//  Created by Johan Sellström on 2017-07-26.
//  Copyright © 2017 ethers.io. All rights reserved.
//

import Gloss
import SwiftKeccak
import EtherKit

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


public struct Method: Glossy {
    
    let anonymous: Bool?
    let constant: Bool?
    let inputs: [IOParameter]?
    let name: String?
    let outputs: [IOParameter]?
    let payable: Bool?
    let type: String
    
    // MARK: - Deserialization
    
    public init?(json: JSON) {
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
    
    public func toJSON() -> JSON? {
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
    
    public func encode(values: Array<String>) -> String? {
        
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
        
        //print("final encoding",  "0x"+methodSignature+parameterSignature(values: values)!)
        return "0x"+methodSignature+parameterSignature(values: values)!
    }
    
    func parameterSignature(values: Array<String>) -> String? {
        
        var i=0
        var parameterSignature = ""
        for input in inputs! {
            
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
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                case "uint","uint8","uint16","uint32","uint64","uint128","uint256": // Tested and working
                    bn = BigNumber(decimalString: values[i])
                    if bn.isNegative { // This is an error
                        return nil
                    }
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                case "address": // Tested and working
                    // just left pad with zeros
                    bn = BigNumber(hexString: values[i])
                    parameterSignature = parameterSignature + truncateAndPad(bn: bn)
                    break
                    
                case "string":
                    
                    // let utf8 = String(values[i].utf8)
                    
                    /* enc(X) = enc(enc_utf8(X)), i.e. X is utf-8 encoded and this value is interpreted as of bytes type and encoded further. Note that the length used in this subsequent encoding is the number of bytes of the utf-8 encoded string, not its number of characters. */
                    
                    let str = values[i]
                    let data = str.data(using: .utf8)!
                    let hexString = data.map{ String(format:"%02x", $0) }.joined()
                    
                    let startIndex = hexString.index((hexString.startIndex), offsetBy: 2)
                    let truncated = hexString.substring(from: startIndex)
                    
                    /*
                     bytes, of length k (which is assumed to be of type uint256):
                     
                     enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a uint256 followed by the actual value of X as a byte sequence, followed by the minimum number of zero-bytes such that len(enc(X)) is a multiple of 32.*/
                    
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


