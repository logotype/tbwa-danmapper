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
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;

	/**
	 * Circle is the class for each Control-Point. 
	 * @author logotype
	 * 
	 */
	public class Circle extends Sprite
	{
		public var container:DisplayObjectContainer;
		public var hitTest:Sprite;

		public function Circle( radius:Number, container:DisplayObjectContainer )
		{
			this.container = container;

			this.hitTest = new Sprite();
			this.addChild( this.hitTest );

			// Draw circle
			this.hitTest.graphics.lineStyle( 1, 0x5bc7e3, 0.75 );
			this.hitTest.graphics.beginFill( 0x5bc7e3, 0.5 );
			this.hitTest.graphics.drawCircle( 0, 0, radius );
			this.hitTest.graphics.endFill();

			// Draw crosshair
			this.graphics.lineStyle( 1, 0x5bc7e3, 1 );
			this.graphics.moveTo( -( radius * 3 ), 0 );
			this.graphics.lineTo( radius * 3, 0 );
			this.graphics.moveTo( 0, -( radius * 2 ) );
			this.graphics.lineTo( 0, radius * 3 );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		protected function onAddedToStageHandler( event:Event ):void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
		}

		protected function onRemovedFromStageHandler( event:Event ):void
		{
			this.container = null;
			this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		public function set point( __point:Point ):void
		{
			this.x = __point.x;
			this.y = __point.y;
			this.dispatchEvent( new CircleEvent( CircleEvent.UPDATE ) );
		}

		public function get point():Point
		{
			return new Point( this.x, this.y );
		}
	}
}
