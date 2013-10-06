/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2013 Ian Martins (ianxm@jhu.edu)                     */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 3.0 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */

package ihx;

class TestHistory extends haxe.unit.TestCase
{
    public function testAddPrev()
    {
        var history = new History();
        history.add("one");
        history.add("two");
        history.add("three");

        assertEquals("three", history.prev());
        assertEquals("two", history.prev());
        assertEquals("one", history.prev());
        assertEquals("", history.prev());

        history.add("four");
        assertEquals("four", history.prev());
        assertEquals("three", history.prev());
        assertEquals("two", history.prev());
        assertEquals("one", history.prev());
        assertEquals("", history.prev());
    }

    public function testAddPrevWrap()
    {
        var history = new History();
        history.add("one");
        history.add("two");
        history.add("three");

        assertEquals("three", history.prev());
        assertEquals("two", history.prev());
        assertEquals("one", history.prev());
        assertEquals("", history.prev());

        assertEquals("three", history.prev());
        assertEquals("two", history.prev());
        assertEquals("one", history.prev());
        assertEquals("", history.prev());
    }

    public function testAddNextWrap()
    {
        var history = new History();
        history.add("one");
        history.add("two");
        history.add("three");

        assertEquals("one", history.next());
        assertEquals("two", history.next());
        assertEquals("three", history.next());
        assertEquals("", history.next());

        assertEquals("one", history.next());
        assertEquals("two", history.next());
        assertEquals("three", history.next());
        assertEquals("", history.next());
    }

    public function testAddPrevNext()
    {
        var history = new History();
        history.add("one");
        history.add("two");
        history.add("three");

        assertEquals("three", history.prev());
        assertEquals("two", history.prev());
        assertEquals("one", history.prev());
        assertEquals("two", history.next());
        assertEquals("three", history.next());
        assertEquals("two", history.prev());

        history.add("four");
        assertEquals("four", history.prev());
        assertEquals("three", history.prev());
        assertEquals("four", history.next());
    }
}
