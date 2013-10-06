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

/**
   remember the past commands.
**/
class History
{
    private var commands :Array<String>;
    private var pos :Int;

    public function new()
    {
        commands = [""];
        pos = 1;
    }

    public function add(cmd)
    {
        commands.push(cmd);
        pos = commands.length;
    }

    public function next()
    {
        pos += 1;
        return commands[pos % commands.length];
    }

    public function prev()
    {
        pos -= 1;
        if( pos < 0 )
            pos += commands.length;
        return commands[pos % commands.length];
    }
}
