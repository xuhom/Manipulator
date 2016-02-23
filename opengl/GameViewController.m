//
//  GameViewController.m
//  opengl
//
//  Created by marcin on 03/01/16.
//  Copyright (c) 2016 Marcin Karmelita. All rights reserved.
//

#import "GameViewController.h"
#import "NSFileRead.h"

/// Strcuture which keeps the value of kinematics coordinates
typedef struct {
    float theta0;
    float theta1;
    float theta2;
} Angles;


@implementation GameViewController {
    NSArray *nodes;
    // thetas in radians
    float theta1, theta2, theta3;
    SCNNode *ship;
    SCNNode *ship2;
    SCNNode *ship3;
    SCNNode *ship4;
    SCNNode *cameraNode;
    SCNMatrix4 defaultTransforms[4];
    ORSSerialPort *serialPort;
    ORSSerialPortManager *serialPortManager;
    Angles angle;
    NSMutableString * buffor;
    NSArray *pointOfWorkingSpace;
    SCNNode *workingSpace;
    
}
/// Converts degrees to radians
/// @param _angle A value of angle in degrees
///
/// @return A value of angle in radians
-(float)degreesToRad: (float) _angle{
    return M_PI*_angle/180;
}


#pragma mark - DEBUG

-(void)logNode:(SCNNode*) node {

    NSLog(@"\n\n ### %@  ###", node.name);
    NSLog(@"First column:");
    NSLog(@"%f", node.transform.m11);
    NSLog(@"%f", node.transform.m12);
    NSLog(@"%f", node.transform.m13);
    NSLog(@"%f", node.transform.m14);
    
    NSLog(@"Second column:");
    NSLog(@"%f", node.transform.m21);
    NSLog(@"%f", node.transform.m22);
    NSLog(@"%f", node.transform.m23);
    NSLog(@"%f", node.transform.m24);
    
    NSLog(@"Third column:");
    NSLog(@"%f", node.transform.m31);
    NSLog(@"%f", node.transform.m32);
    NSLog(@"%f", node.transform.m33);
    NSLog(@"%f", node.transform.m34);
    
    NSLog(@"Fourth column:");
    NSLog(@"%f", node.transform.m41);
    NSLog(@"%f", node.transform.m42);
    NSLog(@"%f", node.transform.m43);
    NSLog(@"%f", node.transform.m44);
}

-(void)logWorldNode:(SCNNode*) node {
    
    NSLog(@"\n\n ### WORLD: %@  ###", node.name);
    NSLog(@"First column:");
    NSLog(@"%f", node.worldTransform.m11);
    NSLog(@"%f", node.worldTransform.m12);
    NSLog(@"%f", node.worldTransform.m13);
    NSLog(@"%f", node.worldTransform.m14);
    
    NSLog(@"Second column:");
    NSLog(@"%f", node.worldTransform.m21);
    NSLog(@"%f", node.worldTransform.m22);
    NSLog(@"%f", node.worldTransform.m23);
    NSLog(@"%f", node.worldTransform.m24);
    
    NSLog(@"Third column:");
    NSLog(@"%f", node.worldTransform.m31);
    NSLog(@"%f", node.worldTransform.m32);
    NSLog(@"%f", node.worldTransform.m33);
    NSLog(@"%f", node.worldTransform.m34);
    
    NSLog(@"Fourth column:");
    NSLog(@"%f", node.worldTransform.m41);
    NSLog(@"%f", node.worldTransform.m42);
    NSLog(@"%f", node.worldTransform.m43);
    NSLog(@"%f", node.worldTransform.m44);
}



