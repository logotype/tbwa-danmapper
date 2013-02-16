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
	import com.tbwa.mapper.quad.AbstractQuad;

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Events triggered from the Editor. Contains all metadata to create/edit Quads. 
	 * @author logotype
	 * 
	 */
	public class EditorEvent extends Event
	{
		static public const ADD:String = "add";
		static public const EDIT:String = "edit";
		static public const LOAD:String = "load";
		static public const SAVE:String = "save";
		static public const UPDATE_VIEWRECT:String = "updateViewRect";

		public var quadType:String;
		public var viewRect:Rectangle;
		public var isMaster:Boolean;
		public var groupID:String;
		public var filePath:String;
		public var maskPoints:Vector.<Point>;
		public var maskPointsOriginal:Vector.<Point>;
		public var viewRectOriginal:Rectangle;
		public var quad:AbstractQuad;

		public function EditorEvent( type:String, quadType:String, viewRect:Rectangle, isMaster:Boolean = false, groupID:String = "", filePath:String = "", maskPoints:Vector.<Point> = null, maskPointsOriginal:Vector.<Point> = null, viewRectOriginal:Rectangle = null, quad:AbstractQuad = null )
		{
			this.quadType = quadType;
			this.viewRect = viewRect;
			this.isMaster = isMaster;
			this.groupID = groupID;
			this.filePath = filePath;
			this.maskPoints = maskPoints;
			this.maskPointsOriginal = maskPointsOriginal;
			this.viewRectOriginal = viewRectOriginal;
			this.quad = quad;
			super( type, true, false );
		}
	}
}
