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
package com.tbwa.mapper.splash
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.tbwa.mapper.Preferences;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	/**
	 * Displays logo, license and screen-resolution details. 
	 * @author logotype
	 * 
	 */
	public class Splash extends Sprite
	{
		[Embed( source = "./assets/splash.png" )]
		public var imageClass:Class;
		private var background:Bitmap;

		private var removeTimer:Timer;

		private var textField:TextField;
		private var textFormat:TextFormat;

		public function Splash()
		{
			var graphics:Graphics = this.graphics;
			graphics.beginFill( 0xf8f8f8, 1 );
			graphics.drawRect(0, 0, 600, 300 );
			graphics.endFill();
			
			this.scrollRect = new Rectangle( 0, 0, 600, 300 );
			
			var date:Date = new Date();

			textFormat = new TextFormat();
			textFormat.font = "Helvetica Bold";
			textFormat.size = 10;
			textFormat.color = 0x999999;

			var systemInfo:String = "Version 1.0. Copyright © " + date.fullYear.toString() + " TBWA\DAN Hong Kong. All rights reserved.\n\n";
			systemInfo += "System version: " + Capabilities.os + ", " + Capabilities.version + "\n";
			systemInfo += "Resolution: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + " at " + Capabilities.screenDPI + " dpi, pixel aspect ratio: " + Capabilities.pixelAspectRatio + "\n\n";

			textField = new TextField();
			textField.selectable = false;
			textField.width = 580;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = true;
			textField.text = systemInfo + "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
			textField.setTextFormat( textFormat );
			textField.antiAliasType = AntiAliasType.NORMAL;
			textField.x = 10;
			textField.y = 250;

			this.addChild( textField );

			background = new imageClass();
			this.addChild( background );
			
			removeTimer = new Timer( 17000, 1 );
			removeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onRemoveTimerCompleteHandler );

			this.filters = [ new DropShadowFilter( 0, 0, 0x000000, 1, 35, 35, 1, Preferences.UI_SHADOW_QUALITY ) ];
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		/**
		 * Triggered when stage is available. Centers itself. 
		 * @param event
		 * 
		 */
		private function onAddedToStageHandler( event:Event ):void
		{
			this.stage.addEventListener( MouseEvent.CLICK, onClickHandler );
			
			TweenLite.to( textField, 30, { y:-textField.height, ease:Linear.easeInOut, delay:2 } );

			this.x = this.stage.stageWidth - this.width >> 1;
			this.y = this.stage.stageHeight - this.height >> 1;
			removeTimer.start();
		}
		
		/**
		 * When clicking, the About view hides and removes. 
		 * @param event
		 * 
		 */
		private function onClickHandler( event:MouseEvent ) :void
		{
			onRemoveTimerCompleteHandler();
		}

		/**
		 * Fades out after timer. Hides and removes About view. 
		 * @param event
		 * 
		 */
		private function onRemoveTimerCompleteHandler( event:TimerEvent = null ):void
		{
			TweenLite.killTweensOf( textField );

			removeTimer.reset();
			removeTimer.stop();
			removeTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, onRemoveTimerCompleteHandler );
			removeTimer = null;

			TweenLite.to( this, .25, { alpha:0, onComplete:onFadeCompleteHandler } );
		}

		private function onFadeCompleteHandler():void
		{
			this.parent.removeChild( this );
		}

		private function onRemovedFromStageHandler( event:Event ):void
		{
			this.stage.removeEventListener( MouseEvent.CLICK, onClickHandler );
		}
	}
}
