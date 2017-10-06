/*****
 MIT License
 
 Copyright (c) 2017 ProVivus Health AB
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 *****/

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

    func rawEncode(_ parameterTypes:Array<String>, _ parameterValues:Array<String>) -> String
    {
        return encodeParams(parameterTypes, parameterValues)!
    }

}

