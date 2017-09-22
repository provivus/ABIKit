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

struct ABI {
 
    public func methodID(name:String, parameterTypes:Array<String>) -> String
    {
        var i=0
        var pack = ""
    
        for parameterType in parameterTypes {
            if i==0 {
                pack = parameterType
            }
            else
            {
                pack = pack+","+parameterType
            }
            i = i+1
        }
    
        let signature = name+"("+pack+")"
        let signatureHash = (signature.data(using: String.Encoding.utf8)!.keccak()).hexEncodedString()
        let indx = signatureHash.index(signatureHash.startIndex, offsetBy: 8)
        let methodSignature = signatureHash.substring(to:indx)
    
        return methodSignature.lowercased()
    }

    public func encodeParam(type: String, value: String) -> String? {
        
        switch type {
        case "int","int8","int16","int32","int64","int128","int256":
            var bn = BigNumber(decimalString: value)!
            
            
            if bn.isNegative {
                let bn1 = bn.complement()
                let bn2 = bn1?.add(BigNumber.constantOne())
                bn = bn2!
                //bn = bn1!
            }
            
            
            return truncateAndPad(bn: bn)
        case "uint","uint8","uint16","uint32","uint64","uint128","uint256": // Tested and working
            let bn = BigNumber(decimalString: value)!
            if bn.isNegative { // This is an error
                return nil
            }
            return truncateAndPad(bn: bn)
        case "address": // Tested and working
            // just left pad with zeros
            let bn = BigNumber(hexString: value)!
            return truncateAndPad(bn: bn)
        case "string":
            /* enc(X) = enc(enc_utf8(X)), i.e. X is utf-8 encoded and this value is interpreted as of bytes type and encoded further. Note that the length used in this subsequent encoding is the number of bytes of the utf-8 encoded string, not its number of characters. */
            
            let str = value
            let data = str.data(using: .utf8)!
            let hexString = data.map{ String(format:"%02x", $0) }.joined()
            
            let len = hexString.lengthOfBytes(using: .utf8)
            let bn = BigNumber(integer: len/2)
            let p = BigNumber(integer: 32)
            
            /*
             bytes, of length k (which is assumed to be of type uint256):
             
             enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a uint256 followed by the actual value of X as a byte sequence, followed by the minimum number of zero-bytes such that len(enc(X)) is a multiple of 32.*/
            
            return truncateAndPad(bn: p!) + truncateAndPad(bn: bn!) + hexString.rightPad()
        case "bytes":
            
            let hexString = value.deHexPrefix()
            let len = hexString.lengthOfBytes(using: .utf8)
            let bn = BigNumber(integer: len/2)
            let p = BigNumber(integer: 32)
            
            /*
             bytes, of length k (which is assumed to be of type uint256):
             
             enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a uint256 followed by the actual value of X as a byte sequence, followed by the minimum number of zero-bytes such that len(enc(X)) is a multiple of 32.*/
            
             return truncateAndPad(bn: p!) +  truncateAndPad(bn: bn!) + hexString.rightPad()
        case "bytes32":
            
            let str = value.deHexPrefix()
            return str.rightPad32()
            
        default:
            return nil
        }
        
    }

    public func encodeParams(_ parameterTypes: Array<String>, _ parameterValues: Array<String>) -> String? {
    
        var i=0
        var parameterSignature = ""
        for parameterType in parameterTypes {
       
            let matched = matches(for: "^((u?int|bytes)([0-9]*)|(address|bool|string)|([([0-9]*)]))", in: parameterType)
            
            for match in matched {
                parameterSignature = parameterSignature + encodeParam(type: match, value: parameterValues[i])!
            }
            i = i + 1
        }
        return parameterSignature.lowercased()
    }

    func rawEncode(_ parameterTypes:Array<String>, _ parameterValues:Array<String>) -> String
    {
        return encodeParams(parameterTypes, parameterValues)!
    }

}

