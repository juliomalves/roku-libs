'
'   string.brs
'
'
function StringUtil() as Object

    util = {
        charAt: function(str as String, index=0 as Integer)
            return str.mid(index, 1)
        end function

        contains: function(str as String, substr as String, position=0 as Integer)
            return m.indexOf(str, substr, position) >= 0
        end function

        indexOf: function(str as String, substr as String, position=0 as Integer)
            return str.instr(position, substr)
        end function

        match: function(str as String, regex as String, flag="" as String) as Object
            regexObj = CreateObject("roRegex", regex, flag)
            return regexObj.match(str)
        end function

        replace: function(str as String, pattern as String, replacement as String) as String
            regexObj = createObject("roRegex", pattern, "")
            return regexObj.replaceAll(str, replacement)
        end function

        truncate: function(str as String, length as Integer, ellipsis="" as String) as String
            truncated = str
            if truncated.len() > length then
                truncated = truncated.left(length) + ellipsis
            end if
            return truncated
        end function

        toMD5: function(str as String) as String
            return m._hash(str, "md5")
        end function

        toSHA1: function(str as String) as String
            return m._hash(str, "sha1")
        end function

        toSHA256: function(str as String) as String
            return m._hash(str, "sha256")
        end function

        toSHA512: function(str as String) as String
            return m._hash(str, "sha512")
        end function

        _hash: function(msg as String, algorithm="md5" as String) as String
            ba = createObject("roByteArray")
            ba.fromAsciiString(msg)
            digest = createObject("roEVPDigest")
            digest.setup(algorithm)
            return digest.process(ba)
        end function

        _isString: function(arr)
            return type(arr) = "String" or type(arr) = "roString"
        end function
    }

    return util

end function
