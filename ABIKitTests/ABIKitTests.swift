//
//  ABIKitTests.swift
//  ABIKitTests
//
//  Created by Johan Sellström on 2017-09-09.
//  Copyright © 2017 Johan Sellström. All rights reserved.
//

import XCTest
@testable import ABIKit
import ethers

//[[NSBundle bundleForClass:[self class]] resourcePath]


public func readJson(fileName:(String)) -> Data? {
    do {
        
        let bundle = Bundle.init(for: ABIKitTests.self)
        
        
        if let file = bundle.url(forResource: fileName, withExtension: "json") {
            
           // Bundle.main.url(forResource: fileName, withExtension: "json") {
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


class ABIKitTests: XCTestCase {
    
    var contractData:Data?
    var contract:Contract?
    let abi = ABI()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.''
        /*
        if let contractData = readJson(fileName: "contracts") {
            print("contractData", contractData)
            contract = Contract(data: contractData)
        }*/
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNegativeInt32() {
        
        let a = abi.rawEncode([ "int32" ], [ "-2" ])
        let b = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        XCTAssertEqual(a,b)
     }


    func testLongString() {
        
        let a = abi.rawEncode([ "string" ], [ " hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world" ])
        let b = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000"
        XCTAssertEqual(a,b)
    }
 
    
    func testData() {
        
        let a = abi.rawEncode([ "bytes32", "address", "bytes32" ], [ "0x75506f727450726f66696c654950465331323230000000000000000000000000", "0xC8092eCeE9fbAD26dC71883506D81A9Ff87c0F9B", "0xd47dd2956fb8a0434b92a4476449c9aa3ed2c14444b183653e3a15000e0dcab2" ])
        let b = "fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac00000000000000"
        XCTAssertEqual(a,b)
    }
    
    
    func testNegativeInt256() {
        
        let a = abi.rawEncode([ "int256" ], [ "-19999999999999999999999999999999999999999999999999999999999999" ])
        let b = "fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac00000000000000"
        XCTAssertEqual(a,b)
    }
    
    func testNegativeInt256II() {
        
        let a = abi.rawEncode([ "int256" ], [ "-1" ])
        let b = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        XCTAssertEqual(a,b)
    }

    func testUint32() {
        
        let a = abi.rawEncode([ "uint32" ], [ "42" ])
        let b = "000000000000000000000000000000000000000000000000000000000000002a"
        XCTAssertEqual(a,b)
    }
    
    func testString() {
        
        let a = abi.rawEncode([ "string" ], [ "a response string (unsupported)" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001f6120726573706f6e736520737472696e672028756e737570706f727465642900"
        XCTAssertEqual(a,b)
    }
    
    func testUint256() {
        
        let a = abi.rawEncode([ "uint256" ], [ "1" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000001"
        XCTAssertEqual(a,b)
    }

    func testUint256388() {
        
        let a = abi.rawEncode([ "uint256" ], [ "388" ])
        print(a)
        let b = "0000000000000000000000000000000000000000000000000000000000000184"
        XCTAssertEqual(a,b)
    }

    func testUint() {
        
        let a = abi.rawEncode([ "uint" ], [ "1" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000001"
        XCTAssertEqual(a,b)
    }
    
    func testInt256() {
        
        let a = abi.rawEncode([ "int256" ], [ "-1" ])
        let b = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        XCTAssertEqual(a,b)
    }
    
    /*
    func testBytes33() {
        
        let a = abi.rawEncode([ "bytes33" ], [ "" ])
        let b = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        XCTAssertEqual(a,b)
    }
    */
    
    func test256BitsAsBytes() {
        
        let a = abi.rawEncode([ "bytes" ], [ "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff" ])
        let b = "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        XCTAssertEqual(a,b)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
