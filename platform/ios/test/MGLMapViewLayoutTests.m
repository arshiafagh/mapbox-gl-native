#import <XCTest/XCTest.h>
#import "MGLMapView.h"
#import "MGLMapViewDelegate.h"
#import "MGLAccountManager.h"


@interface MGLMapViewLayoutTests : XCTestCase<MGLMapViewDelegate>

@property (nonatomic) UIView *superView;
@property (nonatomic) MGLMapView *mapView;
@property (nonatomic) XCTestExpectation *styleLoadingExpectation;

@end

@implementation MGLMapViewLayoutTests

- (void)setUp {
    [super setUp];

    [MGLAccountManager setAccessToken:@"pk.feedcafedeadbeefbadebede"];
    NSURL *styleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"one-liner" withExtension:@"json"];
    NSLog(@"================> Screen size: %@", NSStringFromCGRect(UIScreen.mainScreen.bounds));

    self.superView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];

    self.mapView = [[MGLMapView alloc] initWithFrame:UIScreen.mainScreen.bounds styleURL:styleURL];
    self.mapView.delegate = self;

    [self.superView addSubview:self.mapView];

    UIView *mapView = self.mapView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mapView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mapView]-0-|" options:0 metrics:nil views:bindings];
    NSArray *horizonatalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mapView]-0-|" options:0 metrics:nil views:bindings];

    [self.superView addConstraints:[verticalConstraints arrayByAddingObjectsFromArray:horizonatalConstraints]];

    self.styleLoadingExpectation = [self expectationWithDescription:@"Map view should finish loading style."];
    [self waitForExpectationsWithTimeout:1 handler:nil];

    //set zoom and heading so that scale bar and compass will be shown
    [self.mapView setZoomLevel:4.5 animated:NO];
    [self.mapView.camera setHeading:12.0];

    //invoke layout
    [self.superView setNeedsLayout];
    [self.superView layoutIfNeeded];
    NSLog(@"================> self.mapView.frame: %@", NSStringFromCGRect(self.mapView.frame));
    NSLog(@"================> self.mapView.safeAreaInsets: %@", NSStringFromUIEdgeInsets(self.mapView.safeAreaInsets));
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    XCTAssertNotNil(mapView.style);
    XCTAssertEqual(mapView.style, style);

    [self.styleLoadingExpectation fulfill];
}

- (void)tearDown {
    self.styleLoadingExpectation = nil;
    self.mapView = nil;

    [super tearDown];
}

// TODO: check constraining to superview vs. constraining to safeAreaLayoutGuide.bottomAnchor

- (void)testOrnamentPlacement {

    CGFloat margin = 8.0;
    double accuracy = 0.01;

    //compass
    UIImageView *compassView = self.mapView.compassView;
    NSLog(@"================> %@", compassView);

    CGFloat expectedCompassOriginX = CGRectGetMaxX(self.mapView.bounds) - margin - CGRectGetWidth(compassView.frame);
    CGFloat expectedCompassOriginY = margin;
    // what about width/height? maybe we don't care as much at the moment?

    XCTAssertEqualWithAccuracy(CGRectGetMinX(compassView.frame), expectedCompassOriginX, accuracy);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(compassView.frame), expectedCompassOriginY, accuracy);

    //scale bar
    UIView *scaleBar = self.mapView.scaleBar;
    NSLog(@"================> %@", scaleBar);

    XCTAssertEqualWithAccuracy(CGRectGetMinX(scaleBar.frame), margin, accuracy);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(scaleBar.frame), margin, accuracy);

    //attribution button
    UIButton *attributionButton = self.mapView.attributionButton;
    NSLog(@"================> %@", attributionButton);

    CGFloat expectedButtonOriginX = CGRectGetMaxX(self.mapView.bounds) - margin - CGRectGetWidth(attributionButton.frame);
    CGFloat expectedButtonOriginY = CGRectGetMaxY(self.mapView.bounds) - margin - CGRectGetHeight(attributionButton.frame);

    XCTAssertEqualWithAccuracy(CGRectGetMinX(attributionButton.frame), expectedButtonOriginX, accuracy);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(attributionButton.frame), expectedButtonOriginY, accuracy);

    //mapbox logo
    UIImageView *logoView = self.mapView.logoView;
    NSLog(@"================> %@", logoView);

    CGFloat expectedLogoOriginX = margin;
    CGFloat expectedLogoOriginY = CGRectGetMaxY(self.mapView.bounds) - margin - CGRectGetHeight(logoView.frame);

    XCTAssertEqualWithAccuracy(CGRectGetMinX(logoView.frame), expectedLogoOriginX, accuracy);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(logoView.frame), expectedLogoOriginY, accuracy);
}

@end
