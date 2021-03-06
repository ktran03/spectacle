#import "SpectacleWindowPositionCalculator.h"
#import "SpectacleHistoryItem.h"
#import "SpectacleConstants.h"

#define AgainstTheLeftEdgeOfScreen(a, b) (a.origin.x <= b.origin.x)
#define AgainstTheRightEdgeOfScreen(a, b) (CGRectGetMaxX(a) >= CGRectGetMaxX(b))
#define AgainstTheTopEdgeOfScreen(a, b) (CGRectGetMaxY(a) >= CGRectGetMaxY(b))
#define AgainstTheBottomEdgeOfScreen(a, b) (a.origin.y <= b.origin.y)

#pragma mark -

#define AlreadyTwoThirdsWidthOfDisplay(a, b) (abs(a.size.width - floor((b.size.width * 2.0f) / 3.0f)) < SpectacleWindowCalculationFudgeFactor)
#define AlreadyOneHalfWidthOfDisplay(a, b) (abs(a.size.width - (b.size.width / 2.0f)) < SpectacleWindowCalculationFudgeFactor)


#define AlreadyOneHalfHeightOfDisplay(a, b) (abs(a.size.height - (b.size.height / 2.0f)) < SpectacleWindowCalculationFudgeFactor)
#define AlreadyTwoThirdsHeightOfDisplay(a, b) (abs(a.size.height - floor((b.size.height * 2.0f) / 3.0f)) < SpectacleWindowCalculationFudgeFactor)


#pragma mark -

@implementation SpectacleWindowPositionCalculator

