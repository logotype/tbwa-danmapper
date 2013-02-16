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
package com.tbwa.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * Utility class to make objects draggable on stage. 
	 * @author logotype
	 * 
	 */
	public class DraggableSprite
	{
		protected static var dragMoveFunctions:Dictionary = new Dictionary( true );
		protected static var dragUpFunctions:Dictionary = new Dictionary( true );
		
		protected static var draggingObject:Sprite;
		protected static var draggingObjectOffset:Point;
		
		public static function makeDraggable( __sprite:Sprite, __onMouseMove:Function = null, __onMouseUp:Function = null ):void
		{
			__sprite.buttonMode = true;
			__sprite.mouseEnabled = true;
			__sprite.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownDraggableObject, false, 0, true );
			__sprite.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
			
			if( Boolean( __onMouseMove ) )
				dragMoveFunctions[ __sprite ] = __onMouseMove;
			if( Boolean( __onMouseUp ) )
				dragUpFunctions[ __sprite ] = __onMouseUp;
		}
		
		private static function onRemovedFromStageHandler( event:Event ):void
		{
			var sprite:Sprite = Sprite( event.target );
			
			sprite.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
			sprite.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDownDraggableObject );
			sprite.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMoveDraggableObject );
			sprite.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpDraggableObject );
			
			dragMoveFunctions[ event.target ] = null;
			delete dragMoveFunctions[ event.target ];
			
			dragUpFunctions[ event.target ] = null;
			delete dragUpFunctions[ event.target ];
			
			sprite = null;
		}
		
		protected static function onMouseDownDraggableObject( event:MouseEvent ):void
		{
			var sprite:Sprite = event.currentTarget as Sprite;
			draggingObject = sprite;
			draggingObjectOffset = new Point( sprite.parent.mouseX - sprite.x, sprite.parent.mouseY - sprite.y );
			
			sprite.stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMoveDraggableObject, false, 0, true );
			sprite.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUpDraggableObject, false, 0, true );
		}
		
		protected static function onMouseMoveDraggableObject( event:MouseEvent ):void
		{
			draggingObject.x = draggingObject.parent.mouseX - draggingObjectOffset.x;
			draggingObject.y = draggingObject.parent.mouseY - draggingObjectOffset.y;

			if( dragMoveFunctions[ draggingObject ] )
				dragMoveFunctions[ draggingObject ]();
		}
		
		protected static function onMouseUpDraggableObject( event:MouseEvent ):void
		{
			draggingObject.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMoveDraggableObject );
			draggingObject.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUpDraggableObject );
			
			if( dragUpFunctions[ draggingObject ] )
				dragUpFunctions[ draggingObject ]();
			
			draggingObject = null;
			draggingObjectOffset = null;
		}
	}
}