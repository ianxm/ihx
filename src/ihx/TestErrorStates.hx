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

class TestErrorStates extends haxe.unit.TestCase
{
    public function testIncompleteStatement()
    {
        var proc = new CmdProcessor();
        try
        {
            var ret = proc.process("var a=\\");
            assertTrue(false);
        }
        catch (ex:CmdError)
        {
            assertEquals("IncompleteStatement", Type.enumConstructor(ex));
        }

        var ret = proc.process("2");
        assertEquals('Int : 2', ret);
    }
}