+ (CGRect)calculateWindowRect: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen action: (SpectacleWindowAction)action {
    
    
    CGRect calculatedWindowRect = windowRect;
    
    
    
    //Origin
    if ((action >= SpectacleWindowActionRightHalf) && (action <= SpectacleWindowActionLowerRight)) {
        calculatedWindowRect.origin.x = visibleFrameOfScreen.origin.x + floor(visibleFrameOfScreen.size.width / 2.0f);
    } else if (MovingToCenterRegionOfDisplay(action)) {
        calculatedWindowRect.origin.x = floor(visibleFrameOfScreen.size.width / 2.0f) - floor(calculatedWindowRect.size.width / 2.0f) + visibleFrameOfScreen.origin.x;
    } else if (!MovingToThirdOfDisplay(action)) {
        calculatedWindowRect.origin.x = visibleFrameOfScreen.origin.x;
    }
    
    if (MovingToTopRegionOfDisplay(action)) {
        calculatedWindowRect.origin.y = visibleFrameOfScreen.origin.y + floor(visibleFrameOfScreen.size.height / 2.0f);
    } else if (MovingToCenterRegionOfDisplay(action)) {
        calculatedWindowRect.origin.y = floor(visibleFrameOfScreen.size.height / 2.0f) - floor(calculatedWindowRect.size.height / 2.0f) + visibleFrameOfScreen.origin.y;
    } else if (!MovingToThirdOfDisplay(action)) {
        calculatedWindowRect.origin.y = visibleFrameOfScreen.origin.y;
    }
    
    
    
    //Size
    if ((action == SpectacleWindowActionLeftHalf) || (action == SpectacleWindowActionRightHalf)) {
        if ([SpectacleWindowPositionCalculator halfToTwoThirds: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]) {
            calculatedWindowRect.size.width = floor((visibleFrameOfScreen.size.width * 2.0f) / 3.0f);
        } else if ([SpectacleWindowPositionCalculator twoThirdsToOneThird: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]) {
            calculatedWindowRect.size.width = floor(visibleFrameOfScreen.size.width / 3.0f);
        } else {
            calculatedWindowRect.size.width = floor(visibleFrameOfScreen.size.width / 2.0f);
        }
        
        if (action == SpectacleWindowActionRightHalf) {
            calculatedWindowRect.origin.x = visibleFrameOfScreen.origin.x + visibleFrameOfScreen.size.width - calculatedWindowRect.size.width;
        }
        
        calculatedWindowRect.size.height = visibleFrameOfScreen.size.height;
        
        
    } else if ((action == SpectacleWindowActionTopHalf) || (action == SpectacleWindowActionBottomHalf)) {
        if ([SpectacleWindowPositionCalculator halfToTwoThird: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]) {
            calculatedWindowRect.size.height = floor((visibleFrameOfScreen.size.height * 2.0f) / 3.0f);
        } else if ([SpectacleWindowPositionCalculator twoThirdToOneThird: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]) {
            calculatedWindowRect.size.height = floor(visibleFrameOfScreen.size.height / 3.0f);
        } else {
            calculatedWindowRect.size.height = floor(visibleFrameOfScreen.size.height / 2.0f);
        }

        calculatedWindowRect.size.width = visibleFrameOfScreen.size.width;
    
    } else if (MovingToUpperOrLowerLeftOfDisplay(action) || MovingToUpperOrLowerRightDisplay(action)) {
        
        if ([SpectacleWindowPositionCalculator quarters_HalfToTwoThird: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]) {
            calculatedWindowRect.size.width = floor((visibleFrameOfScreen.size.width * 2.0f) / 3.0f);
        } else if ([SpectacleWindowPositionCalculator quarters_TwoThirdToOneThird: windowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action]){
            calculatedWindowRect.size.width = floor(visibleFrameOfScreen.size.width / 3.0f);
        } else {
            calculatedWindowRect.size.width = floor(visibleFrameOfScreen.size.width / 2.0f);
        }
        
        calculatedWindowRect.size.height = floor(visibleFrameOfScreen.size.height / 2.0f);

    } else if (!MovingToCenterRegionOfDisplay(action) && !MovingToThirdOfDisplay(action)) {
        calculatedWindowRect.size.width = visibleFrameOfScreen.size.width;
        calculatedWindowRect.size.height = visibleFrameOfScreen.size.height;
    }
    
    if (MovingToThirdOfDisplay(action)) {
        calculatedWindowRect = [SpectacleWindowPositionCalculator findThirdForWindowRect: calculatedWindowRect visibleFrameOfScreen: visibleFrameOfScreen withAction: action];
    }
    
    if (MovingToTopRegionOfDisplay(action)) {
        if (((visibleFrameOfScreen.size.height / 2.0f) - calculatedWindowRect.size.height) > 0.0f) {
            calculatedWindowRect.origin.y = calculatedWindowRect.origin.y + 1.0f;
        } else {
            calculatedWindowRect.origin.y = calculatedWindowRect.origin.y + 1.0f;
            calculatedWindowRect.size.height = calculatedWindowRect.size.height - 1.0f;
        }
        
        calculatedWindowRect.origin.y = calculatedWindowRect.origin.y + 1.0f;
    }
    
    if ((action >= SpectacleWindowActionLeftHalf) && (action <= SpectacleWindowActionLowerLeft)) {
        calculatedWindowRect.size.width = calculatedWindowRect.size.width - 1.0f;
    }
    
    NSLog(@"origin = %@, size = %@", NSStringFromPoint(calculatedWindowRect.origin), NSStringFromSize(calculatedWindowRect.size));

    return calculatedWindowRect;
}

