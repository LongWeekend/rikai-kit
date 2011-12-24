//
//  DeinflectorRuleMatch.h
//  RikaiKit
//
//  Created by Paul on 1/7/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import <Foundation/Foundation.h>
#import "DeinflectorRule.h"
#import "DeinflectorReason.h"

@interface DeinflectorRuleMatch : NSObject {
  NSString *word;
  NSInteger typeBitMask;
  NSString *reasonString;
}

+ (DeinflectorRuleMatch*) ruleMatchWith:(NSString*)word typeBitMask:(NSInteger)typeBitMask reasonString:(NSString*)reasonString;

@property (nonatomic,retain) NSString *word;
@property (nonatomic) NSInteger typeBitMask;
@property (nonatomic, retain) NSString *reasonString;
@end
