//
//  HatnoteListenTests.m
//  HatnoteListenTests
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HATViewController.h"

@interface HatnoteListenTests : XCTestCase

@end

@implementation HatnoteListenTests

- (void)testChoosesSameSoundIndexAsWebsite
{
  // Numbers sampled from listen.hatnote.org. The website's random adjustment to the index has been
  // removed to make this deterministic.
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(21.213203435596423), 13);
  XCTAssertEqual(indexForChangeSize(5), 17);
  XCTAssertEqual(indexForChangeSize(23.45207879911715), 12);
  XCTAssertEqual(indexForChangeSize(3), 19);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(55.45268253204709), 9);
  XCTAssertEqual(indexForChangeSize(17.32050807568877), 13);
  XCTAssertEqual(indexForChangeSize(76.64854858377946), 8);
  XCTAssertEqual(indexForChangeSize(17.32050807568877), 13);
  XCTAssertEqual(indexForChangeSize(21.213203435596423), 13);
  XCTAssertEqual(indexForChangeSize(31.22498999199199), 11);
  XCTAssertEqual(indexForChangeSize(15), 14);
  XCTAssertEqual(indexForChangeSize(42.1307488658818), 10);
  XCTAssertEqual(indexForChangeSize(20.615528128088304), 13);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(131.7193987231949), 7);
  XCTAssertEqual(indexForChangeSize(86.16843969807043), 8);
  XCTAssertEqual(indexForChangeSize(20.615528128088304), 13);
  XCTAssertEqual(indexForChangeSize(100.62305898749054), 7);
  XCTAssertEqual(indexForChangeSize(49.749371855331), 10);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(5), 17);
  XCTAssertEqual(indexForChangeSize(96.56603957913984), 8);
  XCTAssertEqual(indexForChangeSize(64.22616289332565), 9);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(199.3113142799475), 5);
  XCTAssertEqual(indexForChangeSize(3), 19);
  XCTAssertEqual(indexForChangeSize(7.0710678118654755), 16);
  XCTAssertEqual(indexForChangeSize(72.62919523166974), 9);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(59.371710435189584), 9);
  XCTAssertEqual(indexForChangeSize(12.24744871391589), 15);
  XCTAssertEqual(indexForChangeSize(61.44102863722254), 9);
  XCTAssertEqual(indexForChangeSize(36.40054944640259), 11);
  XCTAssertEqual(indexForChangeSize(23.45207879911715), 12);
  XCTAssertEqual(indexForChangeSize(26.457513110645905), 12);
  XCTAssertEqual(indexForChangeSize(10), 15);
  XCTAssertEqual(indexForChangeSize(65.76473218982953), 9);
}

@end
