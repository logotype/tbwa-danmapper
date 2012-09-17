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
package com.tbwa.mapper.quad.helpers
{
	/**
	 * Contains all Quads Control-Points for snapping to nearest Point. 
	 * @author logotype
	 * 
	 */
	public class PointCloud
	{
		static private var instance:PointCloud;
		public var pointVector:Vector.<Circle> = new Vector.<Circle>();

		public function PointCloud( singletonEnforcer:SingletonEnforcer )
		{
			super();
		}

		static public function getInstance():PointCloud
		{
			if( instance == null )
				instance = new PointCloud( new SingletonEnforcer() );

			return instance;
		}
	}
}

class SingletonEnforcer
{
}