-(void)awakeFromNib
{
    // import model of your scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/robot_rhino5.scn"];


    // create and add a camera to the scene
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zNear=100;
    cameraNode.camera.zFar=10000;
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 2000);
    [scene.rootNode addChildNode:cameraNode];
    
    
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    ship = [scene.rootNode childNodeWithName:@"part_1" recursively:YES];
    ship2 = [scene.rootNode childNodeWithName:@"part_2" recursively:YES];
    ship3 = [scene.rootNode childNodeWithName:@"part_3" recursively:YES];
    ship4 = [scene.rootNode childNodeWithName:@"part_4" recursively:YES];
    [ship addChildNode:ship2];
    [ship2 addChildNode:ship3];
    [ship3 addChildNode:ship4];
    nodes= [NSArray arrayWithObjects:ship, ship2, ship3, ship4, nil];
    defaultTransforms[0] = ship.transform;
    defaultTransforms[1] = ship2.transform;
    defaultTransforms[2] = ship3.transform;
    defaultTransforms[3] = ship4.transform;
    
    [self logNode:ship];
    [self logNode:ship2];
    
    

    // animate the 3d object
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, M_PI*2)];
    animation.duration = 1;
    animation.repeatCount = 0;
    [ship addAnimation:animation forKey:nil];

    // set the scene to the view
    self.gameView.scene = scene;
    
    // allows the user to manipulate the camera
    self.gameView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    self.gameView.showsStatistics = YES;


    
    // configure the view
    self.gameView.backgroundColor = [NSColor blueColor];
    
    
    //SERIAL PORT
    serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    
    serialPort = [ORSSerialPort serialPortWithPath:@"/dev/cu.HC-05-DevB"]; //Presice Serial Port Path: http://stackoverflow.com/questions/12254378/how-to-find-the-serial-port-number-on-mac-os-x
    serialPort.baudRate = @38400;
    serialPort.delegate = self;
    buffor = [[NSMutableString alloc]initWithString:@""];
    
    //UI
    self.theta0Label.hidden = true;
    self.theta1Label.hidden = true;
    self.theta2Label.hidden = true;
    self.connectButton.enabled = true;
    self.statusLabel.textColor = [NSColor redColor];
    [self.statusLabel setStringValue:@"Status: Disconnected"];
    self.errorLabel.hidden = true;
    
    NSFileRead * fileRead = [[NSFileRead alloc]init];
    pointOfWorkingSpace = [fileRead readFile];
    
    
    
    //SAMPLE DATA
    int nr = 45864;
    SCNVector3 vertices[nr];
    
    for (int i=0; i<nr; i++) {
        NSArray* arrayOfCoordinates = [[pointOfWorkingSpace objectAtIndex:i] componentsSeparatedByString:@" "];
        vertices[i] = SCNVector3Make([arrayOfCoordinates[0] integerValue]*10, [arrayOfCoordinates[1] integerValue]*10, [arrayOfCoordinates[2] integerValue]*10);
    }
   
    
    int count = sizeof(vertices) / sizeof(vertices[0]);
    
    
    
    // Array with predefined vertices sequence
    int verticesSequence[nr*2];
    verticesSequence[0]=0;
    
    for (int i=1; i <nr*2; i++) {
        verticesSequence[i]=i;
    }
   
    
    
    NSData *sequenceData = [NSData dataWithBytes:verticesSequence
                                          length:sizeof(verticesSequence)];
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:sequenceData                                                            primitiveType:SCNGeometryPrimitiveTypePoint
                                                               primitiveCount:(count)
                                                                bytesPerIndex:sizeof(int)];
    
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vertices
                                                                        count:count];
    
    SCNGeometry *line = [SCNGeometry geometryWithSources:@[source]
                                                elements:@[element]];

    workingSpace = [SCNNode nodeWithGeometry:line];
    

    [scene.rootNode addChildNode:workingSpace];

    

    
}

