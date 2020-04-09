//
//  SKTTLVDataParserTests.m
//  CaptureLogicTests
//
//  Created by Chrishon Wyllie on 4/1/20.
//  Copyright © 2020 SocketMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKTTLVParser.h"

@interface SKTTLVDataParserTests : XCTestCase {
}
@end

@implementation SKTTLVDataParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    [super tearDown];
    // Put teardown code here. This method is called after the invocation of each test method in the class.

}


-(void)testForExistenceOfTLVDataAndHeaders {
    // Confirm that C1 and C3 exist
    // C1 represents the TagInfoIndex
    // and C3 represents the TagDataIndex
    
    NSMutableData* tlvData = [self createInitialDecodedData];
    NSDictionary* TLVsDictionary = [SKTTLVParser parseDataForTLVFormat:tlvData];
    
    NSArray* TLVKeys = TLVsDictionary.allKeys;
    
    const NSString* tagInfoKey = @"C1";
    const NSString* tagDataKey = @"C3";
    const NSString* nonExistentKey = @"C6";
    
    NSData* tagInfoPayload = (NSData*)[TLVsDictionary objectForKey:tagInfoKey];
    NSData* tagDataPayload = (NSData*)[TLVsDictionary objectForKey:tagDataKey];
    
    XCTAssertTrue([TLVKeys containsObject:tagInfoKey]);
    XCTAssertTrue([TLVKeys containsObject:tagDataKey]);
    
    int8_t expectedTagInfoBytes[] = {0x20, 0x03, 0x01, 0x00};
    int8_t expectedTagDataBytes[] = {0x68, 0x74, 0x74,
                                    0x70, 0x73, 0x3A, 0x2F, 0x2F,
                                    0x77, 0x77, 0x77, 0x2E, 0x70,
                                    0x72, 0x6F, 0x73, 0x70, 0x65,
                                    0x63, 0x74, 0x70, 0x61, 0x72,
                                    0x6B, 0x2E, 0x6F, 0x72, 0x67};
    XCTAssertEqualObjects(tagInfoPayload, [NSData dataWithBytes:&expectedTagInfoBytes length:sizeof(expectedTagInfoBytes)]);
    XCTAssertEqualObjects(tagDataPayload, [NSData dataWithBytes:&expectedTagDataBytes length:sizeof(expectedTagDataBytes)]);
    
    XCTAssertFalse([TLVKeys containsObject:nonExistentKey]);
}

-(void)testLengthEqualsZeroCase {
    NSMutableData* tlvData = [self createInitialDecodedData];
    uint8_t incorrectByte = 0x00;
    [self replaceLengthByteWithIncorrectValue:incorrectByte inTLVData:tlvData];
    
    XCTAssertThrowsSpecific([SKTTLVParser parseDataForTLVFormat:tlvData], NSException, @"Invalid length");
}

-(void)testLengthTooLargeForValue {
    NSMutableData* tlvData = [self createInitialDecodedData];
    uint8_t incorrectByte = 0xFF;
    [self replaceLengthByteWithIncorrectValue:incorrectByte inTLVData:tlvData];
    
    XCTAssertThrowsSpecific([SKTTLVParser parseDataForTLVFormat:tlvData], NSException, "Index out of bounds error");
}


#pragma mark Utility Functions

-(NSMutableData*)createInitialDecodedData {
    // 50 bytes total
    // Expected payload: "https://www.prospectpark.org
    // TLV format: C1, C2 and C3
    int8_t command1[] = {0xC1, 0x04, 0x20, 0x03, 0x01, 0x00,
                        0xC2, 0x07, 0x04, 0x62, 0x93, 0xAA, 0x10, 0x57, 0x81,
                        0xC3, 0x1C, 0x68, 0x74, 0x74,
                        0x70, 0x73, 0x3A, 0x2F, 0x2F,
                        0x77, 0x77, 0x77, 0x2E, 0x70,
                        0x72, 0x6F, 0x73, 0x70, 0x65,
                        0x63, 0x74, 0x70, 0x61, 0x72,
                        0x6B, 0x2E, 0x6F, 0x72, 0x67};
    
    return [[NSMutableData alloc]initWithBytes:&command1 length:sizeof(command1)];
}

-(void)replaceLengthByteWithIncorrectValue:(uint8_t)incorrectByte inTLVData:(NSMutableData*) tlvData {
    
    // The while loop is not expecting the length
    // of a TLV to be zero...
    
    int indexOfC1Byte = 1;
    NSRange rangeOfC1Byte = NSMakeRange(indexOfC1Byte, 1);
    [tlvData replaceBytesInRange:rangeOfC1Byte withBytes:&incorrectByte];
}

@end
