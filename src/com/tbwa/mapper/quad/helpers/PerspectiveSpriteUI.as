/**
 * Copyright © 2012 TBWA\ Digital Arts Network
 * Authors: Victor Norgren, Mimosa Poon
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:  The above copyright
 * notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE. 
 */
package com.tbwa.mapper.quad.helpers
{
	import com.tbwa.utils.DraggableSprite;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	/**
	 * 4 Control-Points for perspective control. 
	 * @author logotype
	 * 
	 */
	public class PerspectiveSpriteUI extends Sprite
	{
		static public const CIRCLE_RADIUS:int = 10;
		static public const START_X:int = 100;
		static public const START_Y:int = 100;

		public var p1:Circle;
		public var p2:Circle;
		public var p3:Circle;
		public var p4:Circle;

		private var container:PerspectiveSprite;
		private var delayTimer:Timer;
		private var pointCloud:PointCloud;
		private var points:Vector.<Circle> = new Vector.<Circle>();

		public function PerspectiveSpriteUI( container:PerspectiveSprite, __assumedWidth:Number, __assumedHeight:Number )
		{
			this.pointCloud = PointCloud.getInstance();
			this.container = container;
			this.addEventListener( CircleEvent.UPDATE, onUpdateCircleHandler );

			p1 = new Circle( CIRCLE_RADIUS, this );
			p1.alpha = 0.4;
			p1.x = START_X;
			p1.y = START_Y;
			this.addChild( p1 );
			DraggableSprite.makeDraggable( p1, updateSprite, updateSprite );
			pointCloud.pointVector.push( p1 );
			points.push( p1 );

			p2 = new Circle( CIRCLE_RADIUS, this );
			p2.alpha = 0.4;
			p2.x = __assumedWidth + START_X;
			p2.y = START_Y;
			this.addChild( p2 );
			DraggableSprite.makeDraggable( p2, updateSprite, updateSprite );
			pointCloud.pointVector.push( p2 );
			points.push( p2 );

			p3 = new Circle( CIRCLE_RADIUS, this );
			p3.alpha = 0.4;
			p3.x = START_X;
			p3.y = __assumedHeight + START_Y;
			this.addChild( p3 );
			DraggableSprite.makeDraggable( p3, updateSprite, updateSprite );
			pointCloud.pointVector.push( p3 );
			points.push( p3 );

			p4 = new Circle( CIRCLE_RADIUS, this );
			p4.alpha = 0.4;
			p4.x = __assumedWidth + START_X;
			p4.y = __assumedHeight + START_Y;
			this.addChild( p4 );
			DraggableSprite.makeDraggable( p4, updateSprite, updateSprite );
			pointCloud.pointVector.push( p4 );
			points.push( p4 );

			delayTimer = new Timer( 1000, 1 );
			delayTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onDelayTimerCompleteHandler );

			updateSprite();

			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		public function updateDimensions( __assumedWidth:Number, __assumedHeight:Number ):void
		{
			updateSprite();
		}

		private function onUpdateCircleHandler( event:CircleEvent ):void
		{
			this.updateSprite();
		}

		protected function updateSprite():void
		{
			var i:int = 0;
			var j:int = 0;
			var length:int = this.pointCloud.pointVector.length;
			var currentCircle:Circle;
			var localPoint:Point;
			var globalPoint:Point;

			for( i; i < points.length; ++i )
			{
				currentCircle = points[ i ];
				for( j = 0; j < length; ++j )
				{
					if( currentCircle !== this.pointCloud.pointVector[ j ] && this !== this.pointCloud.pointVector[ j ].container )
					{
						if( currentCircle.hitTest.hitTestObject( this.pointCloud.pointVector[ j ].hitTest ) )
						{
							globalPoint = this.pointCloud.pointVector[ j ].localToGlobal( new Point() );
							localPoint = this.globalToLocal( globalPoint );
							currentCircle.x = localPoint.x;
							currentCircle.y = localPoint.y;
						}
					}
				}
			}

			container.topLeft = new Point( p1.x, p1.y );
			container.topRight = new Point( p2.x, p2.y );
			container.bottomLeft = new Point( p3.x, p3.y );
			container.bottomRight = new Point( p4.x, p4.y );
			container.update();
		}

		public function show():void
		{
			delayTimer.reset();
			this.visible = true;
		}

		public function hide():void
		{
			delayTimer.reset();
			delayTimer.start();
		}

		private function onDelayTimerCompleteHandler( event:TimerEvent ):void
		{
			this.visible = false;
		}

		private function onRemovedFromStageHandler( event:Event ):void
		{
			if( delayTimer )
			{
				delayTimer.reset();
				delayTimer.stop();
				delayTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, onDelayTimerCompleteHandler );
				delayTimer = null;
			}

			var i:int = 0;
			var j:int = 0;
			for( i; i < points.length; ++i )
				for( j = 0; j < this.pointCloud.pointVector.length; ++j )
					if( this.points[ i ] == this.pointCloud.pointVector[ j ] )
						this.pointCloud.pointVector.splice( j, 1 );

			while( this.points.length > 0 )
				this.removeChild( this.points.pop() );

			this.points = null;
			this.pointCloud = null;
		}
	}
}
