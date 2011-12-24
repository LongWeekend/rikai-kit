//
//  DeinflectorReason.h
//  RikaiKit
//
//  Created by Paul on 30/6/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import <Foundation/Foundation.h>


@interface DeinflectorReason : NSObject {
  NSString *description;
  NSInteger reasonID;
}

+ (DeinflectorReason*) reasonWithDescription:(NSString*)description reasonID:(NSInteger)reasonID;

@property (nonatomic,retain) NSString *description;
@property (nonatomic) NSInteger reasonID;
@end
