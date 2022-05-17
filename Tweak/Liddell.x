//
//  Liddell.x
//  Liddell
//
//  Created by Alexandra (@thatcluda)
//

#import "Liddell.h"

BBServer* bbServer = nil;
dispatch_queue_t queue;

%group Liddell

%hook NCNotificationShortLookView

%property(nonatomic, retain)UIView* liddellView;
%property(nonatomic, retain)UIBlurEffect* liddellBlur;
%property(nonatomic, retain)UIVisualEffectView* liddellBlurView;
%property(nonatomic, retain)UIImageView* liddellIconView;
%property(nonatomic, retain)UILabel* liddellTitleLabel;
%property(nonatomic, retain)MarqueeLabel* liddellContentLabel;

- (void)didMoveToWindow {

    %orig;

    if (![[self _viewControllerForAncestor] respondsToSelector:@selector(delegate)]) return;
    if (![[[self _viewControllerForAncestor] delegate] isKindOfClass:%c(SBNotificationBannerDestination)]) return; // check if the notification is a banner

    // get the actual notification title, the title property of the hooked class is uppercase
    UIViewController* controller = nil;
    NCNotificationRequest* request = nil;
    if ([[[self nextResponder] nextResponder] nextResponder]) {
        controller = (UIViewController *)[[[self nextResponder] nextResponder] nextResponder];
        if ([controller isKindOfClass:%c(NCNotificationShortLookViewController)] && [((NCNotificationShortLookViewController *) controller) notificationRequest])
            request = [((NCNotificationShortLookViewController *) controller) notificationRequest];
    }

    if (!request || ![request content]) return;
    NCNotificationContent* content = [request content];

    // remove the original notification
    for (UIView* subview in [self subviews]) {
        if (subview == [self liddellView]) continue;
        [subview removeFromSuperview];
    }


    // liddell view
    if (![self liddellView]) {
        self.liddellView = [UIView new];
        [[self liddellView] setClipsToBounds:YES];
        [[[self liddellView] layer] setCornerRadius:cornerRadiusValue];
        if (backgroundColorValue == 1) [[self liddellView] setBackgroundColor:[[libKitten backgroundColor:[[self icons] objectAtIndex:0]] colorWithAlphaComponent:1]];
        else if (backgroundColorValue == 2) [[self liddellView] setBackgroundColor:[GcColorPickerUtils colorWithHex:customBackgroundColorValue]];
        if (borderWidthValue != 0) {
            [[[self liddellView] layer] setBorderWidth:borderWidthValue];
            if (borderColorValue == 0) [[[self liddellView] layer] setBorderColor:[[[libKitten primaryColor:[[self icons] objectAtIndex:0]] colorWithAlphaComponent:1] CGColor]];
            else if (borderColorValue == 1) [[[self liddellView] layer] setBorderColor:[[GcColorPickerUtils colorWithHex:customBorderColorValue] CGColor]];
        }
        [self addSubview:[self liddellView]];

        [[self liddellView] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [self.liddellView.topAnchor constraintEqualToAnchor:self.topAnchor constant:offsetValue],
            [self.liddellView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.liddellView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.liddellView.heightAnchor constraintEqualToConstant:heightValue]
        ]];
    }


    // blur
    if (blurModeValue != 0 && ![self liddellBlurView]) {
		if (blurModeValue == 1) self.liddellBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        if (blurModeValue == 2) self.liddellBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        else if (blurModeValue == 3) self.liddellBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
		self.liddellBlurView = [[UIVisualEffectView alloc] initWithEffect:[self liddellBlur]];
        [[self liddellBlurView] setAlpha:blurAmountValue];
		[[self liddellView] addSubview:[self liddellBlurView]];

        [[self liddellBlurView] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [self.liddellBlurView.topAnchor constraintEqualToAnchor:self.liddellView.topAnchor],
            [self.liddellBlurView.leadingAnchor constraintEqualToAnchor:self.liddellView.leadingAnchor],
            [self.liddellBlurView.trailingAnchor constraintEqualToAnchor:self.liddellView.trailingAnchor],
            [self.liddellBlurView.bottomAnchor constraintEqualToAnchor:self.liddellView.bottomAnchor]
        ]];
    }
    

    // icon
    if (showIconSwitch && ![self liddellIconView]) {
        self.liddellIconView = [UIImageView new];
        [[self liddellIconView] setImage:[[self icons] objectAtIndex:0]];
        [[self liddellIconView] setContentMode:UIViewContentModeScaleAspectFit];
        [[self liddellIconView] setClipsToBounds:YES];
        [[[self liddellIconView] layer] setCornerRadius:iconCornerRadiusValue];
        [[self liddellView] addSubview:[self liddellIconView]];

        [[self liddellIconView] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [self.liddellIconView.leadingAnchor constraintEqualToAnchor:self.liddellView.leadingAnchor constant:8],
            [self.liddellIconView.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor],
            [self.liddellIconView.heightAnchor constraintEqualToConstant:heightValue - 13],
            [self.liddellIconView.widthAnchor constraintEqualToConstant:heightValue - 13]
        ]];
    }


    // app name
    if (showTitleSwitch && ![self liddellTitleLabel]) {
        self.liddellTitleLabel = [UILabel new];
        [[self liddellTitleLabel] setText:[content header]];
        [[self liddellTitleLabel] setFont:[UIFont boldSystemFontOfSize:titleFontSizeValue]];
        if (textContentValue == 0 || textContentValue == 2) {
            if (textColorValue == 0) {
                if (backgroundColorValue == 0) {
                    if (![[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]]) {
                        if ([[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]) {
                            [[self liddellTitleLabel] setTextColor:[UIColor whiteColor]];
                        } else if ([[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]) {
                            [[self liddellTitleLabel] setTextColor:[UIColor blackColor]];
                        }
                    } else {
                        [[self liddellTitleLabel] setTextColor:[UIColor labelColor]];
                    }
                } else {
                    if ([libKitten isDarkColor:[[self liddellView] backgroundColor]]) {
                        [[self liddellTitleLabel] setTextColor:[UIColor whiteColor]];
                    } else if (![libKitten isDarkColor:[[self liddellView] backgroundColor]]) {
                        [[self liddellTitleLabel] setTextColor:[UIColor blackColor]];
                    }
                }
            } else if (textColorValue == 1) {
                [[self liddellTitleLabel] setTextColor:[libKitten secondaryColor:[[self icons] objectAtIndex:0]]];
            } else if (textColorValue == 2) {
                [[self liddellTitleLabel] setTextColor:[GcColorPickerUtils colorWithHex:customTextColorValue]];
            }
        }
        [[self liddellView] addSubview:[self liddellTitleLabel]];

        [[self liddellTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
        if (showIconSwitch && [self liddellIconView]) {
            [NSLayoutConstraint activateConstraints:@[
                [self.liddellTitleLabel.leadingAnchor constraintEqualToAnchor:self.liddellIconView.trailingAnchor constant:8],
                [self.liddellTitleLabel.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor]
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [self.liddellTitleLabel.leadingAnchor constraintEqualToAnchor:self.liddellView.leadingAnchor constant:8],
                [self.liddellTitleLabel.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor]
            ]];
        }
    }

    [[self liddellTitleLabel] layoutIfNeeded]; // this fixes a bug which causes the app name to disappear on long notification messages


    // notification title and message
    if (showMessageSwitch && ![self liddellContentLabel]) {
        self.liddellContentLabel = [MarqueeLabel new];
        if ([self primaryText] && [self secondaryText]) [[self liddellContentLabel] setText:[NSString stringWithFormat:@"%@: %@", [self primaryText], [self secondaryText]]];
        else [[self liddellContentLabel] setText:[[self secondaryText] stringByReplacingOccurrencesOfString:@"\n" withString:@": "]];
        [[self liddellContentLabel] setFont:[UIFont systemFontOfSize:contentFontSizeValue]];
        if (textContentValue == 1 || textContentValue == 2) {
            if (textColorValue == 0) {
                if (backgroundColorValue == 0) {
                    if (![[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]]) {
                        if ([[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]) {
                            [[self liddellContentLabel] setTextColor:[UIColor whiteColor]];
                        } else if ([[[self liddellBlurView] effect] isEqual:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]) {
                            [[self liddellContentLabel] setTextColor:[UIColor blackColor]];
                        }
                    } else {
                        [[self liddellContentLabel] setTextColor:[UIColor labelColor]];
                    }
                } else {
                    if ([libKitten isDarkColor:[[self liddellView] backgroundColor]]) {
                        [[self liddellContentLabel] setTextColor:[UIColor whiteColor]];
                    } else if (![libKitten isDarkColor:[[self liddellView] backgroundColor]]) {
                        [[self liddellContentLabel] setTextColor:[UIColor blackColor]];
                    }
                }
            } else if (textColorValue == 1) {
                [[self liddellContentLabel] setTextColor:[libKitten secondaryColor:[[self icons] objectAtIndex:0]]];
            } else if (textColorValue == 2) {
                [[self liddellContentLabel] setTextColor:[GcColorPickerUtils colorWithHex:customTextColorValue]];
            }
        }
        [[self liddellContentLabel] setScrollRate:scrollRateValue];
        [[self liddellContentLabel] setFadeLength:5];
        [[self liddellView] addSubview:[self liddellContentLabel]];

        [[self liddellContentLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
        if ((showIconSwitch && showTitleSwitch) || (!showIconSwitch && showTitleSwitch)) {
            [NSLayoutConstraint activateConstraints:@[
                [self.liddellContentLabel.leadingAnchor constraintEqualToAnchor:self.liddellTitleLabel.trailingAnchor constant:8],
                [self.liddellContentLabel.trailingAnchor constraintEqualToAnchor:self.liddellView.trailingAnchor constant:-12],
                [self.liddellContentLabel.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor]
            ]];
        } else if (showIconSwitch && !showTitleSwitch) {
            [NSLayoutConstraint activateConstraints:@[
                [self.liddellContentLabel.leadingAnchor constraintEqualToAnchor:self.liddellIconView.trailingAnchor constant:8],
                [self.liddellContentLabel.trailingAnchor constraintEqualToAnchor:self.liddellView.trailingAnchor constant:-12],
                [self.liddellContentLabel.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor]
            ]];
        } else if (!(showIconSwitch && [self liddellIconView]) && !(showTitleSwitch && [self liddellTitleLabel])) {
            [NSLayoutConstraint activateConstraints:@[
                [self.liddellContentLabel.leadingAnchor constraintEqualToAnchor:self.liddellView.leadingAnchor constant:8],
                [self.liddellContentLabel.trailingAnchor constraintEqualToAnchor:self.liddellView.trailingAnchor constant:-12],
                [self.liddellContentLabel.centerYAnchor constraintEqualToAnchor:self.liddellView.centerYAnchor]
            ]];
        }
    }

}

- (void)_setGrabberVisible:(BOOL)arg1 {

    %orig(NO);

}

%end

%end

%group TestNotifications

void testBanner() {
    
	BBBulletin* bulletin = [%c(BBBulletin) new];
    NSProcessInfo* processInfo = [NSProcessInfo processInfo];

	[bulletin setTitle:@"Alice"];
    [bulletin setMessage:@"Another day, a different dream perhaps?"];
    [bulletin setSectionID:@"com.apple.MobileSMS"];
    [bulletin setBulletinID:[processInfo globallyUniqueString]];
    [bulletin setRecordID:[processInfo globallyUniqueString]];
    [bulletin setDate:[NSDate date]];

    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(queue, ^{
            [bbServer publishBulletin:bulletin destinations:15];
        });
    }

}

%hook BBServer

- (id)initWithQueue:(id)arg1 {

    bbServer = %orig;
    queue = [self valueForKey:@"_queue"];

    return bbServer;

}

%end

%end

%ctor {
    
    preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.liddellpreferences"];

	[preferences registerBool:&enabled default:YES forKey:@"enabled"];
	if (!enabled) return;

    // visibility
    [preferences registerBool:&showIconSwitch default:YES forKey:@"showIcon"];
    [preferences registerBool:&showTitleSwitch default:YES forKey:@"showTitle"];
    [preferences registerBool:&showMessageSwitch default:YES forKey:@"showMessage"];

    // style
    [preferences registerFloat:&heightValue default:40 forKey:@"height"];
    [preferences registerFloat:&cornerRadiusValue default:8 forKey:@"cornerRadius"];
    [preferences registerFloat:&offsetValue default:0 forKey:@"offset"];
    [preferences registerFloat:&scrollRateValue default:50 forKey:@"scrollRate"];

    // background
    [preferences registerUnsignedInteger:&backgroundColorValue default:0 forKey:@"backgroundColor"];
    if (backgroundColorValue == 2) [preferences registerObject:&customBackgroundColorValue default:@"000000" forKey:@"customBackgroundColor"];
    [preferences registerUnsignedInteger:&blurModeValue default:3 forKey:@"blurMode"];
    if (blurModeValue != 0) [preferences registerFloat:&blurAmountValue default:1 forKey:@"blurAmount"];

    // icon
    [preferences registerFloat:&iconCornerRadiusValue default:0 forKey:@"iconCornerRadius"];
    
    // text
    [preferences registerUnsignedInteger:&textColorValue default:0 forKey:@"textColor"];
    if (textColorValue != 0) [preferences registerObject:&customTextColorValue default:@"FFFFFF" forKey:@"customTextColor"];
    [preferences registerUnsignedInteger:&textContentValue default:2 forKey:@"textContent"];
    [preferences registerUnsignedInteger:&titleFontSizeValue default:15 forKey:@"titleFontSize"];
    [preferences registerUnsignedInteger:&contentFontSizeValue default:14 forKey:@"contentFontSize"];

    // border
    [preferences registerUnsignedInteger:&borderWidthValue default:0 forKey:@"borderWidth"];
    if (borderWidthValue != 0) {
        [preferences registerUnsignedInteger:&borderColorValue default:0 forKey:@"borderColor"];
        if (borderColorValue != 0) [preferences registerObject:&customBorderColorValue default:@"FFFFFF" forKey:@"customBorderColor"];
    }
    
    %init(Liddell);
    %init(TestNotifications);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)testBanner, (CFStringRef)@"love.litten.liddell/TestBanner", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

}
