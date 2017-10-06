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

public struct Contract: Glossy {
    
    let contractName: String
    public let unlinkedBinary: String
    let schemaVersion: String
    let updatedAt: Int
    let abi: [Method] // nested model
    
    // MARK: - Deserialization
    
    public init?(json: JSON) {
        
        guard let contractName: String = "contract_name" <~~ json,
            let abi: [Method] = "abi" <~~ json,
            let unlinkedBinary: String = "unlinked_binary" <~~ json,
            let schemaVersion: String = "schema_version" <~~ json,
            let updatedAt: Int = "updated_at" <~~ json else {
                print("fail")
                return nil
        }
        
        self.contractName = contractName
        self.abi = abi
        self.unlinkedBinary = unlinkedBinary
        self.schemaVersion = schemaVersion
        self.updatedAt = updatedAt
    }
    
    // MARK: - Serialization
    
    public func toJSON() -> JSON? {
        return jsonify([
            "contract_name" ~~> self.contractName,
            "abi" ~~> self.abi,
            "unlinked_binary" ~~> self.unlinkedBinary,
            "schema_version" ~~> self.schemaVersion,
            "updated_at" ~~> self.updatedAt
            ])
    }
    
    public func find(name: String) -> Method? {
        for method in abi {
            if method.name == name {
                return method
            }
        }
        return nil
        
    }
}
