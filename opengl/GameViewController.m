//
//  GameViewController.m
//  opengl
//
//  Created by marcin on 03/01/16.
//  Copyright (c) 2016 Marcin Karmelita. All rights reserved.
//

#import "GameViewController.h"
#import <ORSSerial/ORSSerial.h>

#define l1 16
#define l2 12.5
#define l3 12.5
#define l4 16

@implementation GameViewController {
    NSArray *nodes;
    // thetas in radians
    float theta1, theta2, theta3;
    SCNNode *ship;
    SCNNode *ship2;
    SCNNode *ship3;
    SCNNode *ship4;
    SCNMatrix4 defaultTransforms[4];
    ORSSerialPort *serialPort;
}

-(float)anglesToRad: (float) angle{
    return M_PI*angle/180;
}

-(SCNMatrix4)defaultMatrix01{
    float s1 = sin(0);
    float c1 = cos(0);
//    SCNMatrix4 mat = {
//        -s1,-c1,0, l2, //l2
//        c1, -s1,0, 0,
//        0,  0,  1, l1, //l1
//        0.5,  2,  5, 1
//    };
    SCNMatrix4 mat = {
        -s1, c1,0, 0, //l2
        -c1, -s1,0, 0,
        0,  0,  1, 0, //l1
        l2,  0,  l1, 1
    };

    return mat;
};

-(SCNMatrix4) trans01{
    SCNMatrix4 trans = SCNMatrix4MakeTranslation(l2, 0, l1);
    SCNMatrix4 mat = SCNMatrix4MakeRotation(theta1 + M_PI_2, 0, 0, 1);
    return SCNMatrix4Mult(trans, mat);
}

-(SCNMatrix4) trans12{
    SCNMatrix4 trans = SCNMatrix4MakeTranslation(-l3, 0, 0);
    SCNMatrix4 rot = SCNMatrix4Mult(SCNMatrix4MakeRotation(-M_PI_2, 1, 0, 0), SCNMatrix4MakeRotation(M_PI + theta2, 1, 0, 0));
    return SCNMatrix4Mult(trans, rot);
}

-(SCNMatrix4) trans23{
    SCNMatrix4 trans = SCNMatrix4MakeTranslation(l4, 0, 0);
    SCNMatrix4 mat = SCNMatrix4MakeRotation(theta3 + M_PI, 0, 0, 1);
    return SCNMatrix4Mult(trans, mat);
}

-(SCNMatrix4) trans34{
    SCNMatrix4 rot = SCNMatrix4Mult(SCNMatrix4MakeRotation(M_PI_2, 1, 0, 0), SCNMatrix4MakeRotation(M_PI, 0, 0, 1));
    return rot;
}

-(SCNMatrix4) nodeDefaultTransform: (SCNNode*)node{
    return node.transform;
}

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
    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/robot_rhino5.scn"];
//    scene.rootNode.transform = SCNMatrix4MakeRotation(-M_PI_2, 1, 0, 0);

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zNear=100;
    cameraNode.camera.zFar=10000;
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 20, 0);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    
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
    animation.repeatCount = 0; //repeat forever
    [ship addAnimation:animation forKey:nil];

    // set the scene to the view
    self.gameView.scene = scene;
    
    // allows the user to manipulate the camera
    self.gameView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    self.gameView.showsStatistics = YES;


    
    // configure the view
    self.gameView.backgroundColor = [NSColor blueColor];
    
    self.firstAngle.title = [NSString stringWithFormat:@"%.2f",[self anglesToRad:self.xAxis.floatValue]];
    self.secondAngle.title = [NSString stringWithFormat:@"%.2f",[self anglesToRad:self.yAxis.floatValue]];
    self.thirdAngle.title = [NSString stringWithFormat:@"%.2f",[self anglesToRad:self.zAxis.floatValue]];
    
    //SERIAL PORT
    serialPort = [ORSSerialPort serialPortWithPath:@"/dev/cu.HC-05-DevB"];
    serialPort.baudRate = @38400;
    serialPort.delegate = self;
    [serialPort open];
    
}
- (IBAction)xAxisTapped:(id)sender {
    float xRot = [self anglesToRad:self.xAxis.floatValue];
    ship.rotation = SCNVector4Make(0, 0, 1, xRot);
    self.firstAngle.title = [NSString stringWithFormat:@"%.2f",xRot];

    NSData *data = [[NSString stringWithFormat:@"<px=%f>", self.xAxis.floatValue] dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
    
}
- (IBAction)yAxisTapped:(id)sender {
    float yRot = [self anglesToRad:self.yAxis.floatValue];
    ship3.transform = SCNMatrix4Rotate(defaultTransforms[2], yRot, 0, 1, 0);
    NSData *data = [[NSString stringWithFormat:@"<py=%f>", self.yAxis.floatValue] dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];

}
- (IBAction)zAxisTapped:(id)sender {
    float zRot = [self anglesToRad:self.zAxis.floatValue];
    self.thirdAngle.title = [NSString stringWithFormat:@"%.2f",zRot];
    ship4.transform = SCNMatrix4Rotate(defaultTransforms[3], zRot, 0, 1, 0);
    NSData *data = [[NSString stringWithFormat:@"<pz=%f>", self.zAxis.floatValue] dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];

}

void printPrompt(void)
{
    printf("\n> ");
}

void listAvailablePorts(void)
{
    printf("\nPlease select a serial port: \n");
    ORSSerialPortManager *manager = [ORSSerialPortManager sharedSerialPortManager];
    NSArray *availablePorts = manager.availablePorts;
    [availablePorts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ORSSerialPort *port = (ORSSerialPort *)obj;
        printf("%lu. %s\n", (unsigned long)idx, [port.name UTF8String]);
    }];
    printPrompt();
}

- (IBAction)resetTapped:(id)sender {
    ship.transform = defaultTransforms[0];
    ship2.transform = defaultTransforms[1];
    ship3.transform = defaultTransforms[2];
    ship4.transform = defaultTransforms[3];
    self.xAxis.integerValue = 0;
    self.yAxis.integerValue = 0;
    self.zAxis.integerValue = 0;
    
    listAvailablePorts();
    
    NSData *data = [[NSString stringWithFormat:@"<calculate>"] dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
    
    
   //[serialPort close];
    
    
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
}

@end
