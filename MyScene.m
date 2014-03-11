/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "MyScene.h"
#import "PlayerTest.h"

#import "RemoveSpaceshipBehavior.h"

@implementation MyScene
 PlayerTest *player;
-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
        int timestart = CACurrentMediaTime();
		/* Setup your scene here */
		//self.backgroundColor = [SKColor colorWithRed:0.4 green:0.0 blue:0.4 alpha:1.0];
		//self.anchorPoint = CGPointMake (0.5,0.5);
		SKLabelNode* myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		myLabel.text = @"Hello, Kobold!";
		myLabel.fontSize = 60;
		myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        SKNode *myWorld = [SKNode node];
        myWorld.name = @"world";
        [self addChild:myWorld];
        
		//[self addChild:myLabel];
        player = [PlayerTest spriteNodeWithImageNamed:@"idle.png"];
        
        player.position = CGPointMake(100, 100);
        player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(player.size.width-40, player.size.height-9)];
        player.physicsBody.friction = 1.0f;
        player.physicsBody.restitution = 0.0f;
       
        
        KKTilemapNode *theMap = [KKTilemapNode tilemapWithContentsOfFile:@"level1.tmx"];
        
        theMap.name = @"map";
        theMap.position = CGPointMake(0, 0);
        theMap.zPosition = 0.0;
        [self addChild:theMap];
        KKTilemapLayerContourTracer *tracer = [KKTilemapLayerContourTracer contourMapFromTileLayer:theMap.mainTileLayerNode.layer];
       
        for (int i = 0; i < tracer.contourSegments.count; i++) {
            CGPathRef chain = (__bridge CGPathRef)([tracer.contourSegments objectAtIndex:i]);
                      SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0, 0)];
            [sprite physicsBodyWithEdgeLoopFromPath:chain];
            sprite.zPosition = 0.0;
            [theMap addChild:sprite];
            
        }
      KKTilemapObject *playerstart =  [theMap objectNamed:@"player_start"];
        player.position = playerstart.position;
		//[self addSmartbombButton];
        [theMap addChild:player];
        NSLog(@"qadfhjsqs: %@",[myWorld childNodeWithName:@"map"]);
        int timestop = CACurrentMediaTime();
        NSLog(@"DIfference: %i",(int)(timestop-timestart));
      
	}
	return self;
}

-(void) addSmartbombButton
{
	// label will become a button that removes all spaceships
	SKLabelNode* buttonLabel = [SKLabelNode labelNodeWithFontNamed:@"Monaco"];
	buttonLabel.text = @"SMARTBOMB!";
	buttonLabel.fontSize = 32;
	buttonLabel.zPosition = 1;
	buttonLabel.position = CGPointMake(CGRectGetMidX(self.frame),
									   self.frame.size.height - buttonLabel.frame.size.height);
	[self addChild:buttonLabel];
    
	// KKButtonBehavior turns any node into a button
	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
	buttonBehavior.selectedScale = 1.2;
	[buttonLabel addBehavior:buttonBehavior];
	
	// observe button execute notification
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(clearSpaceButtonDidExecute:)
					   object:buttonLabel];

	// preload the sound the button plays
	[[OALSimpleAudio sharedInstance] preloadEffect:@"die.wav"];
}

-(void) clearSpaceButtonDidExecute:(NSNotification*)notification
{
	[[OALSimpleAudio sharedInstance] playEffect:@"die.wav"];

	[self enumerateChildNodesWithName:@"spaceship" usingBlock:^(SKNode* node, BOOL* stop) {
		// enable physics, makes spaceships drop (they will be removed by the custom behavior)
		CGFloat radius = node.frame.size.width / 4.0;
		node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
	}];
}

-(void) addSpaceshipAt:(CGPoint)location
{
	SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
	sprite.position = location;
	sprite.name = @"spaceship";
	[sprite setScale:0.5];
	[self addChild:sprite];
	
	SKAction* action = [SKAction rotateByAngle:M_PI duration:1];
	[sprite runAction:[SKAction repeatActionForever:action]];

	// this behavior will remove the node if node's position.y falls below the removeHeight
	RemoveSpaceshipBehavior* removeBehavior = [RemoveSpaceshipBehavior new];
	removeBehavior.removeHeight = -sprite.frame.size.height;
	[sprite addBehavior:removeBehavior];
}

#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/* Called when a touch begins */
	
	for (UITouch* touch in touches)
	{
		CGPoint location = [touch locationInNode:self];
        if (location.y > 200) {
            [player.physicsBody applyImpulse:CGVectorMake(4, 20)];
        }else{
		//[self addSpaceshipAt:location];
            [player runAction:[SKAction moveByX:20 y:0 duration:0.25]];
        }
	}
	
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	/* Called when a mouse click occurs */
	
	CGPoint location = [event locationInNode:self];
	[self addSpaceshipAt:location];

	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif

-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}
-(void)centerOnNode:(SKNode*)node {
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    //[node.parent setPosition:CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y)];
   
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x+100, node.parent.position.y - cameraPositionInScene.y +100);
   // NSLog(@"aha: %@",[node.parent childNodeWithName:@"map"]);
}
- (void)didSimulatePhysics
{
    [super didSimulatePhysics];
    [self centerOnNode: player];
}


@end
