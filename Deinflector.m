//
//  Deinflector.m
//  RikaiKit
//
//  Created by Ross on 6/29/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import "Deinflector.h"
#import "DeinflectorRule.h"
#import "DeinflectorReason.h"
#import "DeinflectorRuleMatch.h"

@implementation Deinflector
@synthesize reasons, rules, rulesArray;

//! Get the shared instance singleton of the deinflector
+(Deinflector *)sharedInstance
{
  static Deinflector *sharedInstanceSingleton;
  if (!sharedInstanceSingleton)
  {
    sharedInstanceSingleton = [[Deinflector alloc] init];
  }
  return sharedInstanceSingleton;
}

- (id) init
{
  self = [super init];
  if (self)
  {
    NSLog(@"Deinflector Shields Up");

    // Read in contents of data file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kRikaiKitDeinflectionDB ofType:kRikaiKitDeinflectionDBExt];
    NSString *rulesString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSMutableArray *lineArray = [[rulesString componentsSeparatedByString:@"\n"] mutableCopy];

    [self setReasons:[[NSMutableDictionary alloc] init]];
    [self setRules:[[NSMutableDictionary alloc] init]];
    [self setRulesArray:[[NSMutableArray alloc] init]];

    NSArray* tmpFields;
    NSMutableArray* tmpRulesGroupArray;
    NSInteger tmpBitMask;
    NSString* ruleGroupLengthKeyString;

    if(lineArray)
    {
      NSInteger counter = 0;
      NSInteger reasonID;
      for (NSString *line in lineArray)
      {
        counter++;
        if(counter == 1) continue; // skip header line
        
        // NB: Assumes reasons stored before rules
        if ([line rangeOfString:@"\t"].location == NSNotFound)
        {
          // No Tabs = reasons data
          reasonID = counter-2;
          [[self reasons] setObject:[DeinflectorReason reasonWithDescription:line reasonID:reasonID] forKey:[NSString stringWithFormat:@"%d",reasonID]];
          //NSLog(@"Added deinflector reason %@", line);
        }
        else {
          // Tabs = Rules data
          tmpFields = [line componentsSeparatedByString:@"\t"];
          tmpBitMask = [[tmpFields objectAtIndex:2] integerValue];
          DeinflectorReason* tmpReason = [reasons objectForKey:[tmpFields objectAtIndex:3]];

          // Raise exception if rason not found!
          if (!tmpReason) {
            [NSException raise:@"Deinflector Reason Not Found" format:@"Not found for ReasonID %@", [tmpFields objectAtIndex:3]];
          }
          DeinflectorRule* tmpRule = [DeinflectorRule ruleWithInflectedString:[tmpFields objectAtIndex:0] deinflectedString:[tmpFields objectAtIndex:1] typeBitMask:tmpBitMask reason:tmpReason];
          
          // Store rules by in dictionary grouped by length of inflected string
          ruleGroupLengthKeyString = [NSString stringWithFormat:@"%d", [[tmpFields objectAtIndex:0] length]];
          if( !(tmpRulesGroupArray = [rules objectForKey:ruleGroupLengthKeyString]) )
          {
            tmpRulesGroupArray = [[[NSMutableArray alloc] init] autorelease];
          }
          [tmpRulesGroupArray addObject:tmpRule];
          [rules setObject:tmpRulesGroupArray forKey:ruleGroupLengthKeyString];

          //NSLog(@"Added deinflector rule %@", [tmpFields objectAtIndex:0]);
        }
      }
    }
    [lineArray release];
  }
  return self;
}

