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

package ihx.program;

using StringTools;

class Statement {
    public var isNew(default,default) :Bool;
    private var text :String;
    private var suppressOutput :Bool;

    public function new(text :String, ?forceSemi=false)
    {
        isNew = true;
        text = text.trim();
        if( forceSemi && !text.endsWith(";") )
            text += ";";
        this.suppressOutput = text.endsWith(";");
        this.text = text;
    }

    public function toString() {
        if( isNew && !suppressOutput )
            return 'Lib.println(IhxASTFormatter.format($text));';
        else
        {
            var addSemi = suppressOutput ? "" : ";";
            return text+addSemi;
        }
    }
}
