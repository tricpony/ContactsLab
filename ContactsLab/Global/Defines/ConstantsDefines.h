//
//  ConstantsDefines.h
//

#import "AppDelegate.h"

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
