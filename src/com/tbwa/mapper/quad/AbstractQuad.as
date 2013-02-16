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
	import com.tbwa.mapper.EventProxy;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Abstract Quad for all subclass-Quads.
	 * <p><code>maskPoints</code> is the points for masking the object (currently sharp corners, bezier curves are planned).</p>
	 * <p><code>groupID</code> is a generated string for master/slave synchronization.</p>
	 * <p><code>viewRect</code> is position and dimensions of the quads viewport.</p>
	 * <p><code>scaleToViewRect</code> scales the content (to fit in the Editor).</p>
	 * @author logotype
	 * 
	 */
	public class AbstractQuad extends MovieClip
	{
		public var isMaster:Boolean = false;
		public var filePath:String = "";
		public var maskPoints:Vector.<Point>;
		public var maskPointsOriginal:Vector.<Point>;
		public var viewRectOriginal:Rectangle;

		protected var _groupID:String;
		protected var _viewRect:Rectangle;
		protected var _scaleToViewRect:Boolean = false;
		protected var eventProxy:EventProxy;

		public function AbstractQuad()
		{
			eventProxy = EventProxy.getInstance();
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
		}

		protected function onRemovedFromStageHandler( event:Event ):void
		{
		}

		public function set viewRect( __viewRect:Rectangle ):void
		{
			this._viewRect = __viewRect;
		}

		public function get viewRect():Rectangle
		{
			return this._viewRect;
		}

		public function set scaleToViewRect( __scaleToViewRect:Boolean ):void
		{
			this._scaleToViewRect = __scaleToViewRect;
		}

		public function get scaleToViewRect():Boolean
		{
			return this._scaleToViewRect;
		}

		public function set groupID( __groupID:String ):void
		{
			this._groupID = __groupID;
		}
		
		public function get groupID():String
		{
			return this._groupID;
		}
		
		public function dispose() :void
		{
			this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler );
			eventProxy = null;
		}
	}
}
