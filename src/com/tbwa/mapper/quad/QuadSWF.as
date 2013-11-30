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
	import com.tbwa.mapper.editor.EditorEvent;
	import com.tbwa.mapper.editor.QuadTypes;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	/**
	 * Quad type SWF.
	 * @author logotype
	 *
	 */
	public class QuadSWF extends AbstractQuad
	{
		private var loader:Loader;
		private var hasLoaded:Boolean = false;
		private var originalWidth:Number = 0;
		private var originalHeight:Number = 0;

		public function QuadSWF()
		{
			this.mouseChildren = false;

			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorHandler );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderCompleteHandler );

			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStageHandler );
		}

		/**
		 * Triggered when stage is available. Loads the specified SWF.
		 * @param event
		 *
		 */
		private function onAddedToStageHandler( event:Event ):void
		{
			if( !loader )
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorHandler );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderCompleteHandler );
			}
			var request:URLRequest = new URLRequest( this.filePath );
			loader.load( request );
		}

		/**
		 * Triggered when SWF has loaded, gets original dimensions, scales to specified view rectangle.
		 * @param event
		 *
		 */
		protected function onLoaderCompleteHandler( event:Event ):void
		{
			this.addChild( loader );

			// Get original SWF dimensions (LoaderInfo.width/height)
			this.originalWidth = event.target.width;
			this.originalHeight = event.target.height;

			hasLoaded = true;

			this.scaleToViewRect = this._scaleToViewRect;
		}

		/**
		 * Silent error handling.
		 * @param event
		 *
		 */
		protected function onLoaderErrorHandler( event:IOErrorEvent ):void
		{
			trace( "Failed to load QuadSWF content!" );
		}

		override public function set viewRect( __viewRect:Rectangle ):void
		{
			this._viewRect = __viewRect;
			this.scrollRect = __viewRect;
		}

		/**
		 * Scales the SWF to the specified view rectangle.
		 * @param __scaleToViewRect
		 *
		 */
		override public function set scaleToViewRect( __scaleToViewRect:Boolean ):void
		{
			this._scaleToViewRect = __scaleToViewRect;

			if( !hasLoaded )
				return;

			var aspectRatio:Number;
			var viewRectWidth:Number;
			var viewRectHeight:Number;
			if( __scaleToViewRect && this.viewRect && this.loader )
			{
				if( originalWidth < originalHeight )
				{
					aspectRatio = originalHeight / originalWidth;
					viewRectWidth = this.viewRect.width;
					viewRectHeight = this.viewRect.width * aspectRatio;
					loader.scaleX = ( this.viewRect.width ) / originalWidth;
					loader.scaleY = ( this.viewRect.width * aspectRatio ) / originalHeight;
				}
				else
				{
					aspectRatio = originalWidth / originalHeight;
					viewRectWidth = this.viewRect.height * aspectRatio;
					viewRectHeight = this.viewRect.height;
					loader.scaleX = ( this.viewRect.height * aspectRatio ) / originalWidth;
					loader.scaleY = this.viewRect.height / originalHeight;
				}
			}
			this.eventProxy.dispatchEvent( new EditorEvent( EditorEvent.UPDATE_VIEWRECT, QuadTypes.QUAD_SWF, new Rectangle( 0, 0, viewRectWidth, viewRectHeight )));
		}

		override public function get width():Number
		{
			return originalWidth;
		}

		override public function get height():Number
		{
			return originalHeight;
		}

		override protected function onRemovedFromStageHandler( event:Event ):void
		{
			super.onRemovedFromStageHandler( event );
		}

		/**
		 * Cleans up, unloads the SWF and removes listeners.
		 *
		 */
		override public function dispose():void
		{
			if( loader )
			{
				if( this.contains( loader ))
					this.removeChild( loader );

				loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderErrorHandler );
				loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderCompleteHandler );
				loader.unloadAndStop( true );
				loader = null;
			}

			super.dispose();
		}
	}
}
