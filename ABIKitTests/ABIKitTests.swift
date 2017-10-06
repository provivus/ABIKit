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

import XCTest
@testable import ABIKit
import EtherKit

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
    /*
    forwardTo hexString 75506f727450726f66696c654950465331323230
    set parameterValues [Optional("75506f727450726f66696c654950465331323230"), Optional("0x646EcB34c9b0d37a25F4AFDCe213612716Ec781d"), Optional("0xa07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e")]
    input: IOParameter(indexed: nil, name: "registrationIdentifier", type: "bytes32")
    value: 75506f727450726f66696c654950465331323230
    rightPad32 40
    encoded: 75506f727450726f66696c654950465331323230000000000000000000000000
    rightPad32 40
    input: IOParameter(indexed: nil, name: "subject", type: "address")
    value: 0x646EcB34c9b0d37a25F4AFDCe213612716Ec781d
    encoded: 000000000000000000000000646ECB34C9B0D37A25F4AFDCE213612716EC781D
    input: IOParameter(indexed: nil, name: "value", type: "bytes32")
    value: 0xa07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e
    rightPad32 64
    encoded: a07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e
    rightPad32 64
    final encoding 0xd79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000646ECB34C9B0D37A25F4AFDCE213612716EC781Da07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e
    input: IOParameter(indexed: nil, name: "registrationIdentifier", type: "bytes32")
    value: 75506f727450726f66696c654950465331323230
    rightPad32 40
    encoded: 75506f727450726f66696c654950465331323230000000000000000000000000
    rightPad32 40
    input: IOParameter(indexed: nil, name: "subject", type: "address")
    value: 0x646EcB34c9b0d37a25F4AFDCe213612716Ec781d
    encoded: 000000000000000000000000646ECB34C9B0D37A25F4AFDCE213612716EC781D
    input: IOParameter(indexed: nil, name: "value", type: "bytes32")
    value: 0xa07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e
    rightPad32 64
    encoded: a07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e
    rightPad32 64
    forwardTo dataStr Optional("0xd79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000646ecb34c9b0d37a25f4afdce213612716ec781da07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e")
    forwardTo  0x6741e892B9a2a88fC57AA93B4a0952913320C941 0x646EcB34c9b0d37a25F4AFDCe213612716Ec781d 0x2a568930Ca544EFF2d80C761D435de29501CD742 0 0xd79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000646ecb34c9b0d37a25f4afdce213612716ec781da07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e

 */
    
    func testdataStr() {
        
        let a = abi.methodID(name: "set", parameterTypes: ["bytes32","address","bytes32"])  +  abi.rawEncode([ "bytes32", "address", "bytes32" ], [ "0x75506f727450726f66696c654950465331323230", "0x646EcB34c9b0d37a25F4AFDCe213612716Ec781d", "0xa07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e" ])
        let b = "d79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000646ecb34c9b0d37a25f4afdce213612716ec781da07cd2b1f1955ed8ac6d6487228a487cc5008babacb1d5985c8015613871aa0e"
        
        XCTAssertEqual(a,b)
    }

    
    func testXData() {
        
        let a = abi.rawEncode([ "bytes32", "address", "bytes32" ], [ "0x75506f727450726f66696c654950465331323230000000000000000000000000", "0xC8092eCeE9fbAD26dC71883506D81A9Ff87c0F9B", "0xd47dd2956fb8a0434b92a4476449c9aa3ed2c14444b183653e3a15000e0dcab2" ])
        let b = "75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000c8092ecee9fbad26dc71883506d81a9ff87c0f9bd47dd2956fb8a0434b92a4476449c9aa3ed2c14444b183653e3a15000e0dcab2"
        XCTAssertEqual(a,b)
    }
    
    
    func testNegativeInt256() {
        
        let a = abi.rawEncode([ "int256" ], [  "-19999999999999999999999999999999999999999999999999999999999999" ])
        let b = "fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001"
        XCTAssertEqual(a,b)
    }
    
    func testNegativeInt256II() {
        
        let a = abi.rawEncode([ "int256" ], [ "-1" ])
        let b = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        XCTAssertEqual(a,b)
    }
    
    func testMegaBytes() {
        let a = abi.rawEncode([ "bytes" ], [ "0xd79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000447ea5c36e883acec07e63058d92258ff7bbceb24344ae2805b2a53a6aefc43d76fae8119dd1e80e882aae4137bd2fbdb40b2c00" ])
        
        
        let b  = "00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000064d79d8e6c75506f727450726f66696c654950465331323230000000000000000000000000000000000000000000000000447ea5c36e883acec07e63058d92258ff7bbceb24344ae2805b2a53a6aefc43d76fae8119dd1e80e882aae4137bd2fbdb40b2c0000000000000000000000000000000000000000000000000000000000"
        print(a,b)
        
        XCTAssertEqual(a,b)
    }

    func testUint256() {
        
        let a = abi.rawEncode([ "uint256" ], [ "0" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000000"
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
    
    func testUint256Y() {
        
        let a = abi.rawEncode([ "uint256" ], [ "1" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000001"
        XCTAssertEqual(a,b)
    }

    func testUint200() {
        
        let a = abi.rawEncode([ "uint256" ], [ "200" ])
        let b = "00000000000000000000000000000000000000000000000000000000000000c8"
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
    
    func testFewBytes()
    {
        let a = abi.rawEncode([ "bytes" ], [ "0x6761766f66796f726b" ])
        let b = "0000000000000000000000000000000000000000000000000000000000000020" + "0000000000000000000000000000000000000000000000000000000000000009" + "6761766f66796f726b0000000000000000000000000000000000000000000000"
    
        
        XCTAssertEqual(a,b)
    }

    func testManyBytes()
    {
    let a = abi.rawEncode([ "bytes" ], [ "0x731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b" ])
    let b = "0000000000000000000000000000000000000000000000000000000000000020" + "0000000000000000000000000000000000000000000000000000000000000020" + "731a3afc00d1b1e3461b955e53fc866dcf303b3eb9f4c16f89e388930f48134b"
        
        XCTAssertEqual(a,b)
    }
    
 
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
