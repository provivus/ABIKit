//
//  contract.swift
//  ABIKit
//
//  Created by Johan Sellström on 2017-09-09.
//  Copyright © 2017 Johan Sellström. All rights reserved.
//


import Gloss

struct Contract: Glossy {
    
    let contractName: String
    let unlinkedBinary: String
    let schemaVersion: String
    let updatedAt: Int
    let abi: [Method] // nested model
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        
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
    
    func toJSON() -> JSON? {
        return jsonify([
            "contract_name" ~~> self.contractName,
            "abi" ~~> self.abi,
            "unlinked_binary" ~~> self.unlinkedBinary,
            "schema_version" ~~> self.schemaVersion,
            "updated_at" ~~> self.updatedAt
            ])
    }
    
    func find(name: String) -> Method? {
        for method in abi {
            if method.name == name {
                return method
            }
        }
        return nil
        
    }
}
