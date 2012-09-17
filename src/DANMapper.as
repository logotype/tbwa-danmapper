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
package 
{
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.editor.Editor;
	import com.tbwa.mapper.editor.EditorEvent;
	import com.tbwa.mapper.editor.QuadTypes;
	import com.tbwa.mapper.quad.AbstractQuad;
	import com.tbwa.mapper.quad.helpers.PerspectiveSprite;
	import com.tbwa.mapper.quad.helpers.PerspectiveSpriteEvent;
	import com.tbwa.mapper.splash.Splash;
	import com.tbwa.mapper.toolbox.ToolBox;
	import com.tbwa.mapper.toolbox.ToolBoxEvent;
	import com.tbwa.utils.Base64;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;
	
	/*
	* 2012-08-16 @victor
	*
	* To build with captive runtime:
	* adt -package -storetype pkcs12 -keystore tbwahk.p12 -keypass tbwahk -target bundle DANMapper.app DANMapper-app.xml DANMapper.swf icons
	*
	* To build AIR package:
	* adt -package -storetype pkcs12 -keystore tbwahk.p12 -keypass tbwahk -target native DANMapper.air DANMapper-app.xml DANMapper.swf icons
	*
	*/

	[SWF( width = "1024", height = "768", backgroundColor = "#000000", frameRate = "60" )]
	public class DANMapper extends MovieClip
	{
		//[Embed( source = "./assets/perspective.png" )]
		//public var imageClass:Class;
		//private var background:Bitmap;

		protected var container:PerspectiveSprite;
		protected var content:AbstractQuad;
		protected var eventProxy:EventProxy;

		private var toolBox:ToolBox;
		private var displaysUI:Boolean = true;
		private var hasKeyboardShortcuts:Boolean = false;
		private var editor:Editor;

		/**
		 * Constructor. Sets up proxy listeners for various functionality. 
		 * 
		 */
		public function DANMapper()
		{
			eventProxy = EventProxy.getInstance();
			eventProxy.addEventListener( EditorEvent.ADD, onAddedQuadHandler );
			eventProxy.addEventListener( EditorEvent.EDIT, onEditedQuadHandler );
			eventProxy.addEventListener( EditorEvent.LOAD, onLoadHandler );
			eventProxy.addEventListener( EditorEvent.SAVE, onSaveHandler );
			eventProxy.addEventListener( PerspectiveSpriteEvent.UPDATE_CONTEXTMENU, onSpriteChangedHandler );
			eventProxy.addEventListener( ToolBoxEvent.ABOUT, onShowAboutHandler );
			eventProxy.addEventListener( ToolBoxEvent.UI_HIDE, onToggleUIHandler );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
		}

		/**
		 * Triggered when stage is available. Adds UI and sets fullscreen mode. 
		 * @param event
		 * 
		 */
		protected function onAddedToStageHandler( event:Event ):void
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			// Maximize window and set fullscreen
			this.stage.nativeWindow.maximize();
			this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			this.stage.addEventListener( Event.RESIZE, onResizeHandler );

			//background = new imageClass();
			//this.addChild( background );

			this.stage.doubleClickEnabled = true;
			this.stage.addEventListener( MouseEvent.DOUBLE_CLICK, onToggleUIHandler );

			toolBox = new ToolBox( this, 10, 10 );
			this.stage.addChild( toolBox );
			onResizeHandler();

			onShowAboutHandler();
			onToggleKeyboardShortcutsHandler();
		}
		
		/**
		 * Enables or disables keyboard shortcuts. 
		 * @param event
		 * 
		 */		
		private function onToggleKeyboardShortcutsHandler( event:Event = null ) :void
		{
			if( !hasKeyboardShortcuts )
			{
				// Adding keyboard shortcuts
				hasKeyboardShortcuts = true;
				this.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUpHandler );
			}
			else
			{
				// Removing keyboard shortcuts
				hasKeyboardShortcuts = false;
				this.stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUpHandler );
			}
		}
		
		/**
		 * Handler method for keyboard events. 
		 * @param event
		 * 
		 */
		private function onKeyUpHandler( event:KeyboardEvent ) :void
		{
			switch( event.keyCode )
			{
				case Keyboard.A:
					// About screen
					onShowAboutHandler();
					break;
				case Keyboard.B:
					// Browse for file
					toolBox.browseFile();
					break;
				case Keyboard.F:
					// Fullscreen
					this.stage.nativeWindow.maximize();
					this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					break;
				case Keyboard.H:
					// Toggle UI
					onToggleUIHandler();
					break;
				case Keyboard.L:
					// Load saved file
					onLoadHandler();
					break;
				case Keyboard.S:
					// Save current stage
					onSaveHandler();
					break;
				case Keyboard.R:
					// Restarts clips (synchronize)
					EventProxy.getInstance().dispatchEvent( new ContentEvent( ContentEvent.RESTART_MASTER ) );
					break;
				default:
					break;
			}
		}

		/**
		 * Shows/hides UI elements.
		 * @param event
		 * 
		 */
		protected function onToggleUIHandler( event:Event = null ):void
		{
			if( displaysUI )
			{
				displaysUI = false;
				toolBox.visible = false;
				this.stage.removeChild( toolBox );
				Mouse.hide();
			}
			else
			{
				displaysUI = true;
				toolBox.visible = true;
				this.stage.addChild( toolBox );
				Mouse.show();
			}
		}
		
		/**
		 * Displays the About-view. 
		 * @param event
		 * 
		 */
		private function onShowAboutHandler( event:Event = null ) :void
		{
			this.addChild( new Splash() );
		}

		/**
		 * Triggered when Editor dispatches a new Quad to be added. 
		 * @param event
		 * 
		 */
		private function onAddedQuadHandler( event:EditorEvent ):void
		{
			container = new PerspectiveSprite( event.viewRect.width, event.viewRect.height );
			container.quadType = event.quadType;
			container.addEventListener( MouseEvent.ROLL_OVER, onClickHandler );
			this.addChild( container );

			var contentClass:Class = getDefinitionByName( event.quadType ) as Class;
			content = new contentClass() as AbstractQuad;
			content.isMaster = event.isMaster;
			content.groupID = event.groupID;
			content.viewRect = event.viewRect;
			content.viewRectOriginal = event.viewRectOriginal;
			content.filePath = event.filePath;
			container.contentReference = content;

			if( event.maskPoints )
			{
				var maskSprite:Sprite = new Sprite();
				maskSprite.graphics.beginFill( 0xFF0000, 0.5 );
				maskSprite.graphics.moveTo( event.maskPoints[ 0 ].x, event.maskPoints[ 0 ].y );

				for( var i:int = 0; i < event.maskPoints.length; i++ )
					maskSprite.graphics.lineTo( event.maskPoints[ i ].x, event.maskPoints[ i ].y );

				maskSprite.graphics.lineTo( event.maskPoints[ 0 ].x, event.maskPoints[ 0 ].y );
				maskSprite.graphics.endFill();

				var currentChild:DisplayObject;

				currentChild = this.getChildAt( numChildren - 1 );

				if( currentChild is PerspectiveSprite )
				{
					( currentChild as PerspectiveSprite ).maskSprite = maskSprite;
					( currentChild as PerspectiveSprite ).contentReference.maskPoints = event.maskPoints;
					( currentChild as PerspectiveSprite ).contentReference.maskPointsOriginal = event.maskPointsOriginal;
				}
			}

			container.addChildAt( content, 0 );
			container.contextMenu = contextMenuHandler( container );
		}

		/**
		 * Triggered when Editor dispatches a Quad to be edited. 
		 * @param event
		 * 
		 */
		private function onEditedQuadHandler( event:EditorEvent ):void
		{
			var i:int = 0;
			var j:int = 0;
			var perspectiveSprite:PerspectiveSprite;
			var abstractQuad:AbstractQuad;

			for( i = 0; i < this.numChildren; ++i )
			{
				if( this.getChildAt( i ) is PerspectiveSprite )
				{
					perspectiveSprite = PerspectiveSprite( this.getChildAt( i ) );

					if( perspectiveSprite.contentReference == event.quad )
					{
						perspectiveSprite.updateViewRect( event.viewRect.width, event.viewRect.height );

						abstractQuad = perspectiveSprite.contentReference;
						abstractQuad.scaleToViewRect = false;
						abstractQuad.viewRect = event.viewRect;
						abstractQuad.viewRectOriginal = event.viewRectOriginal;
						
						perspectiveSprite.addChildAt( abstractQuad, 0 );
						perspectiveSprite.visible = true;
						
						if( event.maskPoints )
						{
							var maskSprite:Sprite = new Sprite();
							maskSprite.graphics.beginFill( 0xFF0000, 0.5 );
							maskSprite.graphics.moveTo( event.maskPoints[ 0 ].x, event.maskPoints[ 0 ].y );

							for( j = 0; j < event.maskPoints.length; j++ )
								maskSprite.graphics.lineTo( event.maskPoints[ j ].x, event.maskPoints[ j ].y );

							maskSprite.graphics.lineTo( event.maskPoints[ 0 ].x, event.maskPoints[ 0 ].y );
							maskSprite.graphics.endFill();

							perspectiveSprite.maskSprite = maskSprite;
							abstractQuad.maskPoints = event.maskPoints;
							abstractQuad.maskPointsOriginal = event.maskPointsOriginal;
						}
					}
				}
			}
		}

		/**
		 * Saves current stage to disk (XML format). Currently saved to desktop. 
		 * @param event
		 * 
		 */
		private function onSaveHandler( event:EditorEvent = null ):void
		{
			var currentChild:DisplayObject;
			var perspectiveSprite:PerspectiveSprite;
			var quad:AbstractQuad;

			var item:XML;
			var viewport:XML;
			var viewportoriginal:XML;
			var maskpoints:XML;
			var maskpointsoriginal:XML;
			var point:XML;
			var controlpoint:XML;
			var xml:XML = <root><map /></root>;

			var i:int = 0;
			var j:int = 0;

			var saveFile:File;
			var stream:FileStream;

			for( i = 0; i < this.numChildren; ++i )
			{
				currentChild = this.getChildAt( i );

				if( currentChild is PerspectiveSprite )
				{
					perspectiveSprite = PerspectiveSprite( currentChild );
					if( perspectiveSprite.getChildAt( 0 ) is AbstractQuad )
					{
						quad = AbstractQuad( perspectiveSprite.getChildAt( 0 ) );

						item = <item />;
						item.@x = perspectiveSprite.x;
						item.@y = perspectiveSprite.y;
						item.@type = perspectiveSprite.quadType;
						item.@filePath = Base64.encode( quad.filePath );
						item.@groupID = quad.groupID;
						item.@isMaster = quad.isMaster;

						if( quad.viewRect )
						{
							viewport = <viewport />;
							viewport.@x = quad.viewRect.x;
							viewport.@y = quad.viewRect.y;
							viewport.@width = quad.viewRect.width;
							viewport.@height = quad.viewRect.height;
							item.appendChild( viewport );
						}

						if( quad.viewRectOriginal )
						{
							viewportoriginal = <viewportoriginal />;
							viewportoriginal.@x = quad.viewRectOriginal.x;
							viewportoriginal.@y = quad.viewRectOriginal.y;
							viewportoriginal.@width = quad.viewRectOriginal.width;
							viewportoriginal.@height = quad.viewRectOriginal.height;
							item.appendChild( viewportoriginal );
						}

						controlpoint = <controlpoint />;
						controlpoint.@id = "cp1";
						controlpoint.@x = perspectiveSprite._ui.p1.x;
						controlpoint.@y = perspectiveSprite._ui.p1.y;
						item.appendChild( controlpoint );

						controlpoint = <controlpoint />;
						controlpoint.@id = "cp2";
						controlpoint.@x = perspectiveSprite._ui.p2.x;
						controlpoint.@y = perspectiveSprite._ui.p2.y;
						item.appendChild( controlpoint );

						controlpoint = <controlpoint />;
						controlpoint.@id = "cp3";
						controlpoint.@x = perspectiveSprite._ui.p3.x;
						controlpoint.@y = perspectiveSprite._ui.p3.y;
						item.appendChild( controlpoint );

						controlpoint = <controlpoint />;
						controlpoint.@id = "cp4";
						controlpoint.@x = perspectiveSprite._ui.p4.x;
						controlpoint.@y = perspectiveSprite._ui.p4.y;
						item.appendChild( controlpoint );

						if( quad.maskPoints && quad.maskPoints.length > 0 )
						{
							maskpoints = <maskpoints />;
							item.appendChild( maskpoints );

							for( j = 0; j < quad.maskPoints.length; ++j )
							{
								point = <point />;
								point.@x = quad.maskPoints[ j ].x;
								point.@y = quad.maskPoints[ j ].y;
								maskpoints.appendChild( point );
							}
						}

						if( quad.maskPointsOriginal && quad.maskPointsOriginal.length > 0 )
						{
							maskpointsoriginal = <maskpointsoriginal />;
							item.appendChild( maskpointsoriginal );

							for( j = 0; j < quad.maskPointsOriginal.length; ++j )
							{
								point = <point />;
								point.@x = quad.maskPointsOriginal[ j ].x;
								point.@y = quad.maskPointsOriginal[ j ].y;
								maskpointsoriginal.appendChild( point );
							}
						}

						xml.map.appendChild( item );
					}
				}
			}

			saveFile = File.desktopDirectory.resolvePath( "danmapper.xml" );
			stream = new FileStream();
			stream.open( saveFile, FileMode.WRITE );
			stream.writeUTFBytes( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + xml );
			stream.close();
		}

		/**
		 * Loads configuration (XML format). Currently loads from desktop.
		 * @param event
		 * 
		 */
		private function onLoadHandler( event:EditorEvent = null ):void
		{
			var file:File;
			var fileStream:FileStream;
			var xml:XML;
			var itemList:XMLList;
			var maskPoints:XMLList;
			var maskPointsOriginal:XMLList;
			var maskPointsVector:Vector.<Point> = new Vector.<Point>();
			var maskPointsOriginalVector:Vector.<Point> = new Vector.<Point>();
			var i:int = 0;
			var j:int = 0;
			var contentClass:Class;
			var currentChild:DisplayObject;
			var maskSprite:Sprite;

			file = File.desktopDirectory.resolvePath( "danmapper.xml" );

			if( !file.exists )
			{
				trace( "File doesn't exist!" );
				return;
			}

			fileStream = new FileStream();
			fileStream.open( file, FileMode.READ );

			try
			{
				xml = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
			}
			catch( error:Error )
			{
				trace( "Could not parse file!" );
				return;
			}

			fileStream.close();

			itemList = xml..item;

			for( i; i < itemList.length(); ++i )
			{
				container = new PerspectiveSprite( Number( itemList[ i ].viewport.@width ), Number( itemList[ i ].viewport.@height ) );
				container.quadType = itemList[ i ].@type;
				container.x = Number( itemList[ i ].@x );
				container.y = Number( itemList[ i ].@y );
				container.addEventListener( MouseEvent.ROLL_OVER, onClickHandler );

				container._ui.p1.point = new Point( Number( itemList[ i ]..controlpoint.( @id == "cp1" ).@x ), Number( itemList[ i ]..controlpoint.( @id == "cp1" ).@y ) );
				container._ui.p2.point = new Point( Number( itemList[ i ]..controlpoint.( @id == "cp2" ).@x ), Number( itemList[ i ]..controlpoint.( @id == "cp2" ).@y ) );
				container._ui.p3.point = new Point( Number( itemList[ i ]..controlpoint.( @id == "cp3" ).@x ), Number( itemList[ i ]..controlpoint.( @id == "cp3" ).@y ) );
				container._ui.p4.point = new Point( Number( itemList[ i ]..controlpoint.( @id == "cp4" ).@x ), Number( itemList[ i ]..controlpoint.( @id == "cp4" ).@y ) );

				this.addChild( container );

				contentClass = getDefinitionByName( String( itemList[ i ].@type ) ) as Class;
				content = new contentClass() as AbstractQuad;
				content.isMaster = String( itemList[ i ].@isMaster ) == "true" ? true : false;
				content.viewRect = new Rectangle( Number( itemList[ i ].viewport.@x ), Number( itemList[ i ].viewport.@y ), Number( itemList[ i ].viewport.@width ), Number( itemList[ i ].viewport.@height ) );
				content.viewRectOriginal = new Rectangle( Number( itemList[ i ].viewportoriginal.@x ), Number( itemList[ i ].viewportoriginal.@y ), Number( itemList[ i ].viewportoriginal.@width ), Number( itemList[ i ].viewportoriginal.@height ) );
				content.groupID = itemList[ i ].@groupID;
				content.filePath = Base64.decode( String( itemList[ i ].@filePath ) );
				container.contentReference = content;
				container.addChildAt( content, 0 );

				// Assign the contextMenu after all properties has been set (to be sure)
				container.contextMenu = contextMenuHandler( container );

				if( itemList[ i ].hasOwnProperty( "maskpoints" ) )
				{
					maskPoints = itemList[ i ].maskpoints..point;

					// Loop through xml and create temporary vector
					for( j = 0; j < maskPoints.length(); ++j )
						maskPointsVector.push( new Point( Number( maskPoints[ j ].@x ), Number( maskPoints[ j ].@y ) ) );

					if( maskPoints.length() > 0 )
					{
						maskSprite = new Sprite();
						maskSprite.graphics.beginFill( 0xFF0000, 0.5 );
						maskSprite.graphics.moveTo( maskPointsVector[ 0 ].x, maskPointsVector[ 0 ].y );

						for( j = 0; j < maskPointsVector.length; ++j )
							maskSprite.graphics.lineTo( maskPointsVector[ j ].x, maskPointsVector[ j ].y );

						maskSprite.graphics.lineTo( maskPointsVector[ 0 ].x, maskPointsVector[ 0 ].y );
						maskSprite.graphics.endFill();

						currentChild = this.getChildAt( numChildren - 1 );

						if( currentChild is PerspectiveSprite )
						{
							( currentChild as PerspectiveSprite ).maskSprite = maskSprite;
							( currentChild as PerspectiveSprite ).contentReference.maskPoints = maskPointsVector;
						}
					}

					if( itemList[ i ].hasOwnProperty( "maskpointsoriginal" ) )
					{
						maskPointsOriginal = itemList[ i ].maskpointsoriginal..point;

						for( j = 0; j < maskPointsOriginal.length(); ++j )
							maskPointsOriginalVector.push( new Point( Number( maskPointsOriginal[ j ].@x ), Number( maskPointsOriginal[ j ].@y ) ) );

						if( currentChild is PerspectiveSprite )
							( currentChild as PerspectiveSprite ).contentReference.maskPointsOriginal = maskPointsOriginalVector;
					}
				}
			}
		}
		
		/**
		 * Triggered when a Quad is moved/transformed. Updates it's context menu. 
		 * @param event
		 * 
		 */
		private function onSpriteChangedHandler( event:PerspectiveSpriteEvent ) :void
		{
			event.perspectiveSprite.contextMenu = contextMenuHandler( event.perspectiveSprite );
		}

		/**
		 * Handler method for a Quads context menu. Displays pos/size/etc as well as edit functions. 
		 * @param container
		 * @return 
		 * 
		 */
		private function contextMenuHandler( container:PerspectiveSprite ):ContextMenu
		{
			var menu:ContextMenu;
			var menuItem:ContextMenuItem;
			var caption:String;

			menu = new ContextMenu();

			// Inactive menu items
			if( container.contentReference.viewRect )
			{
				caption = "Viewport: " + Math.round( container.contentReference.viewRect.width ) + "x" + Math.round( container.contentReference.viewRect.height );
				menuItem = new ContextMenuItem( caption, false, false );
				menu.customItems.push( menuItem );

				caption = "Position: " + Math.round( container.x ) + "x" + Math.round( container.y );
				menuItem = new ContextMenuItem( caption, false, false );
				menu.customItems.push( menuItem );
			}

			caption = "Master: " + container.contentReference.isMaster;
			menuItem = new ContextMenuItem( caption, false, false );
			menu.customItems.push( menuItem );

			// Separator
			caption = "Send to back";
			menuItem = new ContextMenuItem( caption, true, true );
			menuItem.data = container;
			menuItem.keyEquivalent = "s";
			menuItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelectHandler );
			menu.customItems.push( menuItem );

			// Separator
			caption = "Edit";
			menuItem = new ContextMenuItem( caption, true, true );
			menuItem.data = container;
			menuItem.keyEquivalent = "e";
			menuItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelectHandler );
			menu.customItems.push( menuItem );

			caption = "Duplicate";
			menuItem = new ContextMenuItem( caption, false, true );
			menuItem.data = container;
			menuItem.keyEquivalent = "D";
			menuItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelectHandler );
			menu.customItems.push( menuItem );

			caption = "Delete";
			menuItem = new ContextMenuItem( caption, false, true );
			menuItem.data = container;
			menuItem.keyEquivalent = "d";
			menuItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelectHandler );
			menu.customItems.push( menuItem );

			return menu;
		}

		/**
		 * Handler function for context menu selection. 
		 * @param event
		 * 
		 */
		private function onContextMenuSelectHandler( event:ContextMenuEvent ):void
		{
			var item:ContextMenuItem = ContextMenuItem( event.target );

			switch( item.label.toLowerCase() )
			{
				case "edit":
					if( editor )
						return;
					editor = new Editor( this.parent, PerspectiveSprite( item.data ).contentReference, PerspectiveSprite( item.data ).quadType, Editor.MODE_EDIT );
					editor.x = this.stage.stageWidth - editor.width >> 1;
					editor.y = this.stage.stageHeight - editor.height >> 1;
					editor.addEventListener( Event.CLOSE, onCloseEditorHandler );
					break;
				case "duplicate":
					duplicateObject( PerspectiveSprite( item.data ) );
					break;
				case "delete":
					deleteObject( PerspectiveSprite( item.data ) );
					break;
				case "send to back":
					this.addChildAt( PerspectiveSprite( item.data ), 1 );
					break;
			}
		}

		/**
		 * Closes the Editor view. 
		 * @param event
		 * 
		 */
		private function onCloseEditorHandler( event:Event ):void
		{
			editor.removeEventListener( Event.CLOSE, onCloseEditorHandler );

			if( this.parent.contains( editor ) )
				this.parent.removeChild( editor );

			editor = null;
		}

		/**
		 * Clicking a quad moves it to front. 
		 * @param event
		 * 
		 */
		protected function onClickHandler( event:MouseEvent ):void
		{
			if( event.currentTarget is PerspectiveSprite )
				this.setChildIndex( PerspectiveSprite( event.currentTarget ), this.numChildren - 1 );
		}

		/**
		 * Removes the Quad. Cleans up (removes listeners, stops timers, etc). 
		 * @param object
		 * 
		 */
		protected function deleteObject( object:PerspectiveSprite ):void
		{
			object.removeEventListener( MouseEvent.ROLL_OVER, onClickHandler );
			object.remove();
		}

		/**
		 * Makes a copy of the selected Quad. 
		 * @param object
		 * 
		 */
		protected function duplicateObject( object:PerspectiveSprite ):void
		{
			// TODO: We dont need this block of code to be redundant!!!

			container = new PerspectiveSprite( object.contentReference.viewRect.width, object.contentReference.viewRect.height );
			container.quadType = object.quadType;
			container.addEventListener( MouseEvent.ROLL_OVER, onClickHandler );
			this.addChild( container );

			var contentClass:Class = getDefinitionByName( object.quadType ) as Class;
			content = new contentClass() as AbstractQuad;
			content.isMaster = false;
			content.groupID = object.contentReference.groupID;
			content.viewRect = object.contentReference.viewRect;
			content.filePath = object.contentReference.filePath;
			container.contentReference = content;

			if( object.contentReference.maskPoints )
			{
				var maskSprite:Sprite = new Sprite();
				maskSprite.graphics.beginFill( 0xFF0000, 0.5 );
				maskSprite.graphics.moveTo( object.contentReference.maskPoints[ 0 ].x, object.contentReference.maskPoints[ 0 ].y );

				for( var i:int = 0; i < object.contentReference.maskPoints.length; i++ )
					maskSprite.graphics.lineTo( object.contentReference.maskPoints[ i ].x, object.contentReference.maskPoints[ i ].y );

				maskSprite.graphics.lineTo( object.contentReference.maskPoints[ 0 ].x, object.contentReference.maskPoints[ 0 ].y );
				maskSprite.graphics.endFill();

				var currentChild:DisplayObject;

				currentChild = this.getChildAt( numChildren - 1 );

				if( currentChild is PerspectiveSprite )
				{
					( currentChild as PerspectiveSprite ).maskSprite = maskSprite;
					( currentChild as PerspectiveSprite ).contentReference.maskPoints = object.contentReference.maskPoints;
				}
			}

			container.addChildAt( content, 0 );
			container.contextMenu = contextMenuHandler( container );
		}

		/**
		 * Handler function for stage resize. Moves the toolbox in place. 
		 * @param event
		 * 
		 */
		private function onResizeHandler( event:Event = null ):void
		{
			toolBox.x = this.stage.stageWidth - toolBox.width >> 1;
			toolBox.y = this.stage.stageHeight - toolBox.height - 30;
		}
	}
}