- (NSArray*) deinflect:(NSString*) word
{
  NSMutableDictionary *ruleOffsetInResultsArray = [[NSMutableDictionary alloc] init];
  NSMutableArray *results  = [[[NSMutableArray alloc] init] autorelease];
  NSString *currentWord = [NSString stringWithString:word];
  NSString *currentWordEnding, *newWord;
  NSInteger currentTypeBitMask;
  NSInteger wordLen;
  NSInteger iCount, kCount;
  NSArray *ruleGroupArray;
  DeinflectorRule *currentRule;
  DeinflectorRuleMatch *ruleMatch;

  [ruleOffsetInResultsArray setValue:0 forKey:currentWord];  // Add default result for first word
  currentTypeBitMask = 255;  // Default value is 0xFF
  iCount = 0;

  // Add default ruleMatch
  ruleMatch = [DeinflectorRuleMatch ruleMatchWith:currentWord typeBitMask:currentTypeBitMask reasonString:@""];
  [results addObject:ruleMatch];

  do {

    currentWord = [[results objectAtIndex:iCount] word]; // set currentWord from results
    currentTypeBitMask = [[results objectAtIndex:iCount] typeBitMask];
    wordLen = [currentWord length];

    // NSLog(@"\n\n\n");
    // NSLog(@"- - - - - - - - - - - - - - - - - - - - - - - -");
    // NSLog(@"CURRENT WORD: %@", currentWord);
    // NSLog(@"LEN RESULTS ARRAY: %d", [results count]);
    // NSLog(@"LOOP RCOUNT: %d", iCount);
    // NSLog(@"- - - - - - - - - - - - - - - - - - - - - - - -");

    // Iterate through 'rules' in order from longest to shortest
    id ruleKey;

    // Get array of ascending order rule keys and iterate backwards!!
    NSArray *sortedRuleKeysArray = [[[self rules] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (ruleKey in [sortedRuleKeysArray reverseObjectEnumerator])
    {
      int ruleKeyAsInt = [ruleKey intValue];
      //NSLog(@"%d char rules, %d char word", [ruleKey intValue], wordLen);

      if ([ruleKey intValue] <= wordLen) 
      {
        // Get the end of the string
        currentWordEnding = [currentWord substringWithRange: NSMakeRange([currentWord length]-ruleKeyAsInt, ruleKeyAsInt)];
        ruleGroupArray = [[self rules] objectForKey:ruleKey];

        NSLog(@"currentWordEnding = %@", currentWordEnding);

        // Iterate through rules in 'ruleGroupArray'
        for(kCount=0; kCount < [ruleGroupArray count]; kCount++){
          currentRule = [ruleGroupArray objectAtIndex:kCount];

          if((currentTypeBitMask & [currentRule typeBitMask]) && [currentWordEnding isEqualToString:[currentRule inflectedString]]){

            // NSLog(@"currentWordEnding is %@", currentWordEnding);
            // NSLog(@"Matched [currentRule inflectedString] is %@", [currentRule inflectedString]);
            // NSLog(@"Matched bitwise mask: %08x", (currentTypeBitMask & [currentRule typeBitMask]));
            
            newWord = [currentWord substringWithRange: NSMakeRange(0, [currentWord length] - [[currentRule inflectedString] length])];
            newWord = [newWord stringByAppendingString:[currentRule deinflectedString]];

            NSLog(@"DEINFLECTED WORD IS: %@\n",newWord);
            if ([newWord length] <= 1) continue; // continue if too short
            ruleMatch = [DeinflectorRuleMatch ruleMatchWith:@"" typeBitMask:0 reasonString:@""]; // create empty ruleMatch hash

            // Skip to next if newWord found in 'ruleMatchBuffer'
            if([ruleOffsetInResultsArray objectForKey:newWord]){
              ruleMatch = [results objectAtIndex:[[ruleOffsetInResultsArray objectForKey:newWord] intValue]];
              int tmpBitMask = (tmpBitMask |= ([currentRule typeBitMask] >> 8));
              [ruleMatch setTypeBitMask:tmpBitMask];
              continue;
            }

            // Track result offset in result tracking array
            NSNumber *count = [[NSNumber alloc] initWithInt:[results count]];
            [ruleOffsetInResultsArray setValue:count forKey:newWord];
            [count release];

            if([[[results objectAtIndex:iCount] reasonString] length]) 
            {
              // ruleMatch's reason  is "parent < child"
              NSString* tmpReason = [NSString stringWithFormat:@"%@ &lt; %@", [currentRule reason], [[results objectAtIndex:iCount] reasonString]];
              [ruleMatch setReasonString:tmpReason];
            }
            else { 
              // ruleMatch's reason has no child
              [ruleMatch setReasonString: [[currentRule reason] description]];
            }
            NSLog(@"MATCH REASON: %@", [ruleMatch reasonString]);

            // Update ruleMatch and push onto array
            [ruleMatch setTypeBitMask:[currentRule typeBitMask] >> 8];
            [ruleMatch setWord:newWord];
            [results addObject:ruleMatch];
          }

        } // iterating rules
      } // if wordLen <= rule group's char len
    } // iterating groups of rules
  } while( ++iCount < [results count]);

  // memory cleanup
  [ruleOffsetInResultsArray release];
  return results;
}

-(void) dealloc
{
  [self setReasons:nil];
  [self setRulesArray:nil];
  [super dealloc];
} 

@end