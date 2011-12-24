//
//  DeinflectorRule.m
//  RikaiKit
//
//  Created by Paul on 30/6/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import "DeinflectorRule.h"


@implementation DeinflectorRule
@synthesize inflectedString, deinflectedString, typeBitMask, reason;

//! Factory method for creating DeinflectorRule objects
+ (DeinflectorRule*) ruleWithInflectedString:(NSString*)inflectedString deinflectedString:(NSString*)deinflectedString typeBitMask:(NSInteger)typeBitMask reason:(DeinflectorReason*)reason;
{
  DeinflectorRule *tmp = [[[DeinflectorRule alloc] init] autorelease];
  [tmp setInflectedString:inflectedString];
  [tmp setDeinflectedString:deinflectedString];
  [tmp setTypeBitMask:typeBitMask];
  [tmp setReason:reason];
  return tmp;
}
@end