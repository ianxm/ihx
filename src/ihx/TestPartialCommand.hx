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

class TestPartialCommand extends haxe.unit.TestCase
{
    public function testAddChar()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        assertEquals("a", cmd.toString());

        cmd.addChar("b");
        assertEquals("ab", cmd.toString());

        cmd.addChar("1");
        assertEquals("ab1", cmd.toString());
    }

    public function testInsert()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.addChar("1");
        assertEquals("a1bc", cmd.toString());

        cmd.cursorForward();
        cmd.addChar("2");
        assertEquals("a1b2c", cmd.toString());

        cmd.cursorForward();
        cmd.addChar("3");
        assertEquals("a1b2c3", cmd.toString());
    }

    public function testBackspace1()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.backspace();
        assertEquals("ab", cmd.toString());

        cmd.backspace();
        assertEquals("a", cmd.toString());

        cmd.backspace();
        assertEquals("", cmd.toString());

        cmd.backspace();
        assertEquals("", cmd.toString());
    }

    public function testBackspace2()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.cursorBack();
        cmd.backspace();
        assertEquals("ac", cmd.toString());

        cmd.backspace();
        assertEquals("c", cmd.toString());

        cmd.backspace();
        assertEquals("c", cmd.toString());
    }


    public function testDel()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.del();
        assertEquals("abc", cmd.toString());

        cmd.cursorBack();
        cmd.del();
        assertEquals("ab", cmd.toString());

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.del();
        assertEquals("b", cmd.toString());

        cmd.del();
        assertEquals("", cmd.toString());

        cmd.del();
        assertEquals("", cmd.toString());
    }

    public function testHome()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.home();
        cmd.addChar("1");
        assertEquals("1abc", cmd.toString());

        cmd.end();
        cmd.addChar("2");
        assertEquals("1abc2", cmd.toString());
    }

    public function testSet()
    {
        var cmd = new PartialCommand();
        cmd.addChar("a");
        cmd.addChar("b");
        cmd.addChar("c");
        assertEquals("abc", cmd.toString());

        cmd.set("cba");
        assertEquals("cba", cmd.toString());
    }
}
