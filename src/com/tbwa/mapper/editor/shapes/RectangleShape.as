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
package com.tbwa.mapper.editor.shapes
{
	import com.tbwa.mapper.quad.helpers.Circle;
	import com.tbwa.utils.DraggableSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * Class for a simple rectangle shape Quad. 
	 * @author logotype
	 * 
	 */
	public class RectangleShape extends AbstractShape
	{
		public var circle:Circle;
		private var area:Sprite;
		private var onMouseMoveHandler:Function;
		private var _width:int;
		private var _height:int;
		private var _viewPortWidth:Number;
		private var _viewPortHeight:Number;
		private var _contentWidth:Number;
		private var _contentHeight:Number;

		public function RectangleShape( __width:int, __height:int, __viewPortWidth:Number, __viewPortHeight:Number, __contentWidth:Number, __contentHeight:Number, __isMaster:Boolean )
		{
			_width = __width;
			_height = __height;
			_contentWidth = __contentWidth;
			_contentHeight = __contentHeight;
			_viewPortWidth = __viewPortWidth;
			_viewPortHeight = __viewPortHeight;
			isMaster = __isMaster;

			circle = new Circle( 15, this );
			circle.x = _width;
			circle.y = _height;
			DraggableSprite.makeDraggable( circle, this.updateHandler );
			this.addChild( circle );

			area = new Sprite();
			this.addChild( area );

			this.area.addEventListener( MouseEvent.RIGHT_CLICK, onRightClickHandler );
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		protected function onAddedToStageHandler( event:Event ):void
		{
			area.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );
			this.updateHandler();
		}

		private function onMouseDownHandler( event:MouseEvent ):void
		{
			this.startDrag( false, new Rectangle( 0, 0, _viewPortWidth - area.width, _viewPortHeight - area.height ) );
		}

		private function onMouseUpHandler( event:MouseEvent ):void
		{
			this.stopDrag();
			this.updateHandler();
		}
		
		public function updateRectangle( rectangle:Rectangle ) :void
		{
			this.circle.x = rectangle.width;
			this.circle.y = rectangle.height;
			this.x = rectangle.x;
			this.y = rectangle.y;
			updateHandler();
		}

		private function updateHandler( event:MouseEvent = null ):void
		{
			var tempWidth:int;
			var tempHeight:int;

			if( circle.x > _viewPortWidth - this.x )
			{
				tempWidth = _viewPortWidth - this.x;
				circle.x = _viewPortWidth - this.x;
			}
			else
			{
				tempWidth = area.x + circle.x;
			}

			if( circle.y > _viewPortHeight - this.y )
			{
				tempHeight = _viewPortHeight - this.y;
				circle.y = _viewPortHeight - this.y;
			}
			else
			{
				tempHeight = area.y + circle.y;
			}

			this.viewRect = new Rectangle( this.x, this.y, tempWidth, tempHeight );
			area.graphics.clear();
			area.graphics.lineStyle( 1, 0x5bc7e3, 0.75 );
			area.graphics.beginFill( 0x5bc7e3, 0.5 );
			area.graphics.drawRect( 0, 0, this.viewRect.width, this.viewRect.height );
		}
		
		override public function get viewRectOriginal():Rectangle
		{
			return this.viewRect;
		}
		
		override public function get proportionalX():Number
		{
			return this._contentWidth * ( this.viewRect.x / _viewPortWidth );
		}
		
		override public function get proportionalY():Number
		{
			return this._contentHeight * ( this.viewRect.y / _viewPortHeight );
		}
		
		override public function get proportionalWidth():Number
		{
			return this._contentWidth * ( circle.x / _viewPortWidth );
		}
		
		override public function get proportionalHeight():Number
		{
			return this._contentHeight * ( circle.y / _viewPortHeight );
		}
		
		override public function get proportionalRectangle():Rectangle
		{
			return new Rectangle( this.proportionalX, this.proportionalY, this.proportionalWidth, this.proportionalHeight );
		}

		private function onRemovedFromStageHandler( event:Event ):void
		{
			while( this.points.length > 0 )
				this.points.pop();
			
			this.points = null;
			
			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
			area.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );
		}

		private function onRightClickHandler( event:MouseEvent ):void
		{
			this.dispatchEvent( new AbstractShapeEvent( AbstractShapeEvent.REMOVE ) );
			this.parent.removeChild( this );
		}
	}
}
