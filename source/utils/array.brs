'
'   array.brs
'
'
function ArrayUtil() as Object

    util = {

        isArray: function(arr) as Boolean
            return type(arr) = "roArray"
        end function

        contains: function(arr as Object, element as Dynamic) as Boolean
            return m.indexOf(arr, element) >= 0
        end function

        indexOf: function(arr as Object, element as Dynamic) as Integer
            if not m.isArray(arr) then return -1

            size = arr.count()

            if size = 0 then return -1

            for i = 0 to size - 1
                if arr[i] = element then return i
            end for

            return -1
        end function

        lastIndexOf: function(arr as Object, element as Dynamic) as Integer
            if not m.isArray(arr) then return -1

            size = arr.count()

            if size = 0 then return -1

            for i = size - 1 to 0 step -1
                if arr[i] = element then return i
            end for

            return -1
        end function

        slice: function(arr as Object, fromIndex as Integer, toIndex=invalid as Dynamic)
            if not m.isArray(arr) then return invalid

            size = arr.count()
            lastIndex = size - 1
            slicedArr = []
            
            if fromIndex < 0 then fromIndex = size + fromIndex
            if toIndex = invalid then toIndex = lastIndex
            if toIndex < 0 then toIndex = size + toIndex
            if toIndex >= size then toIndex = lastIndex

            if fromIndex >= size OR fromIndex > toIndex then return slicedArr

            for i = fromIndex to toIndex
                slicedArr.push(arr[i])
            end for

            return slicedArr
        end function

        map: function(arr as Object, func as Function)
            if not m.isArray(arr) then return invalid

            size = arr.count()
            mappedArr = []

            if size = 0 then return mappedArr

            for i = 0 to size - 1
                mappedArr.push(func(arr[i], i, arr))
            end for

            return mappedArr
        end function

        reduce: function(arr as Object, func as Function, initialValue=invalid as Dynamic)
            if not m.isArray(arr) then return invalid

            size = arr.count()
            startAt = 0
            accumulator = initialValue

            if size = 0 then return accumulator

            if accumulator = invalid then 
                accumulator = arr[0]
                startAt = 1
            end if

            for i = startAt to size - 1
                accumulator = func(accumulator, arr[i], i, arr)
            end for
            
            return accumulator
        end function

        filter: function(arr as Object, func as Function)
            if not m.isArray(arr) then return invalid

            size = arr.count()
            mappedArr = []

            if size = 0 then return mappedArr

            for i = 0 to size - 1
                if func(arr[i], i, arr) then
                    mappedArr.push(arr[i])
                end if
            end for

            return mappedArr
        end function

    }

    return util

end function
