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
            return "Lib.println("+ text +");";
        else
        {
            var addSemi = suppressOutput ? "" : ";";
            return text+addSemi;
        }
    }
}
