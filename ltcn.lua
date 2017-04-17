local lpeg = require "lpeg"
local P, S, R, V = lpeg.P, lpeg.S, lpeg.R, lpeg.V
local C, Carg, Cb, Cc = lpeg.C, lpeg.Carg, lpeg.Cb, lpeg.Cc
local Cf, Cg, Cmt, Cs, Ct = lpeg.Cf, lpeg.Cg, lpeg.Cmt, lpeg.Cs, lpeg.Ct
local tonumber, type, iotype, open = tonumber, type, io.type, io.open
local concat, sort, pairs = table.concat, table.sort, pairs
local char, error = string.char, error
local _ENV = nil

local escape_map = {
    ["\a"] = "\\a",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
}

local unescape_map = {
    ["a"] = "\a",
    ["b"] = "\b",
    ["f"] = "\f",
    ["n"] = "\n",
    ["r"] = "\r",
    ["t"] = "\t",
    ["v"] = "\v",
    ["\n"] = "\n",
    ["\r"] = "\n",
    ["'"] = "'",
    ['"'] = '"',
    ["\\"] = "\\"
}

local function escape(s)
    return (s:gsub("[\a\b\f\n\r\t\v]", escape_map))
end

local function lineno(str, i)
    if i == 1 then
        return 1, 1
    end
    local rest, n = str:sub(1, i):gsub("[^\n]*\n", "")
    return n + 1, #rest
end

local function getffp(subject, position, errorinfo)
    return errorinfo.ffp or position, errorinfo
end

local function tokenset_to_list(set)
    local list, i = {}, 0
    for member in pairs(set) do
        i = i + 1
        list[i] = "'" .. member .. "'"
    end
    sort(list)
    return list
end

local function report_error()
    local errorinfo = Cmt(Carg(1), getffp) * V"OneWord" / function(e, u)
        e.unexpected = u
        return e
    end
    return errorinfo / function(e)
        local filename = e.filename or ""
        local line, col = lineno(e.subject, e.ffp or 1)
        local unexpected = escape(e.unexpected)
        local expected = concat(tokenset_to_list(e.expected), ", ")
        local s = "%s:%d:%d: Syntax error: unexpected '%s', expecting %s"
        return nil, s:format(filename, line, col, unexpected, expected)
    end
end

local function setffp(subject, position, errorinfo, token_name)
    local ffp = errorinfo.ffp
    if not ffp or position > ffp then
        errorinfo.ffp = position
        errorinfo.expected = {[token_name] = true}
    elseif position == ffp then
        errorinfo.expected[token_name] = true
    end
    return false
end

local function updateffp(name)
    return Cmt(Carg(1) * Cc(name), setffp)
end

local function T(name)
    return V(name) * V"Skip" + updateffp(name) * P(false)
end

local function symb(str)
    return P(str) * V"Skip" + updateffp(str) * P(false)
end

