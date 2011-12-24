//
//  DeinflectorRuleMatch.m
//  RikaiKit
//
//  Created by Paul on 1/7/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import "DeinflectorRuleMatch.h"

@implementation DeinflectorRuleMatch
@synthesize word, typeBitMask, reasonString;

//! Factory method for creating DeinflectorRuleMatch objects
+ (DeinflectorRuleMatch*) ruleMatchWith:(NSString*)word typeBitMask:(NSInteger)typeBitMask reasonString:(NSString*)reasonString
{
  DeinflectorRuleMatch *tmp = [[[DeinflectorRuleMatch alloc] init] autorelease];
  [tmp setWord:word];
  [tmp setTypeBitMask:typeBitMask];
  [tmp setReasonString:reasonString];
  return tmp;
}

@end
