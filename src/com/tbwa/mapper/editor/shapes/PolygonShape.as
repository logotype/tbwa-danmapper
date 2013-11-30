/**
 * Copyright © 2013 TBWA\ Digital Arts Network
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
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Class for point-based Quads (unlimited points, at least a polygon).
	 * @author logotype
	 *
	 */
	public class PolygonShape extends AbstractShape
	{
		private var circle:Circle;
		private var area:Sprite;
		private var _width:int;
		private var _height:int;
		private var _viewPortWidth:Number;
		private var _viewPortHeight:Number;
		private var _contentWidth:Number;
		private var _contentHeight:Number;

		public function PolygonShape( __width:int, __height:int, __viewPortWidth:Number, __viewPortHeight:Number, __contentWidth:Number, __contentHeight:Number, __isMaster:Boolean )
		{
			_width = __width;
			_height = __height;
			_viewPortWidth = __viewPortWidth;
			_viewPortHeight = __viewPortHeight;
			_contentWidth = __contentWidth;
			_contentHeight = __contentHeight;
			this.isMaster = __isMaster;

			area = new Sprite();
			area.x = 0;
			area.y = 0;
			this.addChild( area );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		protected function onAddedToStageHandler( event:Event ):void
		{
			this.updateHandler();
			area.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );
		}

		private function onMouseDownHandler( event:MouseEvent ):void
		{
			var bounds:Rectangle = area.getBounds( area );
			this.startDrag( false, new Rectangle( -bounds.x, -bounds.y, _viewPortWidth - area.width, _viewPortHeight - area.height ));
		}

		private function onMouseUpHandler( event:MouseEvent ):void
		{
			this.stopDrag();
			this.updateHandler();
		}

		public function addPoint( point:Point = null ):void
		{
			circle = new Circle( 15, this );
			if( point )
			{
				circle.x = point.x;
				circle.y = point.y;
			}
			else
			{
				circle.x = _width * 0.5;
				circle.y = _height * 0.5;
			}
			this.points.push( circle );
			this.maskPointsOriginal.push( new Point( circle.x, circle.y ));
			DraggableSprite.makeDraggable( circle, this.updateHandler );
			this.addChild( circle );
			this.updateHandler();
		}

		private function updateHandler( event:MouseEvent = null ):void
		{
			if( this.points.length == 0 )
				return;

			area.graphics.clear();
			area.graphics.lineStyle( 1, 0x5bc7e3, 0.75 );
			area.graphics.beginFill( 0x5bc7e3, 0.5 );

			area.graphics.moveTo( this.points[ 0 ].x, this.points[ 0 ].y );

			for( var i:int = 1; i < this.points.length; ++i )
				area.graphics.lineTo( this.points[ i ].x, this.points[ i ].y );

			area.graphics.lineTo( this.points[ 0 ].x, this.points[ 0 ].y );
			area.graphics.endFill();

			this.viewRect = area.getRect( this );
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
			return this._contentWidth * ( this.viewRect.width / _viewPortWidth );
		}

		override public function get proportionalHeight():Number
		{
			return this._contentHeight * ( this.viewRect.height / _viewPortHeight );
		}

		override public function get proportionalRectangle():Rectangle
		{
			return new Rectangle( this.proportionalX, this.proportionalY, this.proportionalWidth, this.proportionalHeight );
		}

		override public function get maskPoints():Vector.<Point>
		{
			var pointVector:Vector.<Point> = new Vector.<Point>();
			var tempSortVector:Vector.<Point> = new Vector.<Point>();
			var i:int = 0;
			var minPosX:Number = 0;
			var minPosY:Number = 0;
			var tempX:Number;
			var tempY:Number;

			for( i = 0; i < this.points.length; ++i )
			{
				tempX = this._contentWidth * ( this.points[ i ].x / _viewPortWidth );
				tempY = this._contentHeight * ( this.points[ i ].y / _viewPortHeight );

				pointVector.push( new Point( tempX, tempY ));
				tempSortVector.push( new Point( tempX, tempY ));
			}

			tempSortVector.sort( sortVectorPointX );
			minPosX = tempSortVector[ 0 ].x;

			tempSortVector.sort( sortVectorPointY );
			minPosY = tempSortVector[ 0 ].y;

			for( i = 0; i < pointVector.length; ++i )
			{
				pointVector[ i ].x -= minPosX;
				pointVector[ i ].y -= minPosY;
			}

			tempSortVector = null;

			return pointVector;
		}

		override public function get maskPointsOriginal():Vector.<Point>
		{
			var pointVector:Vector.<Point> = new Vector.<Point>();
			var i:int = 0;

			for( i = 0; i < this.points.length; ++i )
				pointVector.push( new Point( this.points[ i ].x, this.points[ i ].y ));

			return pointVector;
		}

		private function sortVectorPointX( p1:Point, p2:Point ):int
		{
			return p1.x - p2.x;
		}

		private function sortVectorPointY( p1:Point, p2:Point ):int
		{
			return p1.y - p2.y;
		}

		private function onRemovedFromStageHandler( event:Event ):void
		{
			while( this.points.length > 0 )
				this.removeChild( this.points.pop());

			this.points = null;

			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
			area.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );
		}
	}
}
