/*
 Copyright (c) 2009, Ian Martins (ianxm@jhu.edu)

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

class TestSimpleStatements extends haxe.unit.TestCase
{
  public function testSetVar()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a=1");
    assertEquals("1", ret);
  }

  public function testSuppressedOutput()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a=1;");
    assertEquals(null, ret);
    ret = proc.process("a");
    assertEquals("1", ret);
  }

  public function testSetTwoVars()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a=1;b=2");
    assertEquals("2", ret);
  }

  public function testCompute()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a=1;b=2;c=a+b");
    assertEquals("3", ret);
  }

  public function testString()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a='one'");
    assertEquals("one", ret);
  }

  public function testVariablePersistence()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("a='one'");
    assertEquals("one", ret);
    ret = proc.process("b='two'");
    assertEquals("two", ret);
    ret = proc.process("c=a+' '+b");
    assertEquals("one two", ret);
  }

  public function testFunction()
  {
    var proc = new CmdProcessor();
    var ret = proc.process("f=function(ii) { return ii*2; }");
    assertEquals("#function:-1", ret);
    ret = proc.process("f(4)");
    assertEquals("8", ret);
  }
}