'
'   string.brs
'
'
function StringUtil() as Object

    util = {

        isString: function(value) as Boolean
            return type(value) = "String" or type(value) = "roString"
        end function

        charAt: function(str as String, index=0 as Integer) as String
            return str.mid(index, 1)
        end function

        startsWith: function(str as String, substr as String) as Boolean
            return str.left(substr.len()) = substr
        end function

        endsWith: function(str as String, substr as String) as Boolean
            return str.right(substr.len()) = substr
        end function

        contains: function(str as String, substr as String, position=0 as Integer) as Boolean
            return m.indexOf(str, substr, position) >= 0
        end function

        indexOf: function(str as String, substr as String, position=0 as Integer) as Integer
            return str.instr(position, substr)
        end function

        match: function(str as String, regex as String, flag="" as String) as Object
            regexObj = createObject("roRegex", regex, flag)
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

        repeat: function(str as String, count as Integer) as String
            return string(count, str)
        end function

        _padToLength: function(str as String, targetLength as Integer) as String
            strLength = str.len()

            if targetLength = 0 or strLength = 0 then return ""

            repeatCount = int(targetLength / strLength) + 1
            return m.repeat(str, repeatCount).left(targetLength)
        end function

        padStart: function(str as String, targetLength as Integer, padString=" " as String) as String
            strLength = str.len()

            if targetLength <= strLength then return str

            padLength = targetLength - strLength
            return m._padToLength(padString, padLength) + str
        end function

        padEnd: function(str as String, targetLength as Integer, padString=" " as String) as String
            strLength = str.len()

            if targetLength <= strLength then return str

            padLength = targetLength - strLength
            return str + m._padToLength(padString, padLength)
        end function

        concat: function(str as String, value) as String
            return str + m.toString(value)
        end function

        toString: function(value) as String
            valueType = type(value)
            if valueType = "<uninitialized>" then
                value = "<uninitialized>"
            else if valueType = "roSGNode" then
                value = value.id
            else if valueType = "roAssociativeArray" then
                items = ""
                for each key in value
                    items += key.toStr() + ": " + m.toString(value[key]) + ", "
                end for
                value = "{ " + items.left(items.len()-2) + " }"
            else if valueType = "roList" or valueType = "roArray" then
                items = ""
                for each item in value
                    items = m.concat(items, item) + ", "
                end for
                value = "[" + items.left(items.len()-2) + "]"
            else if valueType = "roDateTime" then
                value = value.asSeconds()
            end if
            return box(value).toStr()
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

    }

    return util

end function
