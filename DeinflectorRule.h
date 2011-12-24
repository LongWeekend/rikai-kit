//
//  DeinflectorRule.h
//  RikaiKit
//
//  Created by Paul on 30/6/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import <Foundation/Foundation.h>
#import "DeinflectorReason.h"

@interface DeinflectorRule : NSObject {
  NSString *inflectedString;
  NSString *deinflectedString;
  NSInteger typeBitMask;
  DeinflectorReason * reason;
}

+ (DeinflectorRule*) ruleWithInflectedString:(NSString*)inflectedString deinflectedString:(NSString*)deinflectedString typeBitMask:(NSInteger)typeBitMask reason:(DeinflectorReason*)reason;

@property (nonatomic,retain) NSString *inflectedString;
@property (nonatomic,retain) NSString *deinflectedString;
@property (nonatomic) NSInteger typeBitMask;
@property (nonatomic,retain) DeinflectorReason *reason;

@end
