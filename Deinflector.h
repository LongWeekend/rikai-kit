//
//  Deinflector.h
//  RikaiKit
//
//  Created by Ross on 6/29/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import <Foundation/Foundation.h>
#import "DeinflectorRuleMatch.h"

#define kRikaiKitDeinflectionDB @"deinflect"
#define kRikaiKitDeinflectionDBExt @"dat"

@interface Deinflector : NSObject {
  NSMutableDictionary *reasons;
  NSMutableDictionary *rules;
  NSMutableArray *rulesArray;
}

//! Returns the singleton instance
+(Deinflector *)sharedInstance;

//! Method for deinflecting words
- (NSArray*) deinflect:(NSString*) word;

@property (nonatomic, retain) NSMutableDictionary *reasons;
@property (nonatomic, retain) NSMutableDictionary *rules;
@property (nonatomic, retain) NSMutableArray *rulesArray;
@end
