'
'   math.brs
'
'
function MathUtil() as Object

    math = {
        E: 2.71828
        PI: 3.14159

        ceil: function(number as Float) as Integer
            i = int(number)
            if number > i then return i+1
            return i
        end function

        floor: function(number as Float) as Integer
            return int(number)
        end function

        round: function(number as Float, precision=0 as Integer) as Float
            return cint(number * 10^precision) / 10^precision
        end function

        min: function(a, b)
            if not b < a then
                return a
            else
                return b
            end if
        end function

        max: function(a, b)
            if a < b then
                return b
            else
                return a
            end if
        end function

        _isNumber: function(number)
            return getInterface(number, "ifInt") <> invalid or getInterface(number, "ifFloat") <> invalid or getInterface(number, "ifDouble") <> invalid
        end function
    }

    return math

end function
