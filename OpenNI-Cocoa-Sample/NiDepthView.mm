//
//  NiDepthView.m
//  NiGLDepthView
//
//  Created by Daniel Shein on 10/7/11.
//  Copyright 2011 LoFT. All rights reserved.
//

#import "NiDepthView.hpp"

#define DEFAULT_DISPLAY_MODE NiViewDepth

#define MAX_DEPTH            10000


@implementation NiDepthView
@synthesize viewState;

-(id)init
{
    self = [super init];
    if (self != nil) {
        redRatio = 1, greenRatio = 1, blueRatio = 0;
        viewState = DEFAULT_DISPLAY_MODE;
        [self startOpenNi];
    }
    
    return self;
}

-(void)awakeFromNib
{
    redRatio = 1, greenRatio = 1, blueRatio = 0;
    viewState = DEFAULT_DISPLAY_MODE;
    [self startOpenNi];
}


-(void)dealloc
{
}


-(void)startOpenNi
{
    openNI = [OpenNI instance];
    [openNI addDelegate:self];
    [openNI initOpenNiWithConfigFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"xml"]];
}

-(void)openNiInitCompleteWithStatus:(NSNumber *)_status andError:(NSError*)_error
{
    if ([_status intValue] == 0) {
        // Texture map init
        texMapX = (((unsigned short)(openNI.fulleResolution.width-1) / 512) + 1) * 512;
        texMapY = (((unsigned short)(openNI.fulleResolution.height-1) / 512) + 1) * 512;
        texMap  = (XnRGB24Pixel*)malloc(texMapX * texMapY * sizeof(XnRGB24Pixel));
        
        [openNI startGeneratingFrames]; 
    } else {
        //handle error
    }
}

-(void)setColor:(NSColor*)_color
{
    redRatio = [_color redComponent];
    greenRatio = [_color greenComponent];
    blueRatio = [_color blueComponent];
}


-(void)frameReady
{
    
    XnDepthPixel *pDepth = (XnDepthPixel*) openNI.depthMap;
    
    //Calculate the accumulative historgram for the yellow display
    float depthHistory[MAX_DEPTH];
    xnOSMemSet(depthHistory, 0, MAX_DEPTH*sizeof(float));
    unsigned int nNumberOfPoints = 0;
    for (XnUInt y = 0; y < openNI.croppedResolution.height; ++y)
    {
        for (XnUInt x = 0; x < openNI.croppedResolution.width; ++x, ++pDepth) {
            if (*pDepth != 0) {
                depthHistory[*pDepth]++;
                nNumberOfPoints++;
            }
        }
    }

    
    for (int nIndex = 1; nIndex < MAX_DEPTH; nIndex++) {
        depthHistory[nIndex] += depthHistory[nIndex - 1];
    }
    
    if (nNumberOfPoints) {
        for (int nIndex = 1; nIndex < MAX_DEPTH; nIndex++) {
            depthHistory[nIndex] = (unsigned int)(256 * (1.0f - (depthHistory[nIndex] / nNumberOfPoints)));
        }
    }
    
    xnOSMemSet(texMap, 0, texMapX * texMapY * sizeof(XnRGB24Pixel));
    
        
    //TODO: add support for toggling source - Image, Depth or Hybrid
    
    const XnDepthPixel* pDepthRow = openNI.depthMap;
    XnRGB24Pixel* pTexRow = texMap + (XnUInt)openNI.offset.height * texMapX;
    
    for (XnUInt y = 0; y <  openNI.croppedResolution.height; ++y)
    {
        const XnDepthPixel* pDepth = pDepthRow;
        XnRGB24Pixel* pTex = pTexRow + (XnUInt)(XnUInt)openNI.offset.width;
        
        for (XnUInt x = 0; x < openNI.croppedResolution.width; ++x, ++pDepth, ++pTex)
        {
        
            if (*pDepth != 0)
            {
                int nHistValue = depthHistory[*pDepth];
                pTex->nRed = nHistValue * redRatio;
                pTex->nGreen = nHistValue * greenRatio;
                pTex->nBlue = nHistValue * blueRatio;
            }
        }
        
        pDepthRow += (XnUInt)openNI.croppedResolution.width;
        pTexRow += texMapX;
		
    }
    
    [self performSelectorOnMainThread:@selector(setFrameTextureStatic) withObject:nil waitUntilDone:NO];

}

#pragma mark - OpenGL Methods

-(void)initGlEnvironment
{
    glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
   	glOrtho(0, self.bounds.size.width, self.bounds.size.height, 0, -1.0, 1.0);
    
    glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
}

-(void)drawFrame
{
    [self initGlEnvironment];
    glClearColor(0.5f, 0.5f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POLYGON);
    glVertex2f(-100.5f,  100.5f);
    glVertex2f( 100.5f,  100.5f);
    glVertex2f( 100.5f, -100.5f);
    glVertex2f(-100.5f, -100.5f);
    glEnd();
    glFlush();
}
  

 -(void)setFrameTextureStatic
{
    CGPoint _textureSize = CGPointMake(texMapX, texMapY);
    
    [self initGlEnvironment];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _textureSize.x, _textureSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, texMap);    
    
    GLfloat width  = self.bounds.size.width;
    GLfloat height = self.bounds.size.height;
    
    
    int nXRes = openNI.fulleResolution.width;
    int nYRes = openNI.fulleResolution.height;
    
    
    glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0);
    glVertex3d(0.0, 0.0, 0.0);
    
    glTexCoord2f((float)nXRes/(float)texMapX, 0.0);
    glVertex3d(width, 0.0, 0.0);
    
    glTexCoord2f( (float)nXRes/(float)texMapX, (float)nYRes/(float)texMapY);
    glVertex3d(width, height, 0.0);
    
    glTexCoord2f(0.0, (float)nYRes/(float)texMapY);
    glVertex3d(0.0, height, 0.0);
    
    glEnd();
    glFlush();
    
}

@end
