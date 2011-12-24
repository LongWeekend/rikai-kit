//
//  ProgressiveSearch.m
//  Rikai
//
//  Created by paul on 1/7/10.
//  Copyright 2010 LONG WEEKEND INC. All rights reserved.
//

#import "Deinflector.h"

@protocol ProgressiveSearchDelegate
-(NSArray*)progressiveSearchForKeyword:(NSString*)keyword; //! IMPORTANT: delegate must return an NSArray of NSString objects
@end

@interface ProgressiveSearch : NSObject

//! Progressive search methods
- (NSArray*) progressiveSearchForKeyword:(NSString*)keyword maxResults:(NSInteger)max;

//! Class method helper
+ (NSArray*) katakanaToHiragana:(NSString*)inputWord;

@property (nonatomic, retain) id<ProgressiveSearchDelegate>delegate;
@end