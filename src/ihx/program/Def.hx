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

