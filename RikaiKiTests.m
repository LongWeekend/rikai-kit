//
//  RikaiKitTests.h
//  RikaiKit
//
//  Created by Ross on 6/29/10.
//  Copyright 2010-2012 LONG WEEKEND INC. All rights reserved.
//
//  See license.txt for disclaimer
//

#import <SenTestingKit/SenTestingKit.h>
#import "Deinflector.h"
#import "ProgressiveSearch.h"

@interface RikaiKitTests : SenTestCase
@end

@implementation RikaiKitTests

- (void)testKatakanaToHiragana
{
  NSString* out;
  out = [[ProgressiveSearch katakanaToHiragana:@"カタカナ"] objectAtIndex:0];
  STAssertEqualStrings(out, @"かたかな", @"Oops, conversion to hiragana failed!");

  out = [[ProgressiveSearch katakanaToHiragana:@"ウォールストリートアソシエイツ"] objectAtIndex:0];
  STAssertEqualStrings(out, @"うぉーるすとりーとあそしえいつ", @"Oops, conversion to hiragana failed!");

  out = [[ProgressiveSearch katakanaToHiragana:@"隣の客はよく柿食う客だ。ダイスキ！"] objectAtIndex:0];
  STAssertEqualStrings(out, @"隣の客はよく柿食う客だ。だいすき！", @"Oops, conversion to hiragana failed!");

  out = [[ProgressiveSearch katakanaToHiragana:@"サボっている"] objectAtIndex:0];
  STAssertEqualStrings(out, @"さぼっている", @"Oops, conversion to hiragana failed!");
  LWE_LOG(@"%@", out);

}

- (void)testDeinflectionRules
{
  Deinflector *theHounds =  [[Deinflector alloc] init];

  // Ensure we have rules, currently we have 8 groups
  STAssertGreaterThan([[theHounds rules] count], (NSUInteger)5, @"Oops, there weren't enough rules objects!");
  
  // Ensure we have reasons, currently we have 27 groups
  STAssertGreaterThan([[theHounds reasons] count], (NSUInteger)25, @"Oops, there weren't enough reasons objects!");

  [theHounds release];
}

- (void)testDeinflector 
{
  Deinflector *theHounds =  [[Deinflector alloc] init];
  NSArray *results;
  NSString* msg = @"expected deinflected string did not match!";
  
  // Check deinflection types
  results = [theHounds go:@"かけた"];
  STAssertEqualStrings([[results objectAtIndex:0] word], @"かけた", @"1st %@");
  STAssertEqualStrings([[results objectAtIndex:1] word], @"かける", @"2nd %@", msg);
  STAssertEqualStrings([[results objectAtIndex:2] word], @"かく", @"3rd %@", msg);
  
  results = [theHounds go:@"食べました"];
  for (DeinflectorRuleMatch* match in results)
  STAssertEqualStrings([[results objectAtIndex:0] word], @"食べました", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"食べる", @"2nd %@", msg);
  STAssertEqualStrings([[results objectAtIndex:2] word], @"食べます", @"3rd %@", msg);

  results = [theHounds go:@"いただけます"];
  STAssertEqualStrings([[results objectAtIndex:0] word], @"いただけます", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"いただける", @"2nd %@", msg);
  STAssertEqualStrings([[results objectAtIndex:2] word], @"いただく", @"3rd %@", msg);

  results = [theHounds go:@"楽しかった"];
  for (DeinflectorRuleMatch* match in results)
  STAssertEqualStrings([[results objectAtIndex:0] word], @"楽しかった", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"楽しい", @"2nd %@", msg);

  results = [theHounds go:@"したい"];
  STAssertEqualStrings([[results objectAtIndex:0] word], @"したい", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"する", @"2nd %@", msg);

  results = [theHounds go:@"述べます"];
  STAssertEqualStrings([[results objectAtIndex:0] word], @"述べます", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"述べる", @"2nd %@", msg);

  results = [theHounds go:@"した"];
  for (DeinflectorRuleMatch* match in results)
  {
    LWE_LOG(@"%@", [match word]);
  }
  STAssertEqualStrings([[results objectAtIndex:0] word], @"した", @"1st %@", msg);
  STAssertEqualStrings([[results objectAtIndex:1] word], @"する", @"2nd %@", msg);
  
  [theHounds release];
}

- (void)testProgressiveSearch
{
  NSMutableArray* results;

  // Open the database
  LWEDatabase *db = [LWEDatabase sharedLWEDatabase];
  [db openDatabase:[LWEFile createBundlePathWithFilename:RIKAI_CURRENT_DATABASE]];
  LWE_LOG(@"Database Opened >>>>>>>>> !SMACK!");

  results = [[ProgressiveSearch progressiveSearchForKeyword: @"した" maxResults:7] objectAtIndex:0];
  for (DictEntry* match in results)
  {
    LWE_LOG(@"%@", [match mungedResultString]);
  }
  STAssertEqualStrings([[results objectAtIndex:0] mungedResultString], @"下 [した] (n,n-pref) below/down/under/bottom/beneath/underneath/just after/right after/inferiority/one's inferior (i.e. one's junior)/younger (e.g. of siblings)/trade-in/preliminary/(P)", @"1st result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:3] mungedResultString], @"為る [する] (vs-i,uk,vi,suf,aux-v) to do/to cause to become/to make (into)/to turn (into)/to serve as/to act as/to work as/to wear (clothes, a facial expression, etc.)/to judge as being/(P)", @"2nd result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:5] mungedResultString], @"仕 [し] (n) official/civil service", @"4th result incorrect!");
  
  results = [[ProgressiveSearch progressiveSearchForKeyword: @"さんと" maxResults:7] objectAtIndex:0];
  STAssertEqualStrings([[results objectAtIndex:0] mungedResultString], @"さんと サント /(n) saint/", @"1st result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:4] mungedResultString], @"酸 [さん] (n) acid/sourness/sour taste/(P)", @"5th result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:6] mungedResultString], @"讚 [さん] (n) a style of Chinese poetry/legend or inscription on a picture", @"7th result incorrect!");
  
  results = [[ProgressiveSearch progressiveSearchForKeyword: @"掛けた" maxResults:7] objectAtIndex:0];
  STAssertEqualStrings([[results objectAtIndex:0] mungedResultString], @"掛ける [かける] (v1,vt,aux-v) to hang (e.g. picture)/to hoist (e.g. sail)/to raise (e.g. flag)/to sit/to be partway (verb)/to begin (but not complete)/to take (time, money)/to expend (money, time, etc.)/(P)", @"1st result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:1] mungedResultString], @"掛け [かけ] (n,n-suf) credit/partially/half/(P)", @"1st result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:2] mungedResultString], @"掛け [がけ] (n-suf,adj-no) (after an article of clothing) clad/(after a masu stem) in the midst of/(after a number in the ichi, ni counting system) tenths/(after a number in the hitotsu, futatsu counting system) times (i.e. multiplied by)", @"1st result incorrect!");

  results = [[ProgressiveSearch progressiveSearchForKeyword: @"赤くなかった" maxResults:7] objectAtIndex:0];
  STAssertEqualStrings([[results objectAtIndex:0] mungedResultString], @"赤い [あかい] (adj-i) red/Red (i.e. communist)/(P)", @"1st result incorrect!");
  STAssertEqualStrings([[results objectAtIndex:1] mungedResultString], @"赤 [あか] (n,col,abbr,adj-no,n-pref) red/crimson/scarlet/red-containing colour (e.g. brown, pink, orange)/Red (i.e. communist)/red light/red ink (i.e. in finance or proof-reading)/(in) the red", @"2nd result incorrect!");

}

@end