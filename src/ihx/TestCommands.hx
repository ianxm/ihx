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

import ihx.CmdProcessor;

class TestCommands extends haxe.unit.TestCase
{
    public function testDir()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("one", ret);
        ret = proc.process("var b='two'");
        assertEquals("two", ret);
        ret = proc.process("dir");
        assertEquals("vars: a, b", ret);
    }

    public function testHelp()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("help");
        var ans = 'ihx shell commands:
  dir            list all currently defined variables
  addlib [name]  add a haxelib library to the search path
  rmlib  [name]  remove a haxelib library from the search path
  libs           list haxelib libraries that have been added
  clear          delete all variables from the current session
  print          dump the temp neko program to the console
  help           print this message
  exit           close this session
  quit           close this session';
        assertEquals(ans, ret);
    }

    public function testClear()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("one", ret);
        ret = proc.process("var b='two'");
        assertEquals("two", ret);
        ret = proc.process("clear");
        ret = proc.process("dir");
        assertEquals('vars: (none)', ret);
    }

    public function testLibs()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("libs");
        assertEquals("libs: (none)", ret);

        ret = proc.process("addlib hxSet");
        ret = proc.process("libs");
        assertEquals("libs: hxSet", ret);

        ret = proc.process("rmlib hxSet");
        ret = proc.process("libs");
        assertEquals("libs: (none)", ret);
    }
}
