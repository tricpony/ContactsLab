//
//  MapViewController.m
//  ClinicalTrials
//
//  Created by aarthur on 2/22/15.
//  Copyright (c) 2015 Gigabit LLC. All rights reserved.
//

#import <Contacts/Contacts.h>
#import "MapViewController.h"
#import "Constants.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+ContactsLab.h"
#import "GBAlerts.h"
#import "CNPostalAddress+ClinicalTrials.h"

int pinColorIndex = 0;

@interface AnnotationDelegate : NSObject <MKAnnotation>
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MKPlacemark *placemark;
@property(nonatomic, readonly, copy) NSString *title;
@property (nonatomic, assign) UIColor *pinColor;
@property (strong, nonatomic) NSString *researchCenterName;
@property (copy, nonatomic) NSString *formattedAddress;

@end

@implementation AnnotationDelegate

- (CLLocationCoordinate2D)coordinate
{
    return self.placemark.location.coordinate;
}

- (NSString*)title
{
    return self.researchCenterName;
}

- (NSString*)subtitle
{
    return self.formattedAddress;
}

@end
@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MKLocalSearch *extraSearch;

@end

@implementation MapViewController

- (void)loadNavButtons
{
    if (self.isModal) {
        UIBarButtonItem *rtNavButton = nil;
        UIBarButtonItem *ltNavButton = nil;
        
        rtNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                    target:self
                                                                    action:@selector(dismissModal:)];
        
        self.navigationItem.rightBarButtonItem = rtNavButton;
        self.navigationItem.leftBarButtonItem = ltNavButton;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadNavButtons];
    UIUserInterfaceSizeClass hSizeClass = [APP_DELEGATE window].traitCollection.horizontalSizeClass;
    
    if (hSizeClass == UIUserInterfaceSizeClassRegular) {
        self.view.layer.cornerRadius = 10;
        self.view.layer.masksToBounds = YES;
        self.view.superview.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.layer.cornerRadius = 10;
        self.navigationController.navigationBar.layer.masksToBounds = YES;
    }
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    [self.geoCoder geocodePostalAddress:self.addressInfo completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error && ([error code] != kCLErrorGeocodeCanceled)) {
            NSString *message = NSLocalizedString(@"Match not found", nil);
            
            [GBAlerts presentOkAlertWithTitle:NSLocalizedString(@"Alert", nil) andMessage:message handler:^(UIAlertAction *action) {
                [self dismissModal:nil];
            }];
            
        }else{
            
            for (CLPlacemark *placemark in placemarks) {
                AnnotationDelegate *annDelegate;
                MKCoordinateRegion region;
                MKCoordinateSpan span;
                //                MKLocalSearchRequest *request = nil;
                
                span.latitudeDelta = 0.08;
                span.longitudeDelta = 0.08;
                region.span = span;
                region.center = placemark.location.coordinate;
                
                annDelegate = [[AnnotationDelegate alloc] init];
                annDelegate.placemark = (id)placemark;
                annDelegate.pinColor = [MKPinAnnotationView redPinColor];
                annDelegate.researchCenterName = self.researchCenterName;
                annDelegate.formattedAddress = [CNPostalAddressFormatter stringFromPostalAddress:self.addressInfo style:CNPostalAddressFormatterStyleMailingAddress];
                
                [self.mapView addAnnotation:annDelegate];
                [self.mapView setRegion:region animated:YES];
                [self.mapView regionThatFits:region];
                
                //refine the search to look for a match on the research center name
                //                request = [[MKLocalSearchRequest alloc] init];
                //
                //                request.region = region;
                //                request.naturalLanguageQuery = self.researchCenterName;
                //                self.extraSearch = [[MKLocalSearch alloc] initWithRequest:request];
                //                [self.extraSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
                //                    NSString *singleQuote = @"'";
                //                    NSString *theWord = @"The";
                //
                //                    for (MKMapItem *mapItem in response.mapItems) {
                //                        NSString *name = mapItem.name;
                //                        BOOL shouldMovePin = NO;
                //
                //                        //omit single quotes if the research center name does not have any
                //                        if ([name containsString:singleQuote] && ![self.researchCenterName containsString:singleQuote]) {
                //                            name = [name stringByReplacingOccurrencesOfString:singleQuote withString:@""];
                //                        }
                //
                //                        //omit a leading 'The' if the research center name does not have one
                //                        if ([name startsWithString:theWord] && ![self.researchCenterName startsWithString:theWord]) {
                //                            name = [name removeFirstWord];
                //                        }
                //
                //                        if ([[name trim] caseInsensitiveCompare:[self.researchCenterName trim]] == NSOrderedSame) {
                //                            shouldMovePin = YES;
                //                        }else{
                //                            //if this is a US based facility the research center name has been spell checked in AbstractViewController
                //                            shouldMovePin = [self.researchCenterName containsString:name];
                //                        }
                //
                //                        if (shouldMovePin) {
                //                            MKCoordinateRegion nextRegion;
                //
                //                            nextRegion.center = mapItem.placemark.location.coordinate;
                //                            nextRegion.span = span;
                //
                //                            annDelegate.placemark = mapItem.placemark;
                //                            [self.mapView addAnnotation:annDelegate];
                //                            [self.mapView setRegion:nextRegion animated:YES];
                //                            [self.mapView regionThatFits:nextRegion];
                //                            break;
                //                        }
            }
        }
        
    }];
        
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.geoCoder.isGeocoding) {
        [self.geoCoder cancelGeocode];
    }
    if (self.extraSearch.isSearching) {
        [self.extraSearch cancel];
    }
}

- (void)dismissModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>) annotation
{
    NSString *mapViewID = NSStringFromClass([self class]);
    MKPinAnnotationView *annView = (id)[mv dequeueReusableAnnotationViewWithIdentifier:mapViewID];
    
    if (!annView) {

        annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mapViewID];
        annView.pinTintColor = ((AnnotationDelegate*)annotation).pinColor;
        annView.animatesDrop = YES;
        annView.calloutOffset = CGPointMake(-10.0, -7.0);
        annView.draggable = YES;
        annView.canShowCallout = YES;

    }
    
    return annView;
}

- (void)mapView:(MKMapView*)mv didAddAnnotationViews:(NSArray*)views
{
    [mv selectAnnotation:[[views lastObject] annotation] animated:YES];
}

@end
