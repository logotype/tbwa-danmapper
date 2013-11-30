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
package com.tbwa.mapper.editor
{
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.Preferences;
	import com.tbwa.mapper.editor.shapes.AbstractShape;
	import com.tbwa.mapper.editor.shapes.AbstractShapeEvent;
	import com.tbwa.mapper.editor.shapes.PolygonShape;
	import com.tbwa.mapper.editor.shapes.RectangleShape;
	import com.tbwa.mapper.quad.AbstractQuad;
	import com.tbwa.mapper.quad.helpers.PerspectiveSprite;

	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	/**
	 * Main class for Editor. Create polys/rectangles and so on. 
	 * @author logotype
	 * 
	 */
	public class Editor extends Window
	{
		static public const MODE_NEW:String = "modeNew";
		static public const MODE_EDIT:String = "modeEdit";

		public var VIEWRECT_WIDTH:int = 927;
		public var VIEWRECT_HEIGHT:int = 465;

		[Embed( source = "/../assets/grid.png" )]
		public var imageClass:Class;
		private var grid:Bitmap;

		private var editRectangle:AbstractShape;
		private var shapes:Vector.<AbstractShape> = new Vector.<AbstractShape>();
		private var eventProxy:EventProxy;

		private var abstractQuad:AbstractQuad;
		private var quadType:String;

		private var mode:String;

		// Buttons
		private var quadButton:PushButton;
		private var quadHalfWidthButton:PushButton;
		private var quadHalfHeightButton:PushButton;
		private var polyButton:PushButton;
		private var polyDoneButton:PushButton;
		private var saveButton:PushButton;
		private var syncButton:PushButton;

		public function Editor( parent:DisplayObjectContainer, _abstractQuad:AbstractQuad, _quadType:String, _mode:String = Editor.MODE_NEW, xpos:Number = 0, ypos:Number = 0, title:String = "QUAD EDITOR" )
		{
			super( parent, xpos, ypos, title );
			this.setSize( VIEWRECT_WIDTH, VIEWRECT_HEIGHT + 90 );
			this.hasMinimizeButton = true;
			this.hasCloseButton = true;
			this.addEventListener( AbstractShapeEvent.REMOVE, onRemoveRectangleHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );

			eventProxy = EventProxy.getInstance();
			eventProxy.addEventListener( EditorEvent.UPDATE_VIEWRECT, onUpdateViewRectHandler );

			quadType = _quadType;
			abstractQuad = _abstractQuad;
			mode = _mode;

			switch( mode )
			{
				case Editor.MODE_NEW:
					initializeNew();
					break;
				case Editor.MODE_EDIT:
					initializeEdit();
					break;
			}

			this.filters = [ new DropShadowFilter( 0, 0, 0x000000, 1, 35, 35, 1, Preferences.UI_SHADOW_QUALITY ) ];
		}

		/**
		 * Sets mode to NEW (creating new quads). 
		 * 
		 */
		private function initializeNew():void
		{
			abstractQuad.viewRect = new Rectangle( 0, 0, VIEWRECT_WIDTH, VIEWRECT_HEIGHT );
			abstractQuad.scaleToViewRect = true;
			abstractQuad.isMaster = true;
			this.addChild( abstractQuad );

			grid = new imageClass();
			grid.alpha = .25;
			this.addChild( grid );

			syncButton = new PushButton( this, 10, 505, "SYNCHRONIZE", this.synchronize );
			saveButton = new PushButton( this, 817, 475, "SAVE", this.saveAndClose );

			if( mode == Editor.MODE_NEW )
			{
				quadButton = new PushButton( this, 10, 475, "ADD QUAD", this.addRectangle );
				quadHalfWidthButton = new PushButton( this, 120, 475, "SPLIT WIDTH", this.splitWidth );
				quadHalfHeightButton = new PushButton( this, 230, 475, "SPLIT HEIGHT", this.splitHeight );

				polyButton = new PushButton( this, 120, 505, "ADD POLY", this.addPoly );
				polyDoneButton = new PushButton( this, 230, 505, "DONE", this.addPolyDone );
				polyDoneButton.visible = false;
			}
		}

		/**
		 * Sets mode to EDIT (when editing existing quads). 
		 * 
		 */
		private function initializeEdit():void
		{
			this.addChild( abstractQuad );

			grid = new imageClass();
			grid.alpha = .25;
			this.addChild( grid );

			syncButton = new PushButton( this, 10, 505, "SYNCHRONIZE", this.synchronize );
			saveButton = new PushButton( this, 817, 475, "SAVE", this.saveAndClose );

			quadButton = new PushButton( this, 10, 475, "ADD QUAD", this.addRectangle );
			quadHalfWidthButton = new PushButton( this, 120, 475, "SPLIT WIDTH", this.splitWidth );
			quadHalfHeightButton = new PushButton( this, 230, 475, "SPLIT HEIGHT", this.splitHeight );

			polyButton = new PushButton( this, 120, 505, "ADD POLY", this.addPoly );
			polyDoneButton = new PushButton( this, 230, 505, "DONE", this.addPolyDone );
			polyDoneButton.visible = false;

			if( abstractQuad.maskPointsOriginal )
			{
				editRectangle = new PolygonShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, true );

				for( var i:int = 0; i < abstractQuad.maskPointsOriginal.length; ++i )
					( editRectangle as PolygonShape ).addPoint( new Point( abstractQuad.maskPointsOriginal[ i ].x, abstractQuad.maskPointsOriginal[ i ].y ) );

				this.addChild( editRectangle );
				this.shapes.push( editRectangle );
			}

			if( abstractQuad.viewRectOriginal && !abstractQuad.maskPoints )
			{
				editRectangle = new RectangleShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, abstractQuad.isMaster );
				( editRectangle as RectangleShape ).updateRectangle( abstractQuad.viewRectOriginal );
				this.addChild( editRectangle );
				this.shapes.push( editRectangle );
			}

			abstractQuad.viewRect = new Rectangle( 0, 0, VIEWRECT_WIDTH, VIEWRECT_HEIGHT );
			abstractQuad.scaleToViewRect = true;
			abstractQuad.mask = null;
		}

		private function onUpdateViewRectHandler( event:EditorEvent ):void
		{
			VIEWRECT_WIDTH = event.viewRect.width;
			VIEWRECT_HEIGHT = event.viewRect.height;

			abstractQuad.viewRect = new Rectangle( 0, 0, VIEWRECT_WIDTH, VIEWRECT_HEIGHT );

			if( grid )
				grid.scrollRect = event.viewRect;
		}

		private function synchronize( event:MouseEvent = null ):void
		{
			EventProxy.getInstance().dispatchEvent( new ContentEvent( ContentEvent.RESTART_MASTER ) );
		}

		private function addRectangle( event:MouseEvent = null ):void
		{
			var isMaster:Boolean = ( this.shapes.length == 0 ) ? true : false;
			editRectangle = new RectangleShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, isMaster );
			this.addChild( editRectangle );
			this.shapes.push( editRectangle );
		}

		private function splitWidth( event:MouseEvent = null ):void
		{
			// Left
			editRectangle = new RectangleShape( VIEWRECT_WIDTH * .5, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, true );
			this.addChild( editRectangle );
			this.shapes.push( editRectangle );

			// Right
			editRectangle = new RectangleShape( VIEWRECT_WIDTH * .5, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, false );
			editRectangle.x = ( abstractQuad.viewRect.width * .5 );
			this.addChild( editRectangle );
			this.shapes.push( editRectangle );
		}

		private function splitHeight( event:MouseEvent = null ):void
		{
			// Top
			editRectangle = new RectangleShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT * .5, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, true );
			this.addChild( editRectangle );
			this.shapes.push( editRectangle );

			// Bottom
			editRectangle = new RectangleShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT * .5, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, false );
			editRectangle.y = ( abstractQuad.viewRect.height * .5 );
			this.addChild( editRectangle );
			this.shapes.push( editRectangle );
		}

		private function addPoly( event:MouseEvent = null ):void
		{
			if( !editRectangle || !( editRectangle is PolygonShape ) )
			{
				quadButton.visible = false;
				quadHalfWidthButton.visible = false;
				quadHalfHeightButton.visible = false;
				polyButton.label = "ADD POINT";
				saveButton.visible = false;
				polyDoneButton.visible = true;

				editRectangle = new PolygonShape( VIEWRECT_WIDTH, VIEWRECT_HEIGHT, VIEWRECT_WIDTH, VIEWRECT_HEIGHT, abstractQuad.width, abstractQuad.height, true );

				// Create default polygon
				( editRectangle as PolygonShape ).addPoint( new Point( VIEWRECT_WIDTH * .5 - 200, VIEWRECT_HEIGHT * .5 - 200 ) );
				( editRectangle as PolygonShape ).addPoint( new Point( VIEWRECT_WIDTH * .5 + 200, VIEWRECT_HEIGHT * .5 - 200 ) );
				( editRectangle as PolygonShape ).addPoint( new Point( VIEWRECT_WIDTH * .5, VIEWRECT_HEIGHT * .5 + 200 ) );

				this.addChild( editRectangle );
				this.shapes.push( editRectangle );
			}
			else
			{
				( editRectangle as PolygonShape ).addPoint();
			}
		}

		private function addPolyDone( event:MouseEvent = null ):void
		{
			quadButton.visible = true;
			quadHalfWidthButton.visible = true;
			quadHalfHeightButton.visible = true;
			polyButton.label = "ADD POLY";
			polyDoneButton.visible = false;
			saveButton.visible = true;
		}

		private function onRemoveRectangleHandler( event:AbstractShapeEvent ):void
		{
			if( !( event.target is AbstractShape ) )
				return;

			var i:int = 0;
			for( i; i < this.shapes.length; ++i )
				if( this.shapes[ i ] == event.target )
					this.shapes.splice( i, 1 );
		}

		private function onRemovedFromStageHandler( event:Event ):void
		{
			if( this.contains( abstractQuad ) )
				abstractQuad.parent.removeChild( abstractQuad );

			// If edit mode, don't dispose the quad (it's reused)
			if( mode == Editor.MODE_NEW )
				this.abstractQuad.dispose();

			this.abstractQuad = null;

			while( this.shapes.length > 0 )
				this.shapes.pop();

			this.shapes = null;

			eventProxy.removeEventListener( EditorEvent.UPDATE_VIEWRECT, onUpdateViewRectHandler );
			eventProxy = null;
		}

		/**
		 * Loops through all created Quads, dispatches EditorEvents to create and add them to stage. 
		 * @param event
		 * 
		 */
		private function saveAndClose( event:MouseEvent = null ):void
		{
			var i:int = 0;
			var j:int = 0;
			var groupID:String;

			if( this.shapes.length > 0 )
				groupID = generateRandomString();
			else
				groupID = null;

			switch( mode )
			{
				case Editor.MODE_NEW:
					for( i = 0; i < this.shapes.length; ++i )
						EventProxy.getInstance().dispatchEvent( new EditorEvent( EditorEvent.ADD, quadType, this.shapes[ i ].proportionalRectangle, this.shapes[ i ].isMaster, groupID, abstractQuad.filePath, this.shapes[ i ].maskPoints, this.shapes[ i ].maskPointsOriginal, this.shapes[ i ].viewRectOriginal ) );
					break;

				case Editor.MODE_EDIT:
					for( i = 0; i < this.shapes.length; ++i )
						EventProxy.getInstance().dispatchEvent( new EditorEvent( EditorEvent.EDIT, quadType, this.shapes[ i ].proportionalRectangle, this.shapes[ i ].isMaster, groupID, abstractQuad.filePath, this.shapes[ i ].maskPoints, this.shapes[ i ].maskPointsOriginal, this.shapes[ i ].viewRectOriginal, abstractQuad ) );
					break;
			}
			this.dispatchEvent( new Event( Event.CLOSE, true, true ) );
		}

		/**
		 * Handler method for creating a unique ID for master/slave synchronization groups. 
		 * @return 
		 * 
		 */
		private function generateRandomString():String
		{
			var a:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var alphabet:Array = a.split( "" );
			var randomLetter:String = "";
			var i:int = 0;

			for( i; i < 32; ++i )
				randomLetter += alphabet[ Math.floor( Math.random() * alphabet.length ) ];

			return randomLetter;
		}
	}
}