+ (CGRect)calculateResizedWindowRect: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen sizeOffset: (CGFloat)sizeOffset {
    CGRect previousWindowRect = windowRect;
    
    windowRect.size.width = windowRect.size.width + sizeOffset;
    windowRect.origin.x = windowRect.origin.x - floor(sizeOffset / 2.0f);
    
    if (AgainstTheRightEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
        windowRect.origin.x = CGRectGetMaxX(visibleFrameOfScreen) - windowRect.size.width;
        
        if (AgainstTheLeftEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
            windowRect.size.width = visibleFrameOfScreen.size.width;
        }
    }
    
    if (AgainstTheLeftEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
        windowRect.origin.x = visibleFrameOfScreen.origin.x;
    }
    
    if (windowRect.size.width >= visibleFrameOfScreen.size.width) {
        windowRect.size.width = visibleFrameOfScreen.size.width;
    }
    
    windowRect.size.height = windowRect.size.height + sizeOffset;
    windowRect.origin.y = windowRect.origin.y - floor(sizeOffset / 2.0f);
    
    if (AgainstTheTopEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
        windowRect.origin.y = CGRectGetMaxY(visibleFrameOfScreen) - windowRect.size.height;
        
        if (AgainstTheBottomEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
            windowRect.size.height = visibleFrameOfScreen.size.height;
        }
    }
    
    if (AgainstTheBottomEdgeOfScreen(previousWindowRect, visibleFrameOfScreen)) {
        windowRect.origin.y = visibleFrameOfScreen.origin.y;
    }
    
    if (windowRect.size.height >= visibleFrameOfScreen.size.height) {
        windowRect.size.height = visibleFrameOfScreen.size.height;
        windowRect.origin.y = previousWindowRect.origin.y;
    }
    
    if (CGRectEqualToRect(previousWindowRect, visibleFrameOfScreen) && (sizeOffset < 0)) {
        windowRect.size.width = previousWindowRect.size.width + sizeOffset;
        windowRect.origin.x = previousWindowRect.origin.x - floor(sizeOffset / 2.0f);
        
        windowRect.size.height = previousWindowRect.size.height + sizeOffset;
        windowRect.origin.y = previousWindowRect.origin.y - floor(sizeOffset / 2.0f);
    }
    
    if ([SpectacleWindowPositionCalculator isWindowRect: windowRect tooSmallRelativeToVisibleFrameOfScreen: visibleFrameOfScreen]) {
        windowRect = previousWindowRect;
    }
    
    return windowRect;
}

#pragma mark -

+ (NSArray *)thirdsFromVisibleFrameOfScreen: (CGRect)visibleFrameOfScreen {
    NSMutableArray *result = [NSMutableArray new];
    NSInteger i = 0;
    
    for (i = 0; i < 3; i++) {
        CGRect thirdOfScreen = visibleFrameOfScreen;
        
        thirdOfScreen.origin.x = visibleFrameOfScreen.origin.x + (floor(visibleFrameOfScreen.size.width / 3.0f) * i);
        thirdOfScreen.size.width = floor(visibleFrameOfScreen.size.width / 3.0f);
        
        [result addObject: [SpectacleHistoryItem historyItemFromAccessibilityElement: nil windowRect: thirdOfScreen]];
    }
    
    for (i = 0; i < 3; i++) {
        CGRect thirdOfScreen = visibleFrameOfScreen;
        
        thirdOfScreen.origin.y = visibleFrameOfScreen.origin.y + visibleFrameOfScreen.size.height - (floor(visibleFrameOfScreen.size.height / 3.0f) * (i + 1));
        thirdOfScreen.size.height = floor(visibleFrameOfScreen.size.height / 3.0f);
        
        if ((i == 2) && (fmodf(visibleFrameOfScreen.size.height, 3.0f) != 0.0f)) {
            thirdOfScreen.origin.y = thirdOfScreen.origin.y - 1.0f;
            thirdOfScreen.size.height = thirdOfScreen.size.height + 1.0f;
        }
        
        [result addObject: [SpectacleHistoryItem historyItemFromAccessibilityElement: nil windowRect: thirdOfScreen]];
    }
    
    return result;
}

