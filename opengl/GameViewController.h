//
//  GameViewController.h
//  opengl
//
//  Created by marcin on 03/01/16.
//  Copyright (c) 2016 Marcin Karmelita. All rights reserved.
//

#import <SceneKit/SceneKit.h>

#import "GameView.h"

@interface GameViewController : NSViewController

@property (assign) IBOutlet GameView *gameView;
@property (weak) IBOutlet NSSlider *xAxis;
@property (weak) IBOutlet NSSlider *yAxis;
@property (weak) IBOutlet NSSlider *zAxis;
@property (weak) IBOutlet NSTextFieldCell *firstAngle;
@property (weak) IBOutlet NSTextFieldCell *secondAngle;
@property (weak) IBOutlet NSTextFieldCell *thirdAngle;
@end
