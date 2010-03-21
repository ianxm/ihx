/*
 Copyright (c) 2009-2010, Ian Martins (ianxm@jhu.edu)

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
    var ret = proc.process("a='one'");
    assertEquals("one", ret);
    ret = proc.process("b='two'");
    assertEquals("two", ret);
    ret = proc.process("dir");
    assertEquals("Current variables: a, b", ret);
  }

  public function testBuiltins()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a='one'");
    assertEquals("one", ret);
    ret = proc.process("b='two'");
    assertEquals("two", ret);
    ret = proc.process("builtins");
    var ans = 'Builtins: Array, Class, Date, DateTools, Dynamic, EReg, Float, Hash, Int,
     IntHash, IntIter, Lambda, List, Math, Reflect, Std, String, StringBuf,
     StringTools, Type, Xml, haxe.BaseCode, haxe.FastCell, haxe.FastList, haxe.Firebug,
     haxe.Http, haxe.Int32, haxe.Log, haxe.Md5, haxe.Public, haxe.Resource,
     haxe.Serializer, haxe.Stack, haxe.Template, haxe.Timer, haxe.Unserializer';
    assertEquals(ans, ret);
  }

  public function testHelp()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("help");
    var ans = 'IHx Shell Commands:
  dir      list all currently defined variables
  builtins list all builtin classes
  clear    delete all variables from the current session
  help     print this message
  exit     close this session
  quit     close this session';
    assertEquals(ans, ret);
  }

  public function testClear()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a='one'");
    assertEquals("one", ret);
    ret = proc.process("b='two'");
    assertEquals("two", ret);
    ret = proc.process("clear");
    ret = proc.process("dir");
    assertEquals('There are currently no variables', ret);
  }
}