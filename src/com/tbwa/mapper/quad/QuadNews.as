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
package com.tbwa.mapper.quad
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.quad.AbstractQuad;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * Template class for a RSS newsfeed. 
	 * @author logotype
	 * 
	 */
	public class QuadNews extends AbstractQuad
	{
		public static const URL:String = "http://www.standardchartered.com/en/rss/financial.xml";
		public static const DIN_NEXT_LT_PRO:String = "DINNextLTPro";
		public static const ANIMATION_TIME:int = 60;

		[Embed( source = "/../assets/quadnews/background.png" )]
		public var backgroundImageClass:Class;

		//[Embed( source = './assets/quadnews/DINNextLTPro-Light.otf', fontWeight = 'light', fontName = 'DINNextLTPro', mimeType = 'application/x-font', advancedAntiAliasing = 'false' )]
		//private var newsFont:Class;

		protected var loader:URLLoader;
		protected var content:XML;
		protected var itemList:XMLList;
		protected var textField:TextField;

		public function QuadNews()
		{
			var css:String = "h1 { font-family: 'DINNextLTPro'; font-size: 40px; color: #62B651; letter-spacing: -3px; }" + "p { font-family: 'DINNextLTPro'; font-size: 15px; color: #FFFFFF }";
			var style:StyleSheet = new StyleSheet();
			style.parseCSS( css );

			textField = new TextField();
			textField.x = 30;
			textField.width = 640 - 60;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = true;
			textField.multiline = true;
			textField.selectable = false;
			textField.antiAliasType = AntiAliasType.NORMAL;
			textField.styleSheet = style;

			eventProxy.addEventListener( ContentEvent.RESTART_MASTER, onRestartMasterHandler );
			eventProxy.addEventListener( ContentEvent.RESTART, onRestartHandler );
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
		}

		protected function onRestartMasterHandler( event:Event ):void
		{
			if( this.isMaster )
				startAnimation();
		}
		
		protected function onRestartHandler( event:ContentEvent ):void
		{
			if( !this.isMaster && event.groupID == this.groupID )
			{
				TweenLite.killTweensOf( this );
				textField.y = 640;
				TweenLite.to( textField, ANIMATION_TIME, { y:-textField.height, ease:Linear.easeInOut } );
			}
		}

		protected function onAddedToStageHandler( event:Event ):void
		{
			var bitmap:Bitmap = new backgroundImageClass();
			this.addChildAt( bitmap, 0 );

			var request:URLRequest = new URLRequest( URL );

			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, onLoaderCompleteHandler );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorHandler );
			loader.load( request );
		}

		override protected function onRemovedFromStageHandler( event:Event ):void
		{
			super.onRemovedFromStageHandler( event );
		}

		protected function onLoaderCompleteHandler( event:Event ):void
		{
			try
			{
				content = XML( event.target.data );
				itemList = content.channel..item;
			}
			catch( error:Error )
			{
				trace( "Error parsing data!" );
			}

			var i:int = 0;
			var length:int = itemList.length();
			
			for( i; i < length; ++i )
				textField.htmlText += "<h1>" + itemList[ i ].title + "</h1><p>" + itemList[ i ].description + "</p>\n\n";
			
			this.addChild( textField );
			startAnimation();
		}

		protected function onLoaderErrorHandler( event:IOErrorEvent ):void
		{
			trace( "error" );
		}

		private function startAnimation():void
		{
			textField.y = 640;
			if( this.isMaster )
			{
				TweenLite.to( textField, ANIMATION_TIME, { y:-textField.height, ease:Linear.easeInOut, onComplete:startAnimation } );
				EventProxy.getInstance().dispatchEvent( new ContentEvent( ContentEvent.RESTART, this.groupID ) );
			}
		}

		override public function set viewRect( __viewRect:Rectangle ):void
		{
			this.scrollRect = __viewRect;
		}
		
		override public function dispose() :void
		{
			TweenLite.killTweensOf( this );
			
			if( eventProxy )
			{
				eventProxy.removeEventListener( ContentEvent.RESTART, onRestartHandler );
				eventProxy = null;
			}
			
			if( loader )
			{
				itemList = null;
				content = null;
				loader.close();
				loader.removeEventListener( Event.COMPLETE, onLoaderCompleteHandler );
				loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorHandler );
				loader = null;
			}
		}
	}
}
