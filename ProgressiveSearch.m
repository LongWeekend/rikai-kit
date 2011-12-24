//
//  ProgressiveSearch.m
//  Rikai
//
//  Created by paul on 1/7/10.
//  Copyright 2010 LONG WEEKEND INC. All rights reserved.
//

#import "ProgressiveSearch.h"

@implementation ProgressiveSearch
@synthesize delegate;

/* 
 * Progressively search for keyword in DB, removing one character at a time and continuing 
 */
- (NSArray*) progressiveSearchForKeyword:(NSString*)keyword maxResults:(NSInteger)max
{
  NSString *word = [NSString stringWithString:keyword]; // word

  NSMutableDictionary *resultsAlreadyFound = [[NSMutableDictionary alloc] init]; // have
  NSMutableArray *resultData = [[[NSMutableArray alloc] init] autorelease]; // result.data

  NSArray *resultsArray;
  NSString *splittableResultString;
  NSString *reason;
  NSArray *glossesArray;
  NSString *glossSubString;
  NSArray *variants;

  NSInteger count = 0;
  NSInteger maxLen = 0;
  NSInteger maxResults = max;
  NSInteger iCount, jCount, zCount;

  BOOL showInf = FALSE;
  BOOL keepGoing = TRUE;
  BOOL resultMore = FALSE;
  DeinflectorRuleMatch *variant;
  id currentResultString;

  // Convert katakana to hiragana
  NSArray* conversionResult = [ProgressiveSearch katakanaToHiragana:word];
  word = [conversionResult objectAtIndex:0];
  NSMutableDictionary *trueLen = [conversionResult objectAtIndex:1];

  while ([word length] > 0) 
  {
    showInf = (count != 0);
    
    // Run deinflector for array of DeinflectorRuleMatch objects
    variants = [[Deinflector sharedInstance] deinflect:word];
    
    for (iCount = 0; iCount < [variants count]; iCount++) 
    {
      variant = [variants objectAtIndex:iCount];
      // NSLog(@"Deinflected variant: %@",[variant word]);

      // Get Search ressults for keyword form delegate object
      if([(NSObject*)[self delegate] conformsToProtocol:@protocol(ProgressiveSearchDelegate)])
      {
        resultsArray = [self.delegate progressiveSearchForKeyword:[variant word]];
      }
      else
      {
        // Obey maaa authoriteeey!
        [NSException raise:NSInternalInconsistencyException format:@"The search delegate object must conform to <ProgressiveSearchDelegate> protocol"];
      }
      
      // SKIP if already found in 'have'
      for (jCount = 0; jCount < [resultsArray count]; ++jCount) 
      {
        currentResultString = [resultsArray objectAtIndex:jCount];
        NSAssert([(NSObject*)currentResultString isMemberOfClass:[NSString class]], @"Search results provided by delegate should all be NSString objects!");

        if ([resultsAlreadyFound objectForKey:currentResultString]) 
        {
          continue; // SKIP if already have this variant
        }

        // i > 0 means word is de-inflected
        keepGoing = TRUE;
        if(iCount > 0)
        {
          // Split on
          splittableResultString = [currentResultString stringByReplacingOccurrencesOfString:@"(" withString:@","];
          splittableResultString = [splittableResultString stringByReplacingOccurrencesOfString:@")" withString:@","];
          glossesArray = [splittableResultString componentsSeparatedByString:@","];

          NSInteger y = [variant typeBitMask];
          for (zCount = [glossesArray count] - 1; zCount >= 0; --zCount) 
          {
            glossSubString = [[glossesArray objectAtIndex:zCount] stringByReplacingOccurrencesOfString:@"," withString:@""];
            if([glossSubString length] > 0)
            {
              if ((y & 1) && [glossSubString isEqualToString:@"v1"]) break;
              if ((y & 4) && [glossSubString isEqualToString:@"adj-i"]) break;
              if ((y & 2) && ([glossSubString length] > 1) && [[glossSubString substringWithRange: NSMakeRange(0, 2)] isEqualToString:@"v5"]) break;
              if ((y & 16) && ([glossSubString length] > 2) && [[glossSubString substringWithRange: NSMakeRange(0, 3)] isEqualToString:@"vs-"]) break;
              if ((y & 8) && [glossSubString isEqualToString:@"vk"]) break;
            }
          }
          keepGoing = (zCount != -1);
          
        }// if iCount > 0
        // Push onto result aray if OK (i.e. matched acceptable type)
        
        if (keepGoing) 
        {
          if (count >= maxResults) 
          {
            resultMore = TRUE;
            break;
          }

          // Add to results already found
          [resultsAlreadyFound setObject:[NSNumber numberWithInt:1] forKey:currentResultString];

          // Increment loop counter
          ++count;

          if (maxLen == 0) {
            NSString* key = [NSString stringWithFormat:@"%d", [word length]];
            maxLen = [[trueLen valueForKey:key] intValue];
          }
          //maxLen = [word length];
          
          if ([[variant reasonString] length] > 0) {
            if (showInf){
              reason = [NSString stringWithFormat:@"&lt; %@ &lt; %@", [variant reasonString], currentResultString];
            }
            else{
              reason = [NSString stringWithFormat:@"&lt; %@", [variant reasonString]];
            }
          }
          
          [resultData addObject:currentResultString];
        } // if keepGoing?

      } // for jCount < [results count]
      if (count >= maxResults) 
        break;

    } // for iCount < [variants count]
    if (count >= maxResults) 
      break;
    word = [word substringWithRange: NSMakeRange(0, [word length]- 1)];

  }  // while [word length] > 0

  [resultsAlreadyFound release];

  // Returns (NSMutableArray)resultData and (int)maxLen
  if ([resultData count] == 0) 
    return [NSArray arrayWithObjects:resultData, [NSNumber numberWithInt:0], nil];
  else 
    return [NSArray arrayWithObjects:resultData, [NSNumber numberWithInt:maxLen], nil];
}

