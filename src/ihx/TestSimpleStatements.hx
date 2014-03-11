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

import ihx.CmdProcessor;

class TestSimpleStatements extends haxe.unit.TestCase
{
    public function testSetVar()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=1");
        assertEquals("Int : 1", ret);
    }

    public function testSuppressedOutput()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=1;");
        assertEquals("", ret);
        ret = proc.process("a");
        assertEquals("Int : 1", ret);
    }

    public function testCompute()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=1;");
        ret = proc.process("var b=2;");
        ret = proc.process("var c=a+b");
        assertEquals("Int : 3", ret);
    }

    public function testString()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("String : one", ret);
    }

    public function testVariablePersistence()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("String : one", ret);
        ret = proc.process("var b='two'");
        assertEquals("String : two", ret);
        ret = proc.process("var c=a+' '+b");
        assertEquals("String : one two", ret);
    }

    public function testFunction()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var f=function(ii) { return ii*2; }");
        assertEquals("Int -> Int : #function:1", ret);
        ret = proc.process("f(4)");
        assertEquals("Int : 8", ret);
    }
}
