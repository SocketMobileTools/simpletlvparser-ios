//
//  SKTTLVParser.m
//  Capture
//
//  Created by Chrishon Wyllie on 4/3/20.
//  Copyright © 2020 SocketMobile. All rights reserved.
//

#import "SKTTLVParser.h"

@implementation SKTTLVParser
-(id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

+(NSDictionary*)parseDataForTLVFormat:(NSData *)tlvData {
    NSMutableDictionary* TLVsDictionary = [NSMutableDictionary new];
    
     const int TLV_MIN_SIZE = 3; // 1 byte for T, 1 byte for L 1 byte for V
     int index = 0;
    
     uint8_t* decodedDataBytes = (uint8_t *)[tlvData bytes];
    
     NSInteger totalLengthOfData = tlvData.length;
    
     while ((index + TLV_MIN_SIZE) < totalLengthOfData) {
         uint8_t tag = decodedDataBytes[index++];
         uint8_t length = decodedDataBytes[index++];
         
         if (length == 0) {
             [NSException raise:@"Invalid length" format:@"The length specified did not match the length of the data"];
             continue;
         }
         
         uint8_t* value = &decodedDataBytes[index];
         
         if(index + length > totalLengthOfData) {
             // THROW AN OUT OF RANGE EXCEPTION
             [NSException raise:@"Index out of bounds error" format:@"The index has gone out of bounds in regards to the NSData bytes"];
         }
         
         index += length;
         
         NSData* tagData = [NSData dataWithBytes:value length:length];
         [TLVsDictionary setObject:tagData forKey:[NSString stringWithFormat:@"%02X", tag]];
     }
     return TLVsDictionary;
}
@end