/* 
 * Half & Full-Width Katakana to Hiragana Conversion
 * NB: katakana "vu" is never converted to hiragana
 */
+ (NSArray*) katakanaToHiragana:(NSString*)inputWord
{
  // Katakana -> Hiragana conversion tables
  static const unsigned short halfwidthKatakana[56] = 
  { 
    0x3092,0x3041,0x3043,0x3045,0x3047,0x3049,0x3083,0x3085,0x3087,0x3063,0x30FC,0x3042,0x3044,0x3046,
    0x3048,0x304A,0x304B,0x304D,0x304F,0x3051,0x3053,0x3055,0x3057,0x3059,0x305B,0x305D,0x305F,0x3061,
    0x3064,0x3066,0x3068,0x306A,0x306B,0x306C,0x306D,0x306E,0x306F,0x3072,0x3075,0x3078,0x307B,0x307E,
    0x307F,0x3080,0x3081,0x3082,0x3084,0x3086,0x3088,0x3089,0x308A,0x308B,0x308C,0x308D,0x308F,0x3093
  };
  static const unsigned short voicedKatakana[28] = 
  {  
    0x30F4,0xFF74,0xFF75,0x304C,0x304E,0x3050,0x3052,0x3054,0x3056,0x3058,0x305A,0x305C,0x305E,0x3060,
    0x3062,0x3065,0x3067,0x3069,0xFF85,0xFF86,0xFF87,0xFF88,0xFF89,0x3070,0x3073,0x3076,0x3079,0x307C 
  };
  static const unsigned short semiVoicedKatakana[5] = { 0x3071,0x3074,0x3077,0x307A,0x307D };
  unichar currentCharArray[1];

  NSString* outputString = [[[NSString alloc] init] autorelease];
  NSMutableDictionary *trueLen = [[[NSMutableDictionary alloc] init] autorelease]; // trueLen
  [trueLen setObject:@"" forKey:[NSNumber numberWithInt:0]];

  NSInteger iCount;
  unichar previousChar = 0x0000;
  unichar currentChar;
  unichar originalChar;

  for (iCount = 0; iCount < [inputWord length]; ++iCount)
  {
    currentChar = [inputWord characterAtIndex:iCount];
    originalChar = currentChar;
    if (currentChar <= 0x3000) break;

    // full-width katakana to hiragana
    if ((currentChar >= 0x30A1) && (currentChar <= 0x30F3)) 
    {
      currentChar -= 0x60;
    }
    // half-width katakana to hiragana
    else if ((currentChar >= 0xFF66) && (currentChar <= 0xFF9D)) 
    {
      currentChar = halfwidthKatakana[currentChar - 0xFF66];
    }
    // voiced (used in half-width katakana) to hiragana
    else if (currentChar == 0xFF9E) 
    {
      if ((previousChar >= 0xFF73) && (previousChar <= 0xFF8E)) {
        outputString = [outputString substringWithRange: NSMakeRange(0, [outputString length]-1)];
        currentChar = voicedKatakana[previousChar - 0xFF73];
      }
    }
    // semi-voiced (used in half-width katakana) to hiragana
    else if (currentChar == 0xFF9F) 
    {
      if ((previousChar >= 0xFF8A) && (previousChar <= 0xFF8E)) {
        outputString = [outputString substringWithRange: NSMakeRange(0, [outputString length]-1)];
        currentChar = semiVoicedKatakana[previousChar - 0xFF8A];
      }
    }
    // ignore J~
    else if (currentChar == 0xFF5E) 
    {
      previousChar = 0;
      continue;
    }

    // put current char into C string array
    currentCharArray[0] = currentChar;
    currentCharArray[1] = 0x0000;

    outputString = [outputString stringByAppendingString:[NSString stringWithCharacters:currentCharArray length:1]];

    // need to keep real length because of the half-width semi/voiced conversion
    [trueLen setObject:[NSNumber numberWithInt:(iCount + 1)] forKey:[NSString stringWithFormat:@"%d", [outputString length]]];
    previousChar = originalChar;
  }
  return [NSArray arrayWithObjects:outputString, trueLen, nil];
}

-(void) dealloc
{
  self.delegate = nil;
  [super dealloc];
}
@end