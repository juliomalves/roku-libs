'
'   math.brs
'
'
function MathUtil() as Object

    math = {

        E: 2.718281828459

        PI: 3.1415926535898

        isNumber: function(number) as Boolean
            return m.isInt(number) or m.isFloat(number) or m.isDouble(number)
        end function

        isInt: function(number) as Boolean
            return getInterface(number, "ifInt") <> invalid
        end function

        isFloat: function(number) as Boolean
            return getInterface(number, "ifFloat") <> invalid
        end function

        isDouble: function(number) as Boolean
            return getInterface(number, "ifDouble") <> invalid
        end function

        ceil: function(number as Float) as Integer
            return -int(-number)
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

        power: function(base, exp as Integer)
            return base ^ exp
        end function

    }

    return math

end function
