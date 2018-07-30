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
#import "MapTitleView.h"

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

- (void)loadTitleView
{
    UINib *nib;
    MapTitleView *titleBox;
    
    nib = [UINib nibWithNibName:@"MapTitleView" bundle:[NSBundle mainBundle]];
    titleBox = [[nib instantiateWithOwner:self options:0] firstObject];
    titleBox.topLabel.text = self.topTitle;
    titleBox.bottomLabel.text = self.bottomTitle;
    self.navigationItem.titleView = titleBox;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadNavButtons];
    [self loadTitleView];
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
