local lpeg = require "lpeg"
local class = lpeg.locale()
local P, S, R, V = lpeg.P, lpeg.S, lpeg.R, lpeg.V
local C, Carg, Cb, Cc = lpeg.C, lpeg.Carg, lpeg.Cb, lpeg.Cc
local Cf, Cg, Cmt, Ct = lpeg.Cf, lpeg.Cg, lpeg.Cmt, lpeg.Ct
local digit, xdigit, space = class.digit, class.xdigit, class.space
local format = string.format

local boolmap = {
    ["true"] = true,
    ["false"] = false
}

local charmap = {
    ["\\a"] = "\a",
    ["\\b"] = "\b",
    ["\\f"] = "\f",
    ["\\n"] = "\n",
    ["\\r"] = "\r",
    ["\\t"] = "\t",
    ["\\v"] = "\v",
    ["\\\n"] = "\n",
    ["\\\r"] = "\n",
    ["\\'"] = "'",
    ['\\"'] = '"',
    ["\\\\"] = "\\"
}

function lineno(s, i)
    if i == 1 then return 1, 1 end
    local l, lastline = 0, ""
    s = s:sub(1, i) .. "\n"
    for line in s:gmatch("[^\n]*[\n]") do
        l = l + 1
        lastline = line
    end
    local c = lastline:len() - 1
    return l, c ~= 0 and c or 1
end

local function getffp(s, i, t)
    return t.ffp or i, t
end

-- Gets the table that contains the error information
local function geterrorinfo()
    return Cmt(Carg(1), getffp) * (C(V"OneWord") + Cc("EOF")) / function(t, u)
        t.unexpected = u
        return t
    end
end

-- Creates an errror message using the farthest failure position
local function report_error()
    return geterrorinfo() / function(e)
        local pos = e.ffp or 1
        local line, col = lineno(e.subject, pos)
        local s = "%s:%d:%d: Syntax error: unexpected '%s', expecting %s"
        return nil, format(s, e.filename, line, col, e.unexpected, e.expected)
    end
end

-- Sets the farthest failure position and the expected tokens
local function setffp(s, i, t, n)
    if not t.ffp or i > t.ffp then
        t.ffp = i
        t.list = {}
        t.list[n] = n
        t.expected = "'" .. n .. "'"
    elseif i == t.ffp then
        if not t.list[n] then
            t.list[n] = n
            t.expected = "'" .. n .. "', " .. t.expected
        end
    end
    return false
end

local function updateffp(name)
    return Cmt(Carg(1) * Cc(name), setffp)
end

local function token(pat, name)
    return pat * V"Skip" + updateffp(name) * P(false)
end

local function T(name)
    return token(V(name), name)
end

local function symb(str)
    return token(P(str), str)
end

local function unescape(s)
    return (s:gsub("\\[abfnrtv'\n\r\"\\]", charmap))
end

local function setfield(t, v1, v2)
    if v2 == nil then
        table.insert(t, v1)
    else
        rawset(t, v1, v2)
    end
    return t
end

local grammar = {
    V"Skip" * V"Table" * V"Skip" * -1 + report_error();
    -- Parser
    IndexedField = Cg(symb"[" * V"Expr" * symb"]" * symb"=" * V"Expr");
    NamedField = Cg(T"Name" * V"Skip" * symb"=" * V"Expr");
    Field = V"IndexedField" + V"NamedField" + V"Expr";
    FieldSep = symb"," + symb";";
    FieldList = (V"Field" * (V"FieldSep" * V"Field")^0 * V"FieldSep"^-1)^-1;
    Table = symb"{" * Cf(Ct"" * V"FieldList", setfield) * symb"}";
    Expr = T"Number" + T"String" + T"Boolean" + V"Table";
    -- Lexer
    Space = space^1;
    Equals = P"="^0;
    Open = "[" * Cg(V"Equals", "init") * "[" * P"\n"^-1;
    Close = "]" * C(V"Equals") * "]";
    CloseEQ = Cmt(V"Close" * Cb"init", function(s, i, a, b) return a == b end);
    LongString = V"Open" * C((P(1) - V"CloseEQ")^0) * V"Close" / 1;
    Comment = P"--" * V"LongString" / 0 + P"--" * (P(1) - P"\n")^0;
    Skip = (V"Space" + V"Comment")^0;
    NameStart = R"az" + R"AZ" + P"_";
    NameChar = V"NameStart" + R"09";
    Keywords = P"and" + "break" + "do" + "elseif" + "else" + "end" +
               "false" + "for" + "function" + "goto" + "if" + "in" +
               "local" + "nil" + "not" + "or" + "repeat" + "return" +
               "then" + "true" + "until" + "while";
    Reserved = V"Keywords" * -V"NameChar";
    Name = -V"Reserved" * C(V"NameStart" * V"NameChar"^0) * -V"NameChar";
    Hex = P"0" * S"xX" * xdigit^1;
    Expo = S"eE" * S"+-"^-1 * digit^1;
    Float = (((digit^1 * P"." * digit^0) + (P"." * digit^1)) * V"Expo"^-1) +
            (digit^1 * V"Expo");
    Int = digit^1;
    Number = C(P"-"^-1 * (V"Hex" + V"Float" + V"Int")) / tonumber;
    Boolean = ((P"true" + P"false") * -V"NameChar") / boolmap;
    SingleQuotedString = P"'" * C(((P"\\" * P(1)) + (P(1) - P"'"))^0) * P"'";
    DoubleQuotedString = P'"' * C(((P'\\' * P(1)) + (P(1) - P'"'))^0) * P'"';
    ShortString = V"DoubleQuotedString" + V"SingleQuotedString";
    String = V"LongString" + (V"ShortString" / unescape);
    -- For error reporting
    OneWord = V"Name" + V"Number" + V"String" + V"Reserved" + P(1);
}

local function parse(subject, filename)
    local errorinfo = {subject = subject, filename = filename}
    lpeg.setmaxstack(1000)
    return lpeg.match(grammar, subject, 1, errorinfo)
end

local function parse_file(file_or_filename)
    local file, filename, openerr
    if type(file_or_filename) == "string" then
        filename = file_or_filename
        file, openerr = io.open(filename)
        if not file then
            return nil, openerr
        end
    elseif io.type(file_or_filename) == "file" then
        file = file_or_filename
    else
        return nil, "Invalid argument #1: not a file handle or filename string"
    end
    local text, readerr = file:read("*a")
    file:close()
    if text then
        return parse(text, filename)
    else
        return nil, readerr
    end
end

return {
    parse = parse,
    parse_file = parse_file
}