+ (CGRect)findThirdForWindowRect: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    NSArray *thirds = [SpectacleWindowPositionCalculator thirdsFromVisibleFrameOfScreen: visibleFrameOfScreen];
    CGRect result = [thirds[0] windowRect];
    NSInteger i = 0;
    
    for (i = 0; i < thirds.count; i++) {
        CGRect currentWindowRect = [thirds[i] windowRect];
        
        if (CGRectEqualToRect(currentWindowRect, windowRect)) {
            NSInteger j = i;
            
            if (action == SpectacleWindowActionNextThird) {
                if (++j >= thirds.count) {
                    j = 0;
                }
            } else if (action == SpectacleWindowActionPreviousThird) {
                if (--j < 0) {
                    j = thirds.count - 1;
                }
            }
            
            result = [thirds[j] windowRect];
            
            break;
        }
    }
    
    return result;
}

#pragma mark -

+ (BOOL)isWindowRect: (CGRect)windowRect tooSmallRelativeToVisibleFrameOfScreen: (CGRect)visibleFrameOfScreen {
    CGFloat minimumWindowRectWidth = floor(visibleFrameOfScreen.size.width / SpectacleMinimumWindowSizeRatio);
    CGFloat minimumWindowRectHeight = floor(visibleFrameOfScreen.size.height / SpectacleMinimumWindowSizeRatio);
    
    return (windowRect.size.width <= minimumWindowRectWidth) || (windowRect.size.height <= minimumWindowRectHeight);
}

#pragma mark -

+ (BOOL)halfToTwoThirds: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionLeftHalf) {
        result = AlreadyOneHalfWidthOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheLeftEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionRightHalf) {
        result = AlreadyOneHalfWidthOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheRightEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }
    
    return result;
}

+ (BOOL)twoThirdsToOneThird: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionLeftHalf) {
        result = AlreadyTwoThirdsWidthOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheLeftEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionRightHalf) {
        result = AlreadyTwoThirdsWidthOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheRightEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }
    
    return result;
}

#pragma mark -

+ (BOOL)halfToTwoThird: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionTopHalf) {
        result = AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheTopEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionBottomHalf) {
        result = AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheBottomEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }
    
    return result;
}

+ (BOOL)twoThirdToOneThird: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionTopHalf) {
        result = AlreadyTwoThirdsHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheTopEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionBottomHalf) {
        result = AlreadyTwoThirdsHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheBottomEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }
    
    return result;
}

#pragma mark -

+ (BOOL)quarters_HalfToTwoThird: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionUpperLeft || action == SpectacleWindowActionLowerLeft) {
        result = AlreadyOneHalfWidthOfDisplay(windowRect, visibleFrameOfScreen) && AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheLeftEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionUpperRight || action == SpectacleWindowActionLowerRight) {
        result = AlreadyOneHalfWidthOfDisplay(windowRect, visibleFrameOfScreen) && AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheRightEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }

    return result;
}

+ (BOOL)quarters_TwoThirdToOneThird: (CGRect)windowRect visibleFrameOfScreen: (CGRect)visibleFrameOfScreen withAction: (SpectacleWindowAction)action {
    BOOL result = NO;
    
    if (action == SpectacleWindowActionUpperLeft || action == SpectacleWindowActionLowerLeft) {
        result = AlreadyTwoThirdsWidthOfDisplay(windowRect, visibleFrameOfScreen) && AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheLeftEdgeOfScreen(windowRect, visibleFrameOfScreen);
    } else if (action == SpectacleWindowActionUpperRight || action == SpectacleWindowActionLowerRight) {
        result = AlreadyTwoThirdsWidthOfDisplay(windowRect, visibleFrameOfScreen) && AlreadyOneHalfHeightOfDisplay(windowRect, visibleFrameOfScreen) && AgainstTheRightEdgeOfScreen(windowRect, visibleFrameOfScreen);
    }

    return result;
}

/*
 AlreadyTwoThirdsWidthOfDisplay
 AlreadyOneHalfWidthOfDisplay
 
 AlreadyOneHalfHeightOfDisplay
 AlreadyTwoThirdsHeightOfDisplay
 
 */

@end
