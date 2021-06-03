//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// fb-rotate.c
//
// Compile with:
// gcc -w -o fb-rotate fb-rotate.c -framework IOKit -framework ApplicationServices
   
#include <getopt.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <ApplicationServices/ApplicationServices.h>
   
#define PROGNAME "fb-rotate"
#define MAX_DISPLAYS 16
   
// kIOFBSetTransform comes from <IOKit/graphics/IOGraphicsTypesPrivate.h>
// in the source for the IOGraphics family


enum {
    kIOFBSetTransform = 0x00000400,
};

void usage(void)
{
//    fprintf(stderr, "usage: %s -l\n"
//                    "       %s -i\n"
//                    "       %s -d <display ID> -m\n"
//                    "       %s -d <display ID> -r <0|90|180|270|1>\n"
//                "\n"
//                "-r 1 signfies 90 if currently not rotated; otherwise 0 (i.e. toggle)\n"
//                "\n"
//                "-d -1 can be used for the <display ID> of the internal monitor\n"
//                "-d 0  can be used for the <display ID> of the main monitor\n"
//                "-d 1  can be used for the <display ID> of the first non-internal monitor\n",
//                    PROGNAME, PROGNAME, PROGNAME, PROGNAME);
    exit(1);
}

void listDisplays(void)
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount, i;
    CGDirectDisplayID mainDisplay;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];

    mainDisplay = CGMainDisplayID();

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }

//    printf("Display ID       Resolution\n");
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
//        printf("0x%-14x %lux%lu %32s", dID,
//               CGDisplayPixelsWide(dID), CGDisplayPixelsHigh(dID),
//               (dID == mainDisplay) ? "[main display]\n" : "\n");
    }

    exit(0);
}


void infoDisplays(void)
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
//        exit(1);
    }

//    printf("#  Display_ID    Resolution  ____Display_Bounds____  Rotation\n");
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
//        printf("%-2d 0x%-10x  %4lux%-4lu  %5.0f %5.0f %5.0f %5.0f    %3.0f    %s%s%s",
//               CGDisplayUnitNumber (dID),
//               dID,
//               CGDisplayPixelsWide(dID), CGDisplayPixelsHigh(dID),
//
//               CGRectGetMinX (CGDisplayBounds (dID)),
//               CGRectGetMinY (CGDisplayBounds (dID)),
//               CGRectGetMaxX (CGDisplayBounds (dID)),
//               CGRectGetMaxY (CGDisplayBounds (dID)),
//
//               CGDisplayRotation (dID),
//               (CGDisplayIsActive (dID)) ? "" : "[inactive]",
//               (dID == mainDisplay) ? "[main]" : "",
//               (CGDisplayIsBuiltin (dID)) ? "[internal]\n" : "\n");
    }

//    printf("Mouse Cursor Position:  ( %5.0f , %5.0f )\n",
//               (float)ourLoc.x, (float)ourLoc.y);

//    exit(0);
}

void setMainDisplay(CGDirectDisplayID targetDisplay)
{
    int                   deltaX, deltaY, flag;
    CGDisplayErr       dErr;
    CGDisplayCount     displayCount, i;
    CGDirectDisplayID mainDisplay;
    CGDisplayCount     maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID  onlineDisplays[MAX_DISPLAYS];
    CGDisplayConfigRef config;

    mainDisplay = CGMainDisplayID();

    if (mainDisplay == targetDisplay) {
        exit(0);
    }

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
        exit(1);
    }

    flag = 0;
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
            if (dID == targetDisplay) { flag = 1; }
    }
    if (flag == 0) {
//        fprintf(stderr, "No such display ID: 0x%-10x.\n", targetDisplay);
        exit(1);
    }

    deltaX = -CGRectGetMinX (CGDisplayBounds (targetDisplay));
    deltaY = -CGRectGetMinY (CGDisplayBounds (targetDisplay));

    CGBeginDisplayConfiguration (&config);

    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];

    CGConfigureDisplayOrigin (config, dID,
        CGRectGetMinX (CGDisplayBounds (dID)) + deltaX,
        CGRectGetMinY (CGDisplayBounds (dID)) + deltaY );
    }

    CGCompleteDisplayConfiguration (config, kCGConfigureForSession);


    exit(0);
}


CGDirectDisplayID InternalID(void) {
    // returns the ID of the internal monitor;
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
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        if ((CGDisplayIsBuiltin (dID))) {
            return dID;
        }
    }
    return fallbackID;
}


CGDirectDisplayID nonInternalID(uint32_t preId) {
    // returns the ID of the selected active monitor that is not internal or 0 if only one monitor;
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
    //exit(1);
    
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
//        exit(1);
    }

//    printf("#  Display_ID    Resolution  ____Display_Bounds____  Rotation\n");
    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        if(CGRectGetMinX(CGDisplayBounds(dID)) < ourLoc.x) {
            if(CGRectGetMinY(CGDisplayBounds(dID)) < ourLoc.y) {
                if(CGRectGetMaxX(CGDisplayBounds(dID)) > ourLoc.x) {
                    if(CGRectGetMaxY(CGDisplayBounds(dID)) > ourLoc.y) {
                        return CGDisplayUnitNumber(dID);
                    }
                }
            }
        }
    }
    
    return CGDisplayUnitNumber(mainDisplay);
}

int screenNumToDisplayUnitNumber(int screenNum)
{
    CGDisplayErr      dErr;
    CGDisplayCount    displayCount;
    CGDisplayCount    maxDisplays = MAX_DISPLAYS;
    CGDirectDisplayID onlineDisplays[MAX_DISPLAYS];

    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint ourLoc = CGEventGetLocation(ourEvent);

    CFRelease(ourEvent);

    dErr = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    if (dErr != kCGErrorSuccess) {
//        fprintf(stderr, "CGGetOnlineDisplayList: error %d.\n", dErr);
//        exit(1);
    }
    
    return CGDisplayUnitNumber(onlineDisplays[screenNum]);
}


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
//        exit(1);
    }

    for (i = 0; i < displayCount; i++) {
        CGDirectDisplayID dID = onlineDisplays[i];
        
        if (CGDisplayIsBuiltin (dID)) {
            ret = i;
        }
    }

    return ret;
}
