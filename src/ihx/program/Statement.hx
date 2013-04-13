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
