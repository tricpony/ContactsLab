//
//  ConstantsDefines.h
//

#import "AppDelegate.h"

#define GENERIC_LOCALIZED_ALERT_TITLE NSLocalizedString(@"Alert",@"generic localized alert title")

//replace NSLog with this to disable logging in production release
#ifdef DEBUG
#define DLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#endif

#define APP_DELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define TOOL_BAR_HEIGHT 40.0

typedef NS_OPTIONS(NSInteger, GroupedByType) {
    GroupedBy_CorpOwner,
    GroupedBy_Brand,
    GroupedBy_Manager,
    GroupedBy_Person_Company,
    GroupedBy_Person,
    GroupedBy_Address,
    GroupedBy_Phone
};
