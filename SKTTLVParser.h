//
//  SKTTLVParser.h
//  Capture
//
//  Created by Chrishon Wyllie on 4/3/20.
//  Copyright © 2020 SocketMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SKTTLVParser_h
#define SKTTLVParser_h


@interface SKTTLVParser : NSObject
+(NSDictionary*)parseDataForTLVFormat:(NSData *)tlvData;
@end

#endif /* SKTTLVParser_h */
