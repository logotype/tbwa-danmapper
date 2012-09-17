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
package com.tbwa.mapper.toolbox
{
	import com.bit101.components.List;
	import com.bit101.components.ListItem;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.Preferences;
	import com.tbwa.mapper.editor.Editor;
	import com.tbwa.mapper.editor.EditorEvent;
	import com.tbwa.mapper.editor.QuadTypes;
	import com.tbwa.mapper.quad.AbstractQuad;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	/**
	 * ToolBox is the main UI for various functionality. 
	 * @author logotype
	 * 
	 */
	public class ToolBox extends Window
	{
		private var eventProxy:EventProxy;
		private var editor:Editor;
		private var libraryList:List;
		private var libraryLoader:URLLoader;
		private var file:File;

		public function ToolBox( parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "TBWA DIGITAL ARTS NETWORK - MAPPER V1.0A" )
		{
			super( parent, xpos, ypos, title );
			this.setSize( 560, 120 );
			this.hasMinimizeButton = true;
			this.filters = [ new DropShadowFilter( 0, 0, 0x000000, 1, 35, 35, 1, Preferences.UI_SHADOW_QUALITY ) ];

			eventProxy = EventProxy.getInstance();

			var button:PushButton;
			button = new PushButton( this, 10, 10, "SYNCHRONIZE", this.synchronize );
			button = new PushButton( this, 120, 10, "FULL SCREEN", this.fullscreen );
			button = new PushButton( this, 230, 10, "BROWSE", this.browseFile );
			button = new PushButton( this, 10, 40, "LOAD", this.load );
			button = new PushButton( this, 120, 40, "SAVE", this.save );

			button = new PushButton( this, 10, 70, "NEWS", this.addNews );
			button = new PushButton( this, 120, 70, "CAMERA", this.addCamera );

			button = new PushButton( this, 230, 40, "ABOUT", this.about );
			button = new PushButton( this, 230, 70, "HIDE", this.hideUI );

			
			libraryList = new List( this, 340, 10 );
			libraryList.setSize( 210, 80 );
			libraryList.addEventListener( Event.SELECT, onSelectHandler );

			loadLibrary();
		}

		/**
		 * Loads the library list (XML format) into a list. Useful for common files. 
		 * @param event
		 * 
		 */
		private function loadLibrary( event:Event = null ):void
		{
			var request:URLRequest = new URLRequest( "videos/library.xml" );

			libraryLoader = new URLLoader();
			libraryLoader.addEventListener( IOErrorEvent.IO_ERROR, onLibraryErrorHandler );
			libraryLoader.addEventListener( IOErrorEvent.DISK_ERROR, onLibraryErrorHandler );
			libraryLoader.addEventListener( Event.COMPLETE, onLibraryCompleteHandler );
			libraryLoader.load( request );
		}

		/**
		 * Parses the XML and adds item to the list. 
		 * @param event
		 * 
		 */
		private function onLibraryCompleteHandler( event:Event ):void
		{
			var xml:XML;
			var listItems:XMLList;

			try
			{
				xml = XML( event.target.data );
				listItems = xml.library..item;
			}
			catch( error:Error )
			{
				trace( "could not parse xml" );
				return;
			}

			if( !listItems )
			{
				trace( "no items..." );
				return;
			}

			for( var i:int = 0; i < listItems.length(); ++i )
				libraryList.addItem( { label:listItems[ i ].toString().toUpperCase(), file:String( listItems[ i ].@file ) } );
		}

		/**
		 * Silent error handling. 
		 * @param event
		 * 
		 */
		private function onLibraryErrorHandler( event:IOErrorEvent ):void
		{
			trace( "error!" );
		}

		/**
		 * Triggered when clicking on a list item. Displays Editor and sets correct filetype. 
		 * @param event
		 * 
		 */
		private function onSelectHandler( event:Event ):void
		{
			if( libraryList.selectedItem == null || editor )
				return;

			var contentClass:Class = getDefinitionByName( QuadTypes.QUAD_VIDEO ) as Class;
			var abstractQuad:AbstractQuad = new contentClass() as AbstractQuad;
			abstractQuad.filePath = libraryList.selectedItem[ "file" ];

			editor = new Editor( this.parent, abstractQuad, QuadTypes.QUAD_VIDEO );
			editor.x = this.stage.stageWidth - editor.width >> 1;
			editor.y = this.stage.stageHeight - editor.height >> 1;
			editor.addEventListener( Event.CLOSE, onCloseEditorHandler );

			libraryList.selectedItem = null;
		}

		/**
		 * Template item. Adds a RSS feed to the Editor. 
		 * @param event
		 * 
		 */
		private function addNews( event:MouseEvent = null ):void
		{
			var contentClass:Class = getDefinitionByName( QuadTypes.QUAD_NEWS ) as Class;
			var abstractQuad:AbstractQuad = new contentClass() as AbstractQuad;
			abstractQuad.isMaster = true;
			
			editor = new Editor( this.parent, abstractQuad, QuadTypes.QUAD_NEWS );
			editor.x = this.stage.stageWidth - editor.width >> 1;
			editor.y = this.stage.stageHeight - editor.height >> 1;
			editor.addEventListener( Event.CLOSE, onCloseEditorHandler );
		}
		
		/**
		 * Template item. Adds a Camera-enabled Quad to the Editor. 
		 * @param event
		 * 
		 */
		private function addCamera( event:MouseEvent = null ):void
		{
			var contentClass:Class = getDefinitionByName( QuadTypes.QUAD_CAMERA ) as Class;
			var abstractQuad:AbstractQuad = new contentClass() as AbstractQuad;
			abstractQuad.isMaster = true;
			
			editor = new Editor( this.parent, abstractQuad, QuadTypes.QUAD_CAMERA );
			editor.x = this.stage.stageWidth - editor.width >> 1;
			editor.y = this.stage.stageHeight - editor.height >> 1;
			editor.addEventListener( Event.CLOSE, onCloseEditorHandler );
		}
		
		/**
		 * Triggers an application-wide synchronization event (restarts all Quads). 
		 * @param event
		 * 
		 */
		private function synchronize( event:MouseEvent = null ):void
		{
			EventProxy.getInstance().dispatchEvent( new ContentEvent( ContentEvent.RESTART_MASTER ) );
		}

		/**
		 * Closes the Editor and cleans up. 
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
		 * Browses for file on local disk. 
		 * @param event
		 * 
		 */
		public function browseFile( event:MouseEvent = null ):void
		{
			file = new File();
			file.addEventListener( Event.SELECT, onFileSelectedHandler );
			file.addEventListener( Event.CANCEL, onFileCanceledHandler );

			if( !editor )
				file.browse( [ new FileFilter( "MOV/MP4 Files", "*.mov; *.mp4" ), new FileFilter( "SWF", "*.swf" ) ] );
		}

		/**
		 * Handler method for local disk files. 
		 * @param event
		 * 
		 */
		private function onFileSelectedHandler( event:Event ):void
		{
			var nativePath:String = String( event.target.nativePath );
			var extension:String = nativePath.substring( nativePath.length - 4, nativePath.length ).toLowerCase();
			var contentClass:Class;
			var abstractQuad:AbstractQuad;

			switch( extension )
			{
				case ".mov":
				case ".mp4":
					contentClass = getDefinitionByName( QuadTypes.QUAD_VIDEO ) as Class;
					abstractQuad = new contentClass() as AbstractQuad;
					abstractQuad.filePath = "file://" + String( event.target.nativePath );

					file.removeEventListener( Event.SELECT, onFileSelectedHandler );
					file = null;

					editor = new Editor( this.parent, abstractQuad, QuadTypes.QUAD_VIDEO );
					editor.x = this.stage.stageWidth - editor.width >> 1;
					editor.y = this.stage.stageHeight - editor.height >> 1;
					editor.addEventListener( Event.CLOSE, onCloseEditorHandler );
					break;
				case ".swf":
					contentClass = getDefinitionByName( QuadTypes.QUAD_SWF ) as Class;
					abstractQuad = new contentClass() as AbstractQuad;
					abstractQuad.filePath = "file://" + String( event.target.nativePath );

					file.removeEventListener( Event.SELECT, onFileSelectedHandler );
					file = null;

					editor = new Editor( this.parent, abstractQuad, QuadTypes.QUAD_SWF );
					editor.x = this.stage.stageWidth - editor.width >> 1;
					editor.y = this.stage.stageHeight - editor.height >> 1;
					editor.addEventListener( Event.CLOSE, onCloseEditorHandler );
					break;
				default:
					break;
			}
		}

		/**
		 * Remove file browser when user has cancelled. 
		 * @param event
		 * 
		 */
		private function onFileCanceledHandler( event:Event ):void
		{
			file.removeEventListener( Event.SELECT, onFileSelectedHandler );
			file = null;
		}

		/**
		 * Trigger save to disk function. 
		 * @param event
		 * 
		 */
		private function save( event:MouseEvent = null ):void
		{
			eventProxy.dispatchEvent( new EditorEvent( EditorEvent.SAVE, "null", new Rectangle() ) );
		}

		/**
		 * Trigger load from disk function. 
		 * @param event
		 * 
		 */
		private function load( event:MouseEvent = null ):void
		{
			eventProxy.dispatchEvent( new EditorEvent( EditorEvent.LOAD, "null", new Rectangle() ) );
		}

		/**
		 * Toggles fullscreen mode. 
		 * @param event
		 * 
		 */
		private function fullscreen( event:MouseEvent = null ):void
		{
			this.stage.nativeWindow.maximize();
			this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		/**
		 * Displays About view. 
		 * @param event
		 * 
		 */
		private function about( event:MouseEvent = null ):void
		{
			event.stopImmediatePropagation();
			eventProxy.dispatchEvent( new ToolBoxEvent( ToolBoxEvent.ABOUT ) );
		}
		
		/**
		 * Toggles UI. 
		 * @param event
		 * 
		 */
		private function hideUI( event:MouseEvent = null ):void
		{
			eventProxy.dispatchEvent( new ToolBoxEvent( ToolBoxEvent.UI_HIDE ) );
		}
	}
}
