//
//  Liddell.h
//  Liddell
//
//  Created by Alexandra (@thatcluda)
//

#import <UIKit/UIKit.h>
#import "Liddell-Swift.h"
#import <Kitten/libKitten.h>
#import "GcUniversal/GcColorPickerUtils.h"
#import "dlfcn.h"
#import <Cephei/HBPreferences.h>

HBPreferences* preferences = nil;
BOOL enabled = YES;

// visibility
BOOL showIconSwitch = YES;
BOOL showTitleSwitch = YES;
BOOL showMessageSwitch = YES;

// style
CGFloat heightValue = 40;
CGFloat cornerRadiusValue = 8;
CGFloat offsetValue = 0;
CGFloat scrollRateValue = 50;

// background
NSUInteger backgroundColorValue = 0;
NSString* customBackgroundColorValue = @"000000";
NSUInteger blurModeValue = 3;
CGFloat blurAmountValue = 1;

// icon
CGFloat iconCornerRadiusValue = 0;

// text
NSUInteger textColorValue = 0;
NSString* customTextColorValue = @"FFFFFF";
NSUInteger textContentValue = 2;
NSUInteger titleFontSizeValue = 15;
NSUInteger contentFontSizeValue = 14;

// border
NSUInteger borderWidthValue = 0;
NSUInteger borderColorValue = 0;
NSString* customBorderColorValue = @"FFFFFF";

@interface MTPlatterView : UIView
@end

@interface MTTitledPlatterView : MTPlatterView
@end

@interface NCNotificationShortLookView : MTTitledPlatterView
@property(nonatomic, copy)NSArray* icons;
@property(nonatomic, copy)NSString* primaryText;
@property(nonatomic, copy)NSString* secondaryText;
@property(nonatomic, retain)UIView* liddellView;
@property(nonatomic, retain)UIBlurEffect* liddellBlur;
@property(nonatomic, retain)UIVisualEffectView* liddellBlurView;
@property(nonatomic, retain)UIImageView* liddellIconView;
@property(nonatomic, retain)UILabel* liddellTitleLabel;
@property(nonatomic, retain)MarqueeLabel* liddellContentLabel;
@end

@interface NCNotificationContent : NSObject
@property(nonatomic, copy, readonly)NSString* header;
@end

@interface NCNotificationRequest : NSObject
@property(nonatomic, readonly)NCNotificationContent* content;
@end

@interface NCNotificationShortLookViewController : UIViewController
@property(nonatomic, retain)NCNotificationRequest* notificationRequest;
@end

@interface UIView (Liddell)
- (id)_viewControllerForAncestor;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* bulletinID;
@property(nonatomic, copy)NSString* recordID;
@property(nonatomic, retain)NSDate* date;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBObserver : NSObject
@end
