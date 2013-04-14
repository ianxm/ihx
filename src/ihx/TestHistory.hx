/*
  Copyright (c) 2009-2013, Ian Martins (ianxm@jhu.edu)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/

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