local function setfield(t, v1, v2)
    if v2 == nil then
        t[#t + 1] = v1
    else
        t[v1] = v2
    end
    return t
end

local function delim_match(subject, offset, c1, c2)
    return c1 == c2
end

local grammar = {
    V"Return" * V"Table" * T"EOF" + report_error();

    Key = T"Number" + T"String" + T"Boolean";
    Value = T"Number" + T"String" + T"Boolean" + V"Table";
    IndexedField = Cg(symb"[" * V"Key" * symb"]" * symb"=" * V"Value");
    NamedField = Cg(T"Name" * symb"=" * V"Value");
    Field = V"IndexedField" + V"NamedField" + V"Value";
    FieldSep = symb"," + symb";";
    FieldList = (V"Field" * (V"FieldSep" * V"Field")^0 * V"FieldSep"^-1)^-1;
    Table = symb"{" * Cf(Ct"" * V"FieldList", setfield) * symb"}";

    LongOpen = "[" * Cg(P"="^0, "openeq") * "[" * P"\n"^-1;
    LongClose = "]" * C(P"="^0) * "]";
    LongMatch = Cmt(V"LongClose" * Cb"openeq", delim_match);
    LongString = V"LongOpen" * C((P(1) - V"LongMatch")^0) * V"LongClose" / 1;

    LongComment = P"--" * V"LongString" / 0;
    LineComment = P"--" * (P(1) - P"\n")^0;
    Comment = V"LongComment" + V"LineComment";

    Space = S" \f\n\r\t\v";
    Skip = (V"Space" + V"Comment")^0;
    Return = V"Skip" * (P"return" * -V"NameChar")^-1 * V"Skip";
    EOF = P(-1);

    Keywords = P"and" + "break" + "do" + "elseif" + "else" + "end" +
               "false" + "for" + "function" + "goto" + "if" + "in" +
               "local" + "nil" + "not" + "or" + "repeat" + "return" +
               "then" + "true" + "until" + "while";

    NameStart = R"az" + R"AZ" + P"_";
    NameChar = V"NameStart" + R"09";
    Reserved = V"Keywords" * -V"NameChar";
    Name = -V"Reserved" * C(V"NameStart" * V"NameChar"^0) * -V"NameChar";

    HexDigit = R"af" + R"AF" + R"09";
    HexInt = P"0" * S"xX" * V"HexDigit"^1;
    DecInt = R"09"^1;

    DecExpo = S"eE" * S"+-"^-1 * R"09"^1;
    DecFloat = (P"." * R"09"^1 * V"DecExpo"^-1) +
               (V"DecInt" * P"." * R"09"^0 * V"DecExpo"^-1) +
               (V"DecInt" * V"DecExpo");

    HexExpo = S"pP" * S"+-"^-1 * R"09"^1;
    HexFloat = (V"HexInt" * P"." * V"HexDigit"^0 * V"HexExpo"^-1) +
               (V"HexInt" * V"HexExpo");

    Int = V"HexInt" + V"DecInt";
    Float = V"DecFloat";
    Number = C(P"-"^-1 * (V"Float" + V"Int")) / tonumber;

    True = P"true" * -V"NameChar" * Cc(true);
    False = P"false" * -V"NameChar" * Cc(false);
    Boolean = V"True" + V"False";

    Escape = P"\\" / "" * (
        S"abfnrtv'\n\r\"\\" / unescape_map
        + P"z" * V"Space"^0 / ""
        + R"09" * R"09"^-2 / tonumber / char
    );
    SingleQuotedString = P"'" * Cs((V"Escape" + (P(1) - S"'\r\n"))^0) * symb"'";
    DoubleQuotedString = P'"' * Cs((V"Escape" + (P(1) - S'"\r\n'))^0) * symb'"';
    ShortString = V"DoubleQuotedString" + V"SingleQuotedString";
    String = V"LongString" + V"ShortString";

    OneWord = C(V"Name" + V"Number" + V"String" + V"Reserved" + P(1)) + Cc"EOF";
}

local function parse(subject, filename)
    if type(subject) ~= "string" then
        error("bad argument #1: string expected, got " .. type(subject), 2)
    elseif filename ~= nil and type(filename) ~= "string" then
        error("bad argument #2: string expected, got " .. type(filename), 2)
    end
    local errorinfo = {subject = subject, filename = filename}
    lpeg.setmaxstack(1000)
    return lpeg.match(grammar, subject, 1, errorinfo)
end

local function parse_file(file_or_filename)
    local file, filename, openerr
    local argtype = type(file_or_filename)
    if argtype == "string" then
        filename = file_or_filename
        file, openerr = open(filename)
        if not file then
            return nil, openerr
        end
    elseif iotype(file_or_filename) == "file" then
        file = file_or_filename
    else
        error("bad argument #1: string expected, got " .. argtype, 2)
    end
    local text, readerr = file:read("*a")
    file:close()
    if not text then
        return nil, readerr
    end
    return parse(text, filename)
end

return {
    parse = parse,
    parse_file = parse_file
}
