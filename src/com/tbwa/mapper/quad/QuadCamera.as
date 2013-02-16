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
	import com.tbwa.mapper.ContentEvent;
	import com.tbwa.mapper.EventProxy;
	import com.tbwa.mapper.quad.AbstractQuad;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;

	/**
	 * Template class for a Quad with realtime Camera. 
	 * @author logotype
	 * 
	 */
	public class QuadCamera extends AbstractQuad
	{
		private var camera:Camera;
		private var video:Video;

		private var _originalWidth:Number = 640;
		private var _originalHeight:Number = 480;

		public function QuadCamera()
		{
			eventProxy.addEventListener( ContentEvent.RESTART_MASTER, onRestartMasterHandler );
			eventProxy.addEventListener( ContentEvent.RESTART, onRestartHandler );
			video = new Video();
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );
		}

		protected function onRestartMasterHandler( event:Event ):void
		{
			if( this.isMaster )
				eventProxy.dispatchEvent( new ContentEvent( ContentEvent.RESTART, this.groupID ) );
		}

		protected function onRestartHandler( event:ContentEvent ):void
		{
		}

		/**
		 * Triggered when stage is available, sets Camera quality and attaches to Video object. 
		 * @param event
		 * 
		 */
		private function onAddedToStageHandler( event:Event ):void
		{
			camera = Camera.getCamera();
			camera.setMode( 640, 480, 60, true );

			video.attachCamera( camera );
			video.smoothing = true;
			video.width = 640;
			video.height = 480;
			this.addChild( video );
		}

		override protected function onRemovedFromStageHandler( event:Event ):void
		{
			super.onRemovedFromStageHandler( event );
		}

		override public function set viewRect( __viewRect:Rectangle ):void
		{
			this._viewRect = __viewRect;
			this.scrollRect = __viewRect;
		}

		override public function set scaleToViewRect( __scaleToViewRect:Boolean ):void
		{
			this._scaleToViewRect = __scaleToViewRect;
			if( __scaleToViewRect && this.viewRect && this.video )
			{
				video.width = this.viewRect.width;
				video.height = this.viewRect.height;
			}
		}

		override public function get width():Number
		{
			return this._originalWidth;
		}

		override public function get height():Number
		{
			return this._originalHeight;
		}

		override public function dispose():void
		{
			if( eventProxy )
			{
				eventProxy.removeEventListener( ContentEvent.RESTART_MASTER, onRestartMasterHandler );
				eventProxy.removeEventListener( ContentEvent.RESTART, onRestartHandler );
				eventProxy = null;
			}
			
			if( video )
				video.attachCamera( null );
			
			if( camera )
				camera = null;
			
			super.dispose();
		}
	}
}
