/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2020 Ian Martins (ianxm@jhu.edu)                     */
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

package ihx.program;

/**
   typedef or enum
 */
class Def
{
    public var isNew :Bool;
    private var name :String;
    private var type :String;
    private var def  :String;                               // "enum" or "typedef ="

    public function new(name, type, def)
    {
        isNew = true;
        this.name = name;
        this.type = type;
        this.def  = def;
    }

    public function toString()
    {
        var equalStr = (def=="typedef") ? "= " : "";
        return def +" "+ name +" "+ equalStr + type;
    }
}

