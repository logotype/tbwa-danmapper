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
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * Quad type Video, supports various video formats. 
	 * @author logotype
	 * 
	 */
	public class QuadVideo extends AbstractQuad
	{
		private var video:Video;
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		
		private var _originalWidth:Number = 0;
		private var _originalHeight:Number = 0;

		public function QuadVideo()
		{
			eventProxy.addEventListener( ContentEvent.RESTART_MASTER, onRestartMasterHandler );
			eventProxy.addEventListener( ContentEvent.RESTART, onRestartHandler );
			video = new Video();

			netConnection = new NetConnection();
			netConnection.connect( null );
			
			netStream = new NetStream( netConnection );
			/*netStream.inBufferSeek = true;
			netStream.backBufferTime = 0;
			netStream.bufferTime = 0;
			netStream.bufferTimeMax = 0;*/
			netStream.useHardwareDecoder = true;
			netStream.client = {};
			netStream.client.onMetaData = onMetaDataHandler;
			netStream.addEventListener( NetStatusEvent.NET_STATUS, onNetStatusHandler, false, 0, true );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );
		}

		/**
		 * Triggered from a RESTART_MASTER event. 
		 * @param event
		 * 
		 */
		protected function onRestartMasterHandler( event:Event ):void
		{
			if( this.isMaster )
			{
				if( netStream )
					netStream.seek( 0 );
				eventProxy.dispatchEvent( new ContentEvent( ContentEvent.RESTART, this.groupID ) );
			}
		}

		/**
		 * Triggered from a RESTART event. (Master triggered slave). 
		 * @param event
		 * 
		 */
		protected function onRestartHandler( event:ContentEvent ):void
		{
			if( netStream && !this.isMaster && this.groupID == event.groupID )
				netStream.seek( 0 );
		}

		/**
		 * Triggered when stage is available. Attaches NetStream and prepares volume. (Slave is silent, Master has sound). 
		 * @param event
		 * 
		 */
		private function onAddedToStageHandler( event:Event ):void
		{
			netStream.play( this.filePath );

			video.attachNetStream( netStream );
			video.smoothing = false;
			this.addChild( video );

			if( !this.isMaster )
			{
				var soundTransform:SoundTransform = new SoundTransform( 0.5 );
				soundTransform.volume = 0;
				netStream.soundTransform = soundTransform;
			}
		}

		override protected function onRemovedFromStageHandler( event:Event ):void
		{
			super.onRemovedFromStageHandler( event );
		}

		/**
		 * Sets width and height of viewport based on video-size. 
		 * @param info
		 * 
		 */
		public function onMetaDataHandler( info:Object ):void
		{
			this._originalWidth = info.width;
			this._originalHeight = info.height;
			
			if( this.scaleToViewRect && this.viewRect )
			{
				video.width = this.viewRect.width;
				video.height = this.viewRect.height;
			}
			else
			{
				video.width = info.width;
				video.height = info.height;
			}
		}

		/**
		 * Handler method for NetStream. Restarts when video has ended. 
		 * @param event
		 * 
		 */
		private function onNetStatusHandler( event:NetStatusEvent ):void
		{
			switch( event.info.code )
			{
				case "NetStream.Play.Stop":
					if( this.isMaster )
					{
						netStream.seek( 0 );
						eventProxy.dispatchEvent( new ContentEvent( ContentEvent.RESTART, this.groupID ) );
					}
					break;
			}
		}

		override public function set viewRect( __viewRect:Rectangle ):void
		{
			this._viewRect = __viewRect;
			this.scrollRect = __viewRect;
		}

		/**
		 * Scales video to the specified view rectangle. 
		 * @param __scaleToViewRect
		 * 
		 */
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
		
		/**
		 * Cleans up, removes listeners, stops and clears the NetStream object. 
		 * 
		 */
		override public function dispose():void
		{
			if( eventProxy )
			{
				eventProxy.removeEventListener( ContentEvent.RESTART_MASTER, onRestartMasterHandler );
				eventProxy.removeEventListener( ContentEvent.RESTART, onRestartHandler );
				eventProxy = null;
			}
			
			if( video )
				video.attachNetStream( null );
			
			if( netStream )
			{
				netStream.close();
				netStream.removeEventListener( NetStatusEvent.NET_STATUS, onNetStatusHandler );
				netStream.client.onMetaData = null;
				netStream = null;
			}
			
			if( netConnection )
			{
				netConnection.close();
				netConnection = null;
			}
			
			super.dispose();
		}
	}
}
