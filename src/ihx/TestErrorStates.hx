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

class TestErrorStates extends haxe.unit.TestCase
{
  public function testIncompleteStatement()
  {
    var proc = new CmdProcessor();
    try
    {
      var ret = proc.process("a=");
      assertTrue(false);
    }
    catch (ex:CmdError)
    {
      assertEquals("IncompleteStatement", Type.enumConstructor(ex));
    }

    var ret = proc.process("2");
    assertEquals('2', ret);
  }

  public function testIncompleteBlock()
  {
    var proc = new CmdProcessor();
    try
    {
      var ret = proc.process("{a=1");
      assertTrue(false);
    }
    catch (ex:CmdError)
    {
      assertEquals("IncompleteStatement", Type.enumConstructor(ex));
    }

    var ret = proc.process(";}");
    assertEquals('1', ret);
  }

  public function testIncompleteQuote()
  {
    var proc = new CmdProcessor();
    try
    {
      var ret = proc.process("a='multiline");
      assertTrue(false);
    }
    catch (ex:CmdError)
    {
      assertEquals("IncompleteStatement", Type.enumConstructor(ex));
    }

    var ret = proc.process("string'");
    assertEquals('multiline\nstring', ret);
  }

  public function testIncompleteLoop()
  {
    var proc = new CmdProcessor();
    try
    {
      var ret = proc.process("for( ii in 0...4 )");
      assertTrue(false);
    }
    catch (ex:CmdError)
    {
      assertEquals("IncompleteStatement", Type.enumConstructor(ex));
    }

    var ret = proc.process("a=ii; a");
    assertEquals('3', ret);
  }
}