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
        var cmd = new PartialCommand("abc");

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
        var cmd = new PartialCommand("abc");

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
        var cmd = new PartialCommand("abc");

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
        var cmd = new PartialCommand("abc");

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
        var cmd = new PartialCommand("abc");

        cmd.home();
        cmd.addChar("1");
        assertEquals("1abc", cmd.toString());

        cmd.end();
        cmd.addChar("2");
        assertEquals("1abc2", cmd.toString());
    }

    public function testSet()
    {
        var cmd = new PartialCommand("abc");

        cmd.set("cba");
        assertEquals("cba", cmd.toString());
    }

    public function testKillLeft()
    {
        var cmd = new PartialCommand("abcd");

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.killLeft();
        assertEquals("cd", cmd.toString());

        cmd.del();
        assertEquals("d", cmd.toString());

        cmd.killLeft();
        assertEquals("d", cmd.toString());
    }

    public function testKillRight()
    {
        var cmd = new PartialCommand("abcd");

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.killRight();
        assertEquals("ab", cmd.toString());

        cmd.backspace();
        assertEquals("a", cmd.toString());

        cmd.killRight();
        assertEquals("a", cmd.toString());
    }

    public function testYankAfterKillLeft()
    {
        var cmd = new PartialCommand("abcd");

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.killLeft();
        assertEquals("cd", cmd.toString());

        cmd.yank();
        assertEquals("abcd", cmd.toString());

        cmd.end();
        cmd.yank();
        assertEquals("abcdab", cmd.toString());

        cmd.backspace();
        assertEquals("abcda", cmd.toString());
    }

    public function testYankAfterKillRight()
    {
        var cmd = new PartialCommand("abcd");

        cmd.cursorBack();
        cmd.cursorBack();
        cmd.killRight();
        assertEquals("ab", cmd.toString());

        cmd.yank();
        assertEquals("abcd", cmd.toString());

        cmd.home();
        cmd.yank();
        assertEquals("cdabcd", cmd.toString());

        cmd.del();
        assertEquals("cdbcd", cmd.toString());
    }

    public function testYankAfterMultipleKills()
    {
        var cmd = new PartialCommand("abcd");

        cmd.cursorBack();
        cmd.killRight();
        assertEquals("abc", cmd.toString());

        cmd.cursorBack();
        cmd.killRight();
        assertEquals("ab", cmd.toString());

        cmd.yank();
        assertEquals("abc", cmd.toString());
    }

    public function testYankWithNoKill()
    {
        var cmd = new PartialCommand("abc");
        cmd.yank();
        assertEquals("abc", cmd.toString());

        cmd.cursorBack();
        cmd.yank();
        cmd.backspace();
        assertEquals("ac", cmd.toString());
    }
}
