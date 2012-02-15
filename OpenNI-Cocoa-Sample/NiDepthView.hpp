//
//  NiDepthView.h
//  NiGLDepthView
//
//  Created by Daniel Shein on 10/7/11.
//  Copyright 2011 LoFT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

#import <OpenNI/OpenNI.h>

enum NiViewType {
    NiViewDepth,
    NiViewImage,
    NiViewHybrid
};


@interface NiDepthView : NSOpenGLView <OpenNIDelegate>
{
    NiViewType viewState;
    
    // Texture Variable
    XnRGB24Pixel* texMap;
    unsigned int texMapX;
    unsigned int texMapY;

    // Display Color Ratios
    CGFloat redRatio, greenRatio, blueRatio;
    
    OpenNI *openNI;
}

@property (nonatomic, assign) NiViewType viewState;

-(void)setColor:(NSColor*)_color;

// OpenGL Methods
-(void)initGlEnvironment;
-(void)drawFrame;

-(void)setFrameTextureStatic;

-(void)startOpenNi;

@end
