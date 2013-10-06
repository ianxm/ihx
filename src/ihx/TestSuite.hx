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

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new ihx.TestPartialCommand());
        r.add(new ihx.TestHistory());
        r.add(new ihx.TestSimpleStatements());
        r.add(new ihx.TestCommands());
        r.add(new ihx.TestErrorStates());
        r.add(new ihx.TestBuiltins());
        r.run();
    }
}
