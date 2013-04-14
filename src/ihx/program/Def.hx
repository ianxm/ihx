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

