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
package com.tbwa.mapper.editor.shapes
{
	import com.tbwa.mapper.quad.helpers.Circle;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Abstract class for all shapes. 
	 * @author logotype
	 * 
	 */
	public class AbstractShape extends Sprite
	{
		public var points:Vector.<Circle> = new Vector.<Circle>();
		public var isMaster:Boolean = false;
		public var viewRect:Rectangle = new Rectangle();

		public function AbstractShape()
		{
		}
		
		public function get proportionalX():Number
		{
			throw new Error( "proportionalX not implemented" );
		}
		
		public function get proportionalY():Number
		{
			throw new Error( "proportionaly not implemented" );
		}
		
		public function get proportionalWidth():Number
		{
			throw new Error( "proportionalWidth not implemented" );
		}
		
		public function get proportionalHeight():Number
		{
			throw new Error( "proportionalHeight not implemented" );
		}
		
		public function get proportionalRectangle():Rectangle
		{
			throw new Error( "proportionalRectangle not implemented" );
		}
		
		public function get maskPoints():Vector.<Point>
		{
			return null;
		}
		
		public function get maskPointsOriginal():Vector.<Point>
		{
			return null;
		}
		
		public function get viewRectOriginal():Rectangle
		{
			return new Rectangle();
		}
	}
}