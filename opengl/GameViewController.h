//
//  GameViewController.h
//  opengl
//
//  Created by marcin on 03/01/16.
//  Copyright (c) 2016 Marcin Karmelita. All rights reserved.
//

#import <SceneKit/SceneKit.h>

#import "GameView.h"
#import <ORSSerial/ORSSerial.h>

@class ORSSerialPortManager;

@interface GameViewController : NSViewController <ORSSerialPortDelegate>

@property (assign) IBOutlet GameView *gameView;
@property (weak) IBOutlet NSTextField *pxTextField;
@property (weak) IBOutlet NSTextField *pyTextField;
@property (weak) IBOutlet NSTextField *pzTextField;
@property (weak) IBOutlet NSTextField *theta0Label;
@property (weak) IBOutlet NSTextField *theta1Label;
@property (weak) IBOutlet NSTextField *theta2Label;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *errorLabel;
@property (weak) IBOutlet NSButton *workingSpaceButton;



@end
