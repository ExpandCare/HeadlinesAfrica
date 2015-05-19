//
//  --------------------------------------------
//  Copyright (C) 2011 by Simon Blommegård
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  --------------------------------------------
//
//  SBDoubleSidedLayer.m
//  SBTickerView
//
//

#import "SBDoubleSidedLayer.h"

@implementation SBDoubleSidedLayer

@synthesize frontLayer = _frontLayer;
@synthesize backLayer = _backLayer;


- (id)init {
	if ((self = [super init])) {
        [self setDoubleSided:YES];
	}
	return self;
}

- (void)layoutSublayers {
	[super layoutSublayers];
	
	[_frontLayer setFrame:self.bounds];
	[_backLayer setFrame:self.bounds];
}


#pragma mark - Properties

- (void)setFrontLayer:(CALayer *)frontLayer{
	if (_frontLayer != frontLayer) {
		[_frontLayer removeFromSuperlayer];
		_frontLayer = frontLayer;
		[_frontLayer setDoubleSided:NO];
		[self addSublayer:frontLayer];
		[self setNeedsLayout];
	}
}

- (void)setBackLayer:(CALayer *)backLayer {
	if (_backLayer != backLayer) {
		[_backLayer removeFromSuperlayer];
		_backLayer = backLayer;
		[_backLayer setDoubleSided:NO];
		CATransform3D transform = CATransform3DMakeRotation(M_PI, 1., 0., 0.);
		[_backLayer setTransform:transform];
		[self addSublayer:_backLayer];
		[self setNeedsLayout];
	}
}

@end
