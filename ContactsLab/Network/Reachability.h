/*!
    @header Reachability
    @abstract   Declares the Reachability and ReachabilityQuery classes
*/
/*


File: Reachability.h
Abstract: SystemConfiguration framework wrapper.

Version: 1.2


Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class Reachability;

/*!
    @class       Reachability 
	@superclass  NSObject
    @abstract    SystemConfiguration framework wrapper
    @discussion  The class can determine remote host reachability by name 
				 or address, cellular connectivity, and WiFi status.
*/
@interface Reachability : NSObject {
    
@private
	BOOL _networkStatusNotificationsEnabled;
	
	NSString *_hostName;
	NSString *_address;
    
	NSMutableDictionary *_reachabilityQueries;
}

/*
 An enumeration that defines the return values of the network state
 of the device.
 */
typedef enum {
	NotReachable = 0,
	ReachableViaCellularDataNetwork,
	ReachableViaWiFiNetwork
} NetworkStatus;


// Set to YES to register for changes in network status. Otherwise reachability queries
// will be handled synchronously.
@property BOOL networkStatusNotificationsEnabled;
// The remote host whose reachability will be queried.
// Either this or 'addressName' must be set.
@property (nonatomic, strong) NSString *hostName;
// The IP address of the remote host whose reachability will be queried.
// Either this or 'hostName' must be set.
@property (nonatomic, strong) NSString *address;
// A cache of ReachabilityQuery objects, which encapsulate SCNetworkReachabilityRef, a host or address, and a run loop. The keys are host names or addresses.
@property (nonatomic, strong) NSMutableDictionary *reachabilityQueries;

// This class is meant be used as a singleton.
+ (Reachability *)sharedReachability;

/*!
    @method     remoteHostStatus
    @abstract   Determines connectivity to a remote host
    @discussion Is self.hostName is not nil, determines its reachability. If self.hostName 
				is nil and self.address is not nil, determines the reachability of self.address.
    @result     Returns either NotReachable, ReachableViaCellularDataNetwork, or ReachableViaWiFiNetwork
*/
- (NetworkStatus)remoteHostStatus;

// 
/*!
    @method     internetConnectionStatus
    @abstract   Determines connectivity to the internet
    @discussion Is the device able to communicate with Internet hosts? If so, through which network interface?
    @result     Returns either NotReachable, ReachableViaCellularDataNetwork, or ReachableViaWiFiNetwork
 */
- (NetworkStatus)internetConnectionStatus;
// Is the device able to communicate with hosts on the local WiFi network? (Typically these are Bonjour hosts).
- (NetworkStatus)localWiFiConnectionStatus;

/*
    When reachability change notifications are posted, the callback method 'ReachabilityCallback' is called
    and posts a notification that the client application can observe to learn about changes.
*/
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

@end

/*!
    @class       ReachabilityQuery 
	@superclass  NSObject
    @abstract    Helper object used to insert a query into the run loop
*/
@interface ReachabilityQuery : NSObject
{
@private
	SCNetworkReachabilityRef _reachabilityRef;
	CFMutableArrayRef _runLoops;
	NSString *_hostNameOrAddress;
}
// Keep around each network reachability query object so that we can
// register for updates.
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong) NSString *hostNameOrAddress;
@property (nonatomic) CFMutableArrayRef runLoops;

- (void)scheduleOnRunLoop:(NSRunLoop *)inRunLoop;

@end

