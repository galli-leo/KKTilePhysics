KKTilePhysics
=============
Just add #import "KKTilemapLayerContourTracer.h" to the KKTilemap.h in your KoboldKit xcode project.

Then use this code as demonstrated in MyScene.h:

<code>
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
</code>
