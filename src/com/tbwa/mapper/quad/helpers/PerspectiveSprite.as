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
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.quad.AbstractQuad;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.ui.Mouse;

	/**
	 * Main class for Quad transformation. Matrix calculations for correct perspective-projection. 
	 * @author logotype
	 * 
	 */
	public class PerspectiveSprite extends Sprite
	{
		public var _ui:PerspectiveSpriteUI;
		public var topLeft:Point;
		public var topRight:Point;
		public var bottomLeft:Point;
		public var bottomRight:Point;
		public var quadType:String = "";
		public var contentReference:AbstractQuad;

		private var _assumedWidth:Number;
		private var _assumedHeight:Number;

		private var _container3d:DisplayObjectContainer;
		private var _uiRectangle:Sprite;
		private var _isMaster:Boolean = false;
		private var _maskSprite:Sprite;

		public function PerspectiveSprite( __assumedWidth:Number = 640, __assumedHeight:Number = 480, __isMaster:Boolean = false )
		{
			_assumedWidth = __assumedWidth;
			_assumedHeight = __assumedHeight;
			_isMaster = __isMaster;

			_container3d = new Sprite();
			super.addChild( _container3d );

			topLeft = new Point( 0, 0 );
			topRight = new Point( _assumedWidth, 0 );
			bottomLeft = new Point( 0, _assumedHeight );
			bottomRight = new Point( _assumedWidth, _assumedHeight );

			_ui = new PerspectiveSpriteUI( this, _assumedWidth, _assumedHeight );
			_ui.hide();
			super.addChild( _ui );

			this._uiRectangle = new Sprite();
			this._uiRectangle.visible = false;
			this.drawCheckerBoard( this._uiRectangle, _assumedWidth, _assumedHeight );

			this.addChild( _uiRectangle );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		/**
		 * Adds various listeners and triggers a RESTART event. 
		 * @param event
		 * 
		 */
		protected function onAddedToStageHandler( event:Event ):void
		{
			this.buttonMode = true;
			this.useHandCursor = true;
			_container3d.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverHandler );
			_container3d.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.addEventListener( MouseEvent.ROLL_OUT, onMouseOutHandler );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );

			EventProxy.getInstance().dispatchEvent( new ContentEvent( ContentEvent.RESTART ) );
		}

		/**
		 * Cleans up and removes listeners, removes child objects, etc. 
		 * @param event
		 * 
		 */
		protected function onRemovedFromStageHandler( event:Event ):void
		{
			if( this.contentReference )
			{
				this.contentReference.mask = null;
				this.contentReference.maskPoints = null;
			}

			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );

			_container3d.removeEventListener( MouseEvent.MOUSE_OVER, onMouseOverHandler );
			_container3d.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			this.removeEventListener( MouseEvent.ROLL_OUT, onMouseOutHandler );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpHandler );

			while( _container3d.numChildren > 0 )
				_container3d.removeChildAt( 0 );

			super.removeChild( _ui );
			super.removeChild( _container3d );

			_ui = null;
			_container3d = null;
		}

		/**
		 * Updates the viewport, redraws the checkerboard. 
		 * @param __assumedWidth
		 * @param __assumedHeight
		 * 
		 */
		public function updateViewRect( __assumedWidth:Number, __assumedHeight:Number ):void
		{
			_assumedWidth = __assumedWidth;
			_assumedHeight = __assumedHeight;

			topLeft = new Point( 0, 0 );
			topRight = new Point( _assumedWidth, 0 );
			bottomLeft = new Point( 0, _assumedHeight );
			bottomRight = new Point( _assumedWidth, _assumedHeight );

			_ui.updateDimensions( __assumedWidth, __assumedHeight );

			this.drawCheckerBoard( this._uiRectangle, _assumedWidth, _assumedHeight );
		}

		/**
		 * Draws a checkerboard which is visible when hovering (to easily see the dimensions). 
		 * @param sprite
		 * @param width
		 * @param height
		 * 
		 */
		private function drawCheckerBoard( sprite:Sprite, width:Number, height:Number ):void
		{
			var even:uint = 0x5bc7e3;
			var odd:uint = 0x000000;
			var sizeH:int = width / 10;
			var sizeV:int = height / 10;
			var nH:int = width / sizeH;
			var nV:int = height / sizeV;
			var clr:uint;
			var i:uint;
			var j:uint;

			sprite.graphics.clear();

			for( i = 0; i < nV; ++i )
			{
				even ^= odd;
				odd ^= even;
				even ^= odd;
				for( j = 0; j < nH; ++j )
				{
					clr = j & 1 ? even : odd;
					sprite.graphics.lineStyle( 0, 0, 0 );
					sprite.graphics.beginFill( clr, .15 );
					sprite.graphics.drawRect( Number( j * sizeH ), Number( i * sizeV ), sizeH, sizeV );
					sprite.graphics.endFill();
				}
			}

			sprite.graphics.lineStyle( 1, 0x5bc7e3, 1 );
			sprite.graphics.drawRect( -1, -1, width + 1, height + 1 );

		}

		protected function onMouseOverHandler( event:MouseEvent ):void
		{
			_ui.show();
			_uiRectangle.visible = true;
		}

		protected function onMouseOutHandler( event:MouseEvent ):void
		{
			_ui.hide();
			_uiRectangle.visible = false;
		}

		protected function onMouseDownHandler( event:MouseEvent ):void
		{
			Mouse.hide();
			this.startDrag( false );
		}

		protected function onMouseUpHandler( event:MouseEvent ):void
		{
			Mouse.show();
			this.stopDrag();
			EventProxy.getInstance().dispatchEvent( new PerspectiveSpriteEvent( PerspectiveSpriteEvent.UPDATE_CONTEXTMENU, this ) );
		}

		/**
		 * Draws the Quad with correct perspective. This is the core functionality of the whole application. Huge thanks to wh0 and matlab.
		 * 
		 * @see http://wonderfl.net/c/sxQJ
		 * 
		 */
		private function redrawPerspective():void
		{
			var w:Number = _assumedWidth;
			var h:Number = _assumedHeight;

			removeTransform();

			_container3d.rotationX = 0;

			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = new Point( this._assumedWidth * .5, this._assumedHeight * .5 );
			transform.perspectiveProjection = pp;

			var v:Vector.<Number> = _container3d.transform.matrix3D.rawData;
			var cx:Number = transform.perspectiveProjection.projectionCenter.x;
			var cy:Number = transform.perspectiveProjection.projectionCenter.y;
			var cz:Number = transform.perspectiveProjection.focalLength;

			v[ 12 ] = topLeft.x;
			v[ 13 ] = topLeft.y;
			v[ 0 ] = -( cx * topLeft.x * bottomLeft.y - cx * bottomLeft.x * topLeft.y - cx * topLeft.x * bottomRight.y - cx * topRight.x * bottomLeft.y + cx * bottomLeft.x * topRight.y + cx * bottomRight.x * topLeft.y + cx * topRight.x * bottomRight.y - cx * bottomRight.x * topRight.y - topLeft.x * bottomLeft.x * topRight.y + topRight.x * bottomLeft.x * topLeft.y + topLeft.x * bottomRight.x * topRight.y - topRight.x * bottomRight.x * topLeft.y + topLeft.x * bottomLeft.x * bottomRight.y - topLeft.x * bottomRight.x * bottomLeft.y - topRight.x * bottomLeft.x * bottomRight.y + topRight.x * bottomRight.x * bottomLeft.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / w;
			v[ 1 ] = -( cy * topLeft.x * bottomLeft.y - cy * bottomLeft.x * topLeft.y - cy * topLeft.x * bottomRight.y - cy * topRight.x * bottomLeft.y + cy * bottomLeft.x * topRight.y + cy * bottomRight.x * topLeft.y + cy * topRight.x * bottomRight.y - cy * bottomRight.x * topRight.y - topLeft.x * topRight.y * bottomLeft.y + topRight.x * topLeft.y * bottomLeft.y + topLeft.x * topRight.y * bottomRight.y - topRight.x * topLeft.y * bottomRight.y + bottomLeft.x * topLeft.y * bottomRight.y - bottomRight.x * topLeft.y * bottomLeft.y - bottomLeft.x * topRight.y * bottomRight.y + bottomRight.x * topRight.y * bottomLeft.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / w;
			v[ 2 ] = ( cz * topLeft.x * bottomLeft.y - cz * bottomLeft.x * topLeft.y - cz * topLeft.x * bottomRight.y - cz * topRight.x * bottomLeft.y + cz * bottomLeft.x * topRight.y + cz * bottomRight.x * topLeft.y + cz * topRight.x * bottomRight.y - cz * bottomRight.x * topRight.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / w;
			v[ 4 ] = ( cx * topLeft.x * topRight.y - cx * topRight.x * topLeft.y - cx * topLeft.x * bottomRight.y + cx * topRight.x * bottomLeft.y - cx * bottomLeft.x * topRight.y + cx * bottomRight.x * topLeft.y + cx * bottomLeft.x * bottomRight.y - cx * bottomRight.x * bottomLeft.y - topLeft.x * topRight.x * bottomLeft.y + topRight.x * bottomLeft.x * topLeft.y + topLeft.x * topRight.x * bottomRight.y - topLeft.x * bottomRight.x * topRight.y + topLeft.x * bottomRight.x * bottomLeft.y - bottomLeft.x * bottomRight.x * topLeft.y - topRight.x * bottomLeft.x * bottomRight.y + bottomLeft.x * bottomRight.x * topRight.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / h;
			v[ 5 ] = ( cy * topLeft.x * topRight.y - cy * topRight.x * topLeft.y - cy * topLeft.x * bottomRight.y + cy * topRight.x * bottomLeft.y - cy * bottomLeft.x * topRight.y + cy * bottomRight.x * topLeft.y + cy * bottomLeft.x * bottomRight.y - cy * bottomRight.x * bottomLeft.y - topLeft.x * topRight.y * bottomLeft.y + bottomLeft.x * topLeft.y * topRight.y + topRight.x * topLeft.y * bottomRight.y - bottomRight.x * topLeft.y * topRight.y + topLeft.x * bottomLeft.y * bottomRight.y - bottomLeft.x * topLeft.y * bottomRight.y - topRight.x * bottomLeft.y * bottomRight.y + bottomRight.x * topRight.y * bottomLeft.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / h;
			v[ 6 ] = -( cz * topLeft.x * topRight.y - cz * topRight.x * topLeft.y - cz * topLeft.x * bottomRight.y + cz * topRight.x * bottomLeft.y - cz * bottomLeft.x * topRight.y + cz * bottomRight.x * topLeft.y + cz * bottomLeft.x * bottomRight.y - cz * bottomRight.x * bottomLeft.y ) / ( topRight.x * bottomLeft.y - bottomLeft.x * topRight.y - topRight.x * bottomRight.y + bottomRight.x * topRight.y + bottomLeft.x * bottomRight.y - bottomRight.x * bottomLeft.y ) / h;

			// Catch the error "Invalid raw matrix. Matrix must be invertible."
			try
			{
				_container3d.transform.matrix3D.rawData = v;
			}
			catch( error:Error )
			{
				trace( "Error occured: " + error );
			}
		}

		/**
		 * Sets the DisplayObject masking. 
		 * @param _maskSprite
		 * 
		 */
		public function set maskSprite( _maskSprite:Sprite ):void
		{
			if( this._maskSprite )
			{
				this.contentReference.mask = null;

				if( this._container3d.contains( this._maskSprite ) )
					this._container3d.removeChild( this._maskSprite );

				this._maskSprite = null;
			}

			this._maskSprite = _maskSprite;
			this._container3d.addChild( this._maskSprite );
			this.contentReference.mask = this._maskSprite;
		}

		public function update():void
		{
			redrawPerspective();
		}

		public function removeTransform():void
		{
			_container3d.transform.matrix3D = null;
		}

		public function remove():void
		{
			for( var i:int = 0; i < this._container3d.numChildren; ++i )
				if( this._container3d.getChildAt( i ) is AbstractQuad )
					( this._container3d.getChildAt( i ) as AbstractQuad ).dispose();

			this.parent.removeChild( this );
		}

		override public function addChild( __child:DisplayObject ):DisplayObject
		{
			return _container3d.addChild( __child );
		}

		override public function addChildAt( __child:DisplayObject, __index:int ):DisplayObject
		{
			return _container3d.addChildAt( __child, __index );
		}

		override public function getChildAt( __index:int ):DisplayObject
		{
			return _container3d.getChildAt( __index );
		}

		override public function getChildByName( __name:String ):DisplayObject
		{
			return _container3d.getChildByName( __name );
		}

		override public function getChildIndex( __child:DisplayObject ):int
		{
			return _container3d.getChildIndex( __child );
		}

		override public function removeChild( __child:DisplayObject ):DisplayObject
		{
			return _container3d.removeChild( __child );
		}

		override public function removeChildAt( __index:int ):DisplayObject
		{
			return _container3d.removeChildAt( __index );
		}

		override public function setChildIndex( __child:DisplayObject, __index:int ):void
		{
			_container3d.setChildIndex( __child, __index );
		}

		override public function swapChildren( __child1:DisplayObject, __child2:DisplayObject ):void
		{
			_container3d.swapChildren( __child1, __child2 );
		}

		override public function swapChildrenAt( __index1:int, __index2:int ):void
		{
			_container3d.swapChildrenAt( __index1, __index2 );
		}

		override public function get numChildren():int
		{
			var returnValue:int = 0;
			
			if( _container3d )
				returnValue = _container3d.numChildren;
			
			return returnValue;
		}
	}
}