-(void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort{
    
}



#pragma mark - UI

/// Reads value of UITextFields and sends it via Serial Port
/// @param sender Sender of a messages
///
/// @return Action
- (IBAction)calculateTapped:(id)sender {
    
    NSLog(@"%@", [NSString stringWithFormat:@"<px=%@>", self.pxTextField.stringValue]);
    NSLog(@"%@", [[NSString stringWithFormat:@"<px=%@>", self.pxTextField.stringValue] dataUsingEncoding:NSUTF8StringEncoding]);
    
    [serialPort sendData:[[NSString stringWithFormat:@"<px=%@>", self.pxTextField.stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    DELAY(100); // The delay is necessary in order to avoid missing data
    [serialPort sendData:[[NSString stringWithFormat:@"<py=%@>", self.pyTextField.stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    DELAY(100);
    [serialPort sendData:[[NSString stringWithFormat:@"<pz=%@>", self.pzTextField.stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    DELAY(100);
    [serialPort sendData:[[NSString stringWithFormat:@"<calculate>"] dataUsingEncoding:NSUTF8StringEncoding]];
    DELAY(100);
    

}
/// Connects device
/// @param sender Sender of a message
///
/// @return Action
- (IBAction)connectButtonTapped:(id)sender {
    serialPort.isOpen ? [serialPort close] : [serialPort open];
    [self logNode:cameraNode];
    [self logWorldNode:cameraNode];
}

/// Indicates connection via Serial Port
/// @param serialPort Serial Port used is application
///
- (void)serialPortWasOpened:(ORSSerialPort *)serialPort{
    self.connectButton.title = @"Close";
    [self.statusLabel setStringValue:@"Status: Connected"];
    self.statusLabel.textColor = [NSColor greenColor];
}


/// Indicates disconnection via Serial Port
/// @param serialPort Serial Port used in application
///
- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    self.connectButton.title = @"Open";
    [self.statusLabel setStringValue:@"Status: Disconnected"];
    self.statusLabel.textColor = [NSColor redColor];
}

/// Shows/hides working space of a manipulator
/// @param sender Sender of a message
///
/// @return Action
- (IBAction)workingSpaceSelected:(id)sender {
    if (self.workingSpaceButton.state) {
        workingSpace.hidden = NO;
    } else {
        workingSpace.hidden = YES;
    }
}




#pragma mark - SERIAL



/// Reads incoming data from SerialPort and then stores it in a buffor. When the data is complete, the kinamtics coordinates are set
/// @param serialPort Serial Port used in application
/// @param data Incoming data
///
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *error = @"Error: ";
    NSString *recievedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [buffor appendString:recievedString];
    
    NSLog(@"%@", buffor);
    
    
    if ([buffor containsString:@"!"]) {
        self.errorLabel.hidden = true;
        [self.errorLabel setStringValue:@"Point is inside working space."];
        
        if ([buffor containsString:error]) {
            [buffor deleteCharactersInRange:[error rangeOfString:error]];
            self.errorLabel.hidden = false;
            [self.errorLabel setStringValue:@"Point is outside working space."];
            
        }
        NSString *formattedString = [buffor substringToIndex:buffor.length-1];
        NSArray *separatedRecievedString = [formattedString componentsSeparatedByString:@"-"];
        
        if ([separatedRecievedString count] == 3) {
            angle.theta0 = [separatedRecievedString[0] floatValue];
            angle.theta1 = [separatedRecievedString[1] floatValue];
            angle.theta2 = [separatedRecievedString[2] floatValue];
            
            [self.theta0Label setStringValue:[NSString stringWithFormat:@"Theta 0: %.2f", angle.theta0]];
            [self.theta1Label setStringValue:[NSString stringWithFormat:@"Theta 1: %.2f", angle.theta1]];
            [self.theta2Label setStringValue:[NSString stringWithFormat:@"Theta 2: %.2f", angle.theta2]];
            self.theta0Label.hidden = false;
            self.theta1Label.hidden = false;
            self.theta2Label.hidden = false;
            ship4.transform = SCNMatrix4Rotate(defaultTransforms[3], [self degreesToRad:-(angle.theta2-90.0)], 0, 1, 0);
            ship3.transform = SCNMatrix4Rotate(defaultTransforms[2], [self degreesToRad:-(angle.theta1-90.0)], 0, 1, 0);
            ship.rotation = SCNVector4Make(0, 0, 1, [self degreesToRad:(angle.theta0-90.0)]);
        }
        NSRange range = [buffor rangeOfString:buffor];
        [buffor deleteCharactersInRange:range];
    }
    
}

- (void)setSerialPort:(ORSSerialPort *)port
{
    if (port != serialPort)
    {
        [serialPort close];
        serialPort.delegate = nil;
        
        serialPort = port;
        
        serialPort.delegate = self;
    }
}

@end
