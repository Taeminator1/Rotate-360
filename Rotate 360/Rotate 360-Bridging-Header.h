//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//  This file is modified from origin below.
//  https://github.com/CdLbB/fb-rotate/blob/master/fb-rotate.c
   
#include <getopt.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <ApplicationServices/ApplicationServices.h>
   
#define PROGNAME "fb-rotate"
#define MAX_DISPLAYS 16
   
//  kIOFBSetTransform comes from <IOKit/graphics/IOGraphicsTypesPrivate.h>
//  in the source for the IOGraphics family

enum {
    kIOFBSetTransform = 0x00000400,
};


// returns the ID of the selected active monitor that is not internal or 0 if only one monitor;
CGDirectDisplayID nonInternalID(uint32_t preId) {
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount, i;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];
    CGDirectDisplayID fallbackID = 0;
    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }
    
    CGDirectDisplayID dID = onlineDisplays[preId];
    if (!(CGDisplayIsBuiltin (dID)) && (CGDisplayIsActive (dID))) {
        return dID;
    }
    
    return fallbackID;
}


CGDirectDisplayID cgIDfromU32(uint32_t preId)
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount, i;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];
    CGDirectDisplayID postId = preId;

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        if ((dID == preId) || (dID == postId) ||
            (onlineDisplays[i] == preId) || (onlineDisplays[i] == postId)) {
            return dID;
        }
    }
//    fprintf(stderr, "Could not find a matching id in onlineDisplays!\n");
    exit(1);
    
    return 0;
}

IOOptionBits angle2options(long angle)
{
    static IOOptionBits anglebits[] = {
               (kIOFBSetTransform | (kIOScaleRotate0)   << 16),
               (kIOFBSetTransform | (kIOScaleRotate90)  << 16),
               (kIOFBSetTransform | (kIOScaleRotate180) << 16),
               (kIOFBSetTransform | (kIOScaleRotate270) << 16)
    };

    if ((angle % 90) != 0) // Map arbitrary angles to a rotation reset
        return anglebits[0];

    return anglebits[(angle / 90) % 4];
}

CG_EXTERN io_service_t duplicatedCGDisplayIOServicePort(CGDirectDisplayID display) {
    return CGDisplayIOServicePort(display);
}


// MARK: - Add custom functions
int displayUnitNumberOfMouseCursorPosition(void)
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount, i;
    CGDirectDisplayID mainDisplay;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];

    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint ourLoc = CGEventGetLocation(ourEvent);

    CFRelease(ourEvent);

    mainDisplay = CGMainDisplayID();

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }

//    printf("#  Display_ID    Resolution  ____Display_Bounds____  Rotation\n");
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        if (CGRectGetMinX(CGDisplayBounds(dID)) < ourLoc.x &&
            CGRectGetMaxX(CGDisplayBounds(dID)) > ourLoc.x &&
            CGRectGetMinY(CGDisplayBounds(dID)) < ourLoc.y &&
            CGRectGetMaxY(CGDisplayBounds(dID)) > ourLoc.y) {
                    return CGDisplayUnitNumber(dID);
        }
    }
    
    return CGDisplayUnitNumber(mainDisplay);
}


// Return value of main display to 0.
// If it has internal display, return to 0 or more than 0.
// Otherwise, return value to -1
int findInternalDisplay(void)
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount, i;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];

    CGEventRef ourEvent = CGEventCreate(NULL);
    CFRelease(ourEvent);
    
    int ret = -1;

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }

    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        
        if (CGDisplayIsBuiltin (dID)) {
            ret = i;
        }
    }

    return ret;
}
