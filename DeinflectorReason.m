//
//  DeinflectorReason.m
//  RikaiKit
//
//  Created by Paul on 30/6/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import "DeinflectorReason.h"

@implementation DeinflectorReason
@synthesize description, reasonID;

//! Factory method for creating DeinflectorReason objects
+ (DeinflectorReason*) reasonWithDescription:(NSString*)description reasonID:(NSInteger)reasonID
{
  DeinflectorReason *tmp = [[[DeinflectorReason alloc] init] autorelease];
  [tmp setDescription:description];
  [tmp setReasonID:reasonID];
  return tmp;
}
@end
