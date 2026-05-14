
# **Array methods**
## .chunk
Creates an array of elements split into groups the length of size. If array can't be split evenly, the final chunk will be the remaining elements.


#### Arguments
array (Array): The array to process.

[size:=1] (number): The length of each chunk


#### Returns
(Array): Returns the new array of chunks.


#### Example

```autohotkey
_.chunk(["a", "b", "c", "d"], 2)
; => [["a", "b"], ["c", "d"]]

_.chunk(["a", "b", "c", "d"], 3)
; => [["a", "b", "c"], ["d"]]

```



## .compact
Creates an array with all falsey values removed. The values `false`, `0`, `""`, and `unset` are falsey.


#### Arguments
array (Array): The array to compact.


#### Returns
(Array): Returns the new array of filtered values.


#### Example

```autohotkey
_.compact([0, 1, false, 2, "", 3])
; => [1, 2, 3]

```



## .depthOf
This method is explores the array and returns the maximum depth.


#### Arguments
array (Array): The array to inspect.


#### Returns
(number): Returns the maximum depth.


#### Example

```autohotkey
_.depthOf([1])
; => 1

_.depthOf([1, [2]])
; => 2

_.depthOf([1, [[2]]])
; => 3

_.depthOf([1, [2, [3, [4]], 5]])
; => 4

```



## .difference
Creates an array of `array` values not included in the other given arrays. The order of result values are determined by the first array.

#### Arguments
array (Array): The array to inspect.

values (Array*): The values to exclude.


#### Returns
(Array): Returns the new array of filtered values.


#### Example

```autohotkey
_.difference([2, 1], [2, 3])
; => [1]

```



## .drop
Creates a slice of `array` with `n` elements dropped from the beginning.


#### Arguments
array (Array): The array to query.

[n:=1] (number): The number of elements to drop.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.drop([1, 2, 3])
; => [2, 3]

_.drop([1, 2, 3], 2)
; => [3]

_.drop([1, 2, 3], 5)
; => []

_.drop([1, 2, 3], 0)
; => [1, 2, 3]

_.drop("neo")
; => ["e", "o"]

_.drop(100)
; => ["0", "0"]

```



## .dropRight
Creates a slice of array with n elements dropped from the end.


#### Arguments
array (Array): The array to query.

[n:=1] (number): The number of elements to drop.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.dropRight([1, 2, 3])
; => [1, 2]

_.dropRight([1, 2, 3], 2)
; => [1]

_.dropRight([1, 2, 3], 5)
; => []

_.dropRight([1, 2, 3], 0)
; => [1, 2, 3]

_.dropRight("neo")
; => ["n", "e"]

_.dropRight(100)
; => ["1", "0"]

```



## .fill
Fills elements of array with `value` from start up to, but not including, `end`.

> [!Note]
> This method mutates the array.


#### Arguments
array (Array): The array to fill.

value (*): The value to fill array with.

[start:=1] (number): The start position.

[end:=array.length] (number): The end position.


#### Returns
(Array): Returns array.


#### Example

```autohotkey
arr := [1, 2, 3]
_.fill(arr, "a")
; => ["a", "a", "a"]

_.fill([4, 6, 8, 10], "*", 2, 4)
; => [4, "*", "*", 10]

```



## .flatten
Flattens array a single level deep.


#### Arguments
array (Array): The array to flatten.


#### Returns
(Array): Returns the new flattened array.


#### Example

```autohotkey
_.flatten([1, [2, [3, [4]], 5]])
; => [1, 2, [3, [4]], 5]

_.flatten([[1, 2, 3], [4, 5, 6]])
; => [1, 2, 3, 4, 5, 6]

```



## .flattenDeep
Recursively flattens array.


#### Arguments
array (Array): The array to flatten.


#### Returns
(Array): Returns the new flattened array.


#### Example

```autohotkey
_.flattenDeep([1])
; => [1]

_.flattenDeep([1, [2, [3, [4]], 5]])
; => [1, 2, 3, 4, 5]

```



## .flattenDepth
Recursively flatten array up to depth times.


#### Arguments
array (Array): The array to flatten.

[depth:=1] (number): The maximum recursion depth.


#### Returns
(Array): Returns the new flattened array.


#### Example

```autohotkey
_.flattenDepth([1, [2, [3, [4]], 5]], 1)
; => [1, 2, [3, [4]], 5]

_.flattenDepth([1, [2, [3, [4]], 5]], 2)
; => [1, 2, 3, [4], 5]

```



## .fromPairs
The inverse of _.toPairs; this method returns an object composed from key-value pairs.

#### Arguments
pairs (Array): The key-value pairs.


#### Returns
(Object): Returns the new object.


#### Example

```autohotkey
_.fromPairs([["a", 1], ["b", 2]])
; => {a: 1, b: 2}

```



## .head
Gets the first element of array.

#### Aliases
`.first`

#### Arguments
array (Array): The array to query.


#### Returns
(*): Returns the first element of array.


#### Example

```autohotkey
_.head([1, 2, 3])
; => 1

_.head({a: 1, b: 2, c:3})
; => 1

_.head("Neo")
; => "N"

```



## .indexOf
Gets the index at which the first occurrence of `value` is found in `array`. If `fromIndex` is negative, it's used as the offset from the end of `array`.


#### Arguments
array (Array): The array to inspect.

value (*): The value to search for.

[fromIndex:=1] (number): The index to search from.


#### Returns
(number): Returns the index of the matched value, else -1.


#### Example

```autohotkey
_.indexOf([1, 2, 1, 2], 2)
; => 2

; Search from the `fromIndex`.
_.indexOf([1, 2, 1, 2], 2, 3)
; => 4

_.stringCaseSense := true
_.indexOf(["neo", "morpheus"], "Neo")
; => -1

```



## .initial
Gets all but the last element of array.


#### Arguments
array (Array): The array to query.

#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.initial([1, 2, 3])
; => [1, 2]

_.initial("neo")
; => ["n", "e"]

_.initial(100)
; => ["1", "0"]

```



## .intersection
Creates an array of unique values that are included in all given arrays. The order of result values are determined by the first array.


#### Arguments
[arrays*] (...Array): The arrays to inspect.


#### Returns
(Array): Returns the new array of intersecting values.


#### Example

```autohotkey
_.intersection([2, 1], [2, 3])
; => [2]

```



## .join
Converts all elements in array into a string separated by separator.


#### Arguments
array (Array): The array to convert.

[separator:=","] (string): The element separator.


#### Returns
(string): Returns the joined string.


#### Example

```autohotkey
_.join(["a", "b", "c"], "~")
; => "a~b~c"

_.join(["a", "b", "c"])
; => "a,b,c"

```



## .last
Gets the last element of array.


#### Arguments
array (Array): The array to query.


#### Returns
(*): Returns the last element of array.


#### Example

```autohotkey
_.last([1, 2, 3])
; => 3

_.last([])
; => ""

_.last("neo")
; => "o"

_.last(100)
; => 0

```



## .lastIndexOf
This method is like [_.indexOf](/?id=indexof) except that it iterates over elements of array from right to left.


#### Arguments
array (Array): The array to inspect.

value (*): The value to search for.

[fromIndex:=array.length] (number): The index to search from.


#### Returns
(number): Returns the index of the matched value, else -1.


#### Example

```autohotkey
_.lastIndexOf([1, 2, 1, 2], 2)
; => 4

; Search from the `fromIndex`.
_.lastIndexOf([1, 2, 1, 2], 1, 3)
; => 3

_.stringCaseSense := true
_.lastIndexOf(["neo", "morpheus"], "Neo")
; => -1

```



## .nth
Gets the element at index n of array. If n is negative, the nth element from the end is returned.


#### Arguments
array (Array): The array to query.

[n:=1] (number): The index of the element to return.


#### Returns
(*): Returns the nth element of array.


#### Example

```autohotkey
_.nth([1, 2, 3])
; => 1

_.nth([1, 2, 3], -3)
; => 1

_.nth([1, 2, 3], 5)
; => ""

_.nth("neo")
; => "n"

_.nth(100)
; => "1"

_.nth([1, 2, 3], 0)
; => 1

```



## .reverse
Reverses array so that the first element becomes the last, the second element becomes the second to last, and so on.


#### Arguments
array (Array): The array to modify.


#### Returns
(Array): Returns array.


#### Example

```autohotkey
_.reverse(["a", "b", "c"])
; => ["c", "b", "a"]

_.reverse([{foo: "bar"}, "b", "c"])
; => ["c", "b", {foo: "bar"}]

_.reverse([[1, 2, 3], "b", "c"])
; => ["c", "b", [1, 2, 3]]

```



## .slice
Creates a slice of array from start up to end.


#### Arguments
array (Array): The array to slice.

[start:=1] (number): The start position.

[end:=array.length] (number): The end position.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.slice([1, 2, 3], 1, 2)
; => [1, 2]

_.slice([1, 2, 3], 1)
; => [1, 2, 3]

_.slice([1, 2, 3], 5)
; => []

_.slice("neo")
; => ["n", "e", "o"]

_.slice(100)
; => ["1", "0", "0"]

```



## .sortedIndex
Uses a search to determine the lowest index at which value should be inserted into array in order to maintain its sort order.


#### Arguments
array (Array): The sorted array to inspect.

value (*): The value to evaluate.


#### Returns
(number): Returns the index at which value should be inserted into array.


#### Example

```autohotkey
_.sortedIndex([30, 50], 40)
; => 2

_.sortedIndex([30, 50], 20)
; => 1

_.sortedIndex([30, 50], 99)
; => 3

```



## .sortedUniq
This method is like [_.uniq](/?id=uniq) except that it's optimized for sorted arrays.


#### Arguments
array (Array): The sorted array to inspect.


#### Returns
(array): Returns the new duplicate free array.


#### Example

```autohotkey
_.sortedUniq([1, 1, 2])
; => [1, 2]

```



## .tail
Gets all but the first element of array.


#### Arguments
array (Array): The array to query.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.tail([1, 2, 3])
; => [2, 3]

_.tail("neo")
; => ["e", "o"]

_.tail(100)
; => ["0", "0"]

```



## .take
Creates a slice of array with n elements taken from the beginning.


#### Arguments
array (Array): The array to query.

[n:=1] (number): The number of elements to take.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.take([1, 2, 3])
; => [1]

_.take([1, 2, 3], 2)
; => [1, 2]

_.take([1, 2, 3], 5)
; => [1, 2, 3]

_.take([1, 2, 3], 0)
; => []

_.take("neo")
; => ["n"]

_.take(100)
; => ["1"]

```



## .takeRight
Creates a slice of array with n elements taken from the end.


#### Arguments
array (Array): The array to query.

[n:=1] (number): The number of elements to take.


#### Returns
(Array): Returns the slice of array.


#### Example

```autohotkey
_.takeRight([1, 2, 3])
; => [3]

_.takeRight([1, 2, 3], 2)
; => [2, 3]

_.takeRight([1, 2, 3], 5)
; => [1, 2, 3]

_.takeRight([1, 2, 3], 0)
; => []

_.takeRight("neo")
; => ["o"]

_.takeRight(100)
; => ["0"]

```



## .union
Creates an array of unique values, in order, from all given arrays.


#### Arguments
[arrays] (...Array): The arrays to inspect.


#### Returns
(Array): Returns the new array of combined values.


#### Example

```autohotkey
_.union([2], [1, 2])
; => [2, 1]

```



## .uniq
Creates a duplicate-free version of an array, in which only the first occurrence of each element is kept. The order of result values is determined by the order they occur in the array.


#### Arguments
array (Array): The array to inspect.


#### Returns
(Array): Returns the new duplicate free array.

#### Example

```autohotkey
_.uniq([2, 1, 2])
; => [2, 1]

```



## .unzip
This method is like [_.zip](/?id=zip) except that it accepts an array of grouped elements and creates an array regrouping the elements to their pre-zip configuration.

#### Arguments
array (Array): The array of grouped elements to process.


#### Returns

(Array): Returns the new array of regrouped elements.

#### Example

```autohotkey
zipped := _.zip(["a", "b"], [1, 2], [true, false])
; => [["a", 1, true], ["b", 2, false]]
_.unzip(zipped)
; => [["a", "b"], [1, 2], [true, false]]

```



## .without
Creates an array excluding all given values.

#### Arguments
array (Array): The array to inspect.

[values] (...*): The values to exclude.


#### Returns
(Array): Returns the new array of filtered values.


#### Example

```autohotkey
_.without([2, 1, 2, 3], 1, 2)
; => [3]

```



## .zip
Creates an array of grouped elements, the first of which contains the first elements of the given arrays, the second of which contains the second elements of the given arrays, and so on.


#### Arguments
[arrays*] (...Array): The arrays to process.


#### Returns

(Array): Returns the new array of grouped elements.

#### Example

```autohotkey
_.zip(["a", "b"], [1, 2], [true, true])
; => [["a", 1, true], ["b", 2, true]]

```



## .zipObject
This method is like [_.fromPairs](/?id=frompairs) except that it accepts two arrays, one of property identifiers and one of corresponding values.


#### Arguments
[props:=[]] (Array): The property identifiers.

[values:=[]] (Array): The property values.


#### Returns

(Object): Returns the new object.


#### Example

```autohotkey
_.zipObject(["a", "b"], [1, 2])
; => {a: 1, b: 2}

```




# **Collection methods**
## .includes
Checks if value is in collection. If collection is a string, it's checked for a substring of value.


#### Arguments
collection (Array|Object|string): The collection to inspect.

value (*): The value to search for.

[fromIndex:=1] (number): The index to search from.


#### Returns
(boolean): Returns true if value is found, else false.




## .map
Creates an array of values by running each element in collection thru iteratee. The iteratee is invoked with three arguments: (value, index|key, collection).

Many adash.ahk methods are guarded to work as iteratees

The guarded methods are:
trimEnd, trimStart, parseInt, chunk, take, takeRight, drop, sampleSize, words, random

#### Arguments
collection (Array|Object): The collection to iterate over.

[iteratee:=.identity] (Function): The function invoked per iteration.


#### Returns
(Array): Returns the new mapped array.


#### Example

```autohotkey
fn_square(n) {
	return n * n
}
_.map([4, 8], fn_square)
; => [16, 64]

_.map({ a: 4, b: 8 }, fn_square)
; => [16, 64]

data_array := ["Neo", "Morpheus", "Trinity"]
_.map(data_array, (value) => ({name: value, id: A_Index}))
; => [{name: "Neo", id: 1}, {name: "Morpheus", id: 2}, {name: "Trinity", id: 3}]

```



## .sample
Gets a single random element from `collection`.

#### Arguments
collection (Array|Object|String): The collection to sample.


#### Returns
(*): Returns the random element.


#### Example
```autohotkey
_.sample([1, 2, 3, 4])
; => 2
```




## .shuffle
Creates an array of shuffled values, using a version of the [Fisher-Yates shuffle](https://en.wikipedia.org/wiki/Fisher-Yates_shuffle).

#### Arguments
collection (Array|Object): The collection to shuffle.


#### Returns
(Array): Returns the new shuffled array.


#### Example
```autohotkey
_.shuffle([1, 2, 3, 4])
; => [4, 1, 3, 2]

_.shuffle(["morpheus", "neo", "trinity"])
; => ["trinity", "morpheus", "neo"]
```




## .size
Gets the size of `collection` by returning its length for array-like values or the number of own enumerable string keyed properties for objects.


#### Arguments
collection (Array|Object|string): The collection to inspect.


#### Returns
(number): Returns the collection size.


#### Example

```autohotkey
_.size([1, 2, 3])
; => 3

_.size({ a: 1, b: 2 })
; => 2

_.size("trinity")
; => 7

```



## .some
Checks if `predicate` returns truthy for **any** element of `collection`. Iteration is stopped once `predicate` returns truthy. The predicate is invoked with three arguments: (value, index|key, collection).


#### Arguments
collection (Array|Object): The collection to iterate over.

[iteratees:=.identity] (Function): The function invoked per iteration.


#### Returns
(Array): Returns true if any element passes the predicate check, else false.


#### Example

```autohotkey
_.some(["foo", "bar", 42], _.isNumber)
; => true

```




# **Lang methods**
## .clone
Creates a shallow clone of value. Supports cloning arrays, objects, numbers, strings.

#### Arguments
value (*): The value to clone.


#### Returns
(*): Returns the cloned value.


#### Example

```autohotkey
objects := [{ a: 1 }, { b: 2 }]
shallow := _.clone(objects)
_.isEqual(objects, shallow)
; => true

```



## .cloneDeep
This method is like [_.clone](/?id=clone) except that it recursively clones value.


#### Arguments
value (*): The value to recursively clone.


#### Returns
(*): Returns the deep cloned value.


#### Example

```autohotkey
obj := [{ a: [[1, 2, 3]] }, { b: 2 }]
deepclone := _.cloneDeep(obj)
obj[1].a := 2
; object
; => [{ "a": 2 }, { "b": 2 }]
; deepclone
; => [{ "a": [[1, 2, 3]] }, { "b": 2 }]
```



## .isAlnum
Checks if value is an alnum.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is an alnum, else false.


#### Example

```autohotkey
_.isAlnum(1)
; => false

_.isAlnum("hello")
; => true

_.isAlnum([])
; => false

_.isAlnum({})
; => false

```



## .isArray
Checks if value is an Array obj.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is an array, else false.


#### Example

```autohotkey
_.isArray([1, 2, 3])
; => true

_.isArray("abc")
; => false

_.isArray({key: "value"})
; => false

```



## .isBoolean
Checks if value is classified as a boolean.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is a boolean, else false.


#### Example

```autohotkey
_.isBoolean(true)
; => true

_.isBoolean(1)
; => true

_.isBoolean(false)
; => true

_.isBoolean(0)
; => true

```



## .isBuffer
Checks if `value` is a buffer.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is a buffer, else false.


#### Example

```autohotkey
myBuffer := buffer(20, 100)
_.isBuffer(myBuffer)
; => true

```



## .isEmpty
Checks if `value` is an empty object, array, or map.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns `true` if value is empty, else `false.


#### Example

```autohotkey
_.isEmpty([])
; => true

_.isEmpty({})
; => true

_.isEmpty(map())
; => true

```



## .isEqual
Performs a deep comparison between two values to determine if they are equivalent.

This method supports comparing strings and objects.


#### Arguments
value (*): The value to compare.

other (...*): The other value to compare.


#### Returns
(boolean): Returns true if the values are equivalent, else false.


#### Example

```autohotkey
_.isEqual(1, 1)
; => true

_.isEqual({ a: 1 }, { a: 1 })
; => true

_.isEqual(1, 1, 2)
; => false

_.stringCaseSense := true
_.isEqual({ a: "a" }, { a: "A" })
; => false

```



## .isFloat
Checks if value is a float.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is a float, else false.


#### Example

```autohotkey
_.isFloat(1.0)
; => true

_.isFloat(1)
; => false

```



## .isFunction
Checks if `value` is callable as a function object, bound function, or object method.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns `true` if `value` is callable, else `false`.


#### Example

```autohotkey
bndFunc := strLen.bind("one")
_.isFunction(bndFunc)
; => true

_.isFunction(_.size)
; => true

_.isFunction([1, 2, 3])
; => false

```



## .isInteger
Checks if value is an integer.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is an integer, else false.


#### Example

```autohotkey
_.isInteger(1)
; => true

_.isInteger("1")
; => false

```



## .isMap
Checks if `value` is classified as a Map object.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns `true` if `value` is map, else `false`.


#### Example

```autohotkey
_.isMap(map(1, "Neo"))
; => true

_.isMap([])
; => false

```



## .isMatch
Performs a partial deep comparison between `object` and source to determine if `object` contains equivalent property values.

Partial comparisons will match empty array and empty object `source` values against any array or object value, respectively. See [_.isEqual](/?id=isEqual).


#### Arguments
object (Object): The object to inspect.

source (Object): The object of property values to match.


#### Returns
(boolean): Returns `true` if `object` is a match, else `false`.

#### Example

```autohotkey
obj := { a: 1, b: 2, c: 3 }
_.isMatch(obj, {b: 2})
; => true

_.isMatch(obj, {b: 2, c: 3})
; => true

_.isMatch(obj, {b: 1})
; => false

_.isMatch(obj, {b: 2, z: 99})
; => false

```



## .isNative
Checks if value is a pristine native function.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns `true` if `value` is a native function, else `false`.

#### Example

```autohotkey
_.isNative(isFloat)
; => true

boundFn := inStr.bind()
_.isNative(boundFn)
; => false

_.isNative(_)
; => false

```



## .isNumber
Checks if value is a number.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is a number, else false.


#### Example

```autohotkey
_.isNumber(1)
; => true

_.isNumber("1")
; => true

_.isNumber("1.001")
; => true

```



## .isObject
Checks if value is an obj.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is an object, else false.


#### Example

```autohotkey
_.isObject({})
; => true

_.isObject([1, 2, 3])
; => true

_.isObject("")
; => false

```



## .isString
Checks if value is classified as a string.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is a string, else false.


#### Example

```autohotkey
_.isString("abc")
; => true

_.isString(1)
; => false

```



## .isUndefined
Checks if value is undefined or blank.


#### Arguments
value (*): The value to check.


#### Returns
(boolean): Returns true if value is undefined, else false.


#### Example

```autohotkey
_.isUndefined(non_existant_var)
; => true

_.isUndefined("")
; => false

_.isUndefined({})
; => false

_.isUndefined(" ")
; => false

_.isUndefined(0)
; => false

_.isUndefined(false)
; => false

```



## .toString
Converts value to a string. An empty string is returned for undefined values. The sign of `-0` is preserved.


#### Arguments
value (*): The value to convert.


#### Returns
(boolean): Returns the converted string.




## .typeOf
This method returns a string indicating the type of `value`.


#### Arguments
value (*): the value to check.


#### Returns
(string): Returns value's type.


#### Example

```autohotkey
_.typeOf(42)
; => "integer"

_.typeOf(0.25)
; => "float"

_.typeOf("0.25")
; => "string"

_.typeOf("blubber")
; => "string"

_.typeOf([])
; => "array"

_.typeOf({})
; => "object"

_.typeOf(map())
; => "map"

_.typeOf(object)
; => "class"

_.typeOf(_)
; => "class"

```




# **Math methods**
## .add
Adds two numbers.


#### Arguments
augend (number): The first number in an addition.

addend (number): The second number in an addition.


#### Returns
(number): Returns the total.


#### Example

```autohotkey
_.add(6, 4)
; => 10

```



## .ceil
Computes `number` rounded up to `precision`.


#### Arguments
number (number): The number to round up.

[precision:=0] (number): The precision to round up to.


#### Returns
(number): Returns the rounded up number.


#### Example

```autohotkey
_.ceil(4.006)
; => 5

_.ceil(6.004, 2)
; => 6.01

_.ceil(6040, -2)
; => 6100

```



## .divide
Divide two numbers.


#### Arguments
dividend (number): The first number in a division.

divisor (number): The second number in a division.


#### Returns
(number): Returns the quotient.


#### Example

```autohotkey
_.divide(6, 4)
; => 1.5

```



## .floor
Computes `number` rounded down to `precision`.


#### Arguments
number (number): The number to round down.

[precision:=0] (number): The precision to round down to.


#### Returns
(number): Returns the rounded down number.

#### Example

```autohotkey
_.floor(4.006)
; => 4

_.floor(0.046, 2)
; => 0.04

_.floor(4060, -2)
; => 4000

```



## .max
Computes the maximum value of `array`. If `array` is empty or falsey, `""` is returned.


#### Arguments
array (Array): The array to iterate over.


#### Returns
(*): Returns the maximum value.


#### Example

```autohotkey
_.max([4, 2, 8, 6])
; => 8

_.max([])
; => ""

```



## .mean
Computes the mean of the values in `array`.


#### Arguments
array (Array): The array to iterate over.


#### Returns
(number): Returns the mean.


#### Example

```autohotkey
_.mean([4, 2, 8, 6])
; => 5

```



## .min
Computes the minimum value of `array`. If array is empty or falsey, `""` is returned.


#### Arguments
array (Array): The array to iterate over.


#### Returns
(*): Returns the minimum value.


#### Example

```autohotkey
_.min([4, 2, 8, 6])
; => 2

_.min([])
; => ""

```



## .multiply
Multiply two numbers.


#### Arguments
multiplier (number): The first number in a multiplication.

multiplicand (number): The second number in a multiplication.


#### Returns
(number): Returns the product.


#### Example

```autohotkey
_.multiply(6, 4)
; => 24

```



## .round
Computes `number` rounded to `precision`.


#### Arguments
number (number): The number to round.

[precision:=0] (number): The precision to round to.


#### Returns
(number): Returns the rounded number.


#### Example

```autohotkey
_.round(4.006)
; => 4

_.round(4.006, 2)
; => 4.01

_.round(4060, -2)
; => 4100

```



## .subtract
Subtract two numbers.


#### Arguments
minuend (number): The first number in a subtraction.

subtrahend (number): The second number in a subtraction.


#### Returns
(number): Returns the difference.


#### Example

```autohotkey
_.subtract(6, 4)
; => 2

```



## .sum
Computes the sum of the values in `array`.


#### Arguments
array (Array): The array to iterate over.


#### Returns
(number): Returns the sum.


#### Example

```autohotkey
_.sum([4, 2, 8, 6])
; => 20

```




# **Number methods**
## .clamp
Clamps number within the inclusive lower and upper bounds.


#### Arguments
number (number): The number to clamp.

lower (number): The lower bound.

upper (number): The upper bound.


#### Returns
(number): Returns the clamped number.


#### Example

```autohotkey
_.clamp(-10, -5, 5)
; => -5

_.clamp(10, -5, 5)
; => 5

```



## .inRange
Checks if `n` is between `start` and up to, but not including, `end`. If end is not specified, it's set to start with start then set to 0. If start is greater than end the params are swapped to support negative ranges.


#### Arguments
number (number): The number to check.

start (number): The start of the range.

end (number): The end of the range.


#### Returns
(boolean): Returns true if number is in the range, else false.


#### Example

```autohotkey
_.inRange(3, 2, 4)
; => true

_.inRange(4, 8)
; => true

_.inRange(4, 2)
; => false

_.inRange(2, 2)
; => false

_.inRange(1.2, 2)
; => true

_.inRange(5.2, 4)
; => false

_.inRange(-3, -2, -6)
; => true

```



## .random
Produces a random number between the inclusive lower and upper bounds. If floating is true, or either lower or upper are floats, a floating-point number is returned instead of an integer. Uses AutoHotkey's pseudo-random [Random](https://www.autohotkey.com/docs/v2/lib/Random.htm) command.


#### Arguments
[lower:=0] (number): The lower bound.

[upper:=1] (number): The upper bound.

[floating:=false] (boolean): Specify returning a floating-point number.


#### Returns
(number): Returns the random number.


#### Example
```autohotkey
_.random(0, 5)
; => an integer between 0 and 5

_.random(5)
; => an integer between 0 and 5

_.random(1.2, 5.2)
; => a floating-point number between 1.2 and 5.2

_.map(_.random([10, 10, 10]))
; => an array of random numbers between 0 and 10
```




# **Object methods**
## .get
Gets the value at `path` of `object`. If the resolved value is `unset`, the `defaultValue` is returned in its place.


#### Arguments
object (Object): The object to query.

path (Array|string): The path of the property to get.

[defaultValue] (*): The value returned for undefined resolved values.


#### Returns
(*): Returns the resolved value.


#### Example

```autohotkey
obj := {a: [{b: {c: 3}}]}
_.get(obj, "a[1].b.c")
; => 3

_.get(obj, ["a", "1", "b", "c"])
; => 3

_.get(obj, "a.b.c", "default")
; => "default"

```



## .has
Checks if `path` is a direct property of `object`.


#### Arguments
object (Object): The object to query.

path (Array|string): The path to check.


#### Returns
(boolean): Returns true if path exists, else false.


#### Example

```autohotkey
someBase := { a: "Alpha" }
instance := { base: someBase, b: "Beta" }
_.has(someBase, "a")
; => true

_.has(instance, "a")
; => false

_.has(instance, "b")
; => true

```



## .hasIn
Checks if `path` is a direct or inherited property of `object`.


#### Arguments
object (Object): The object to query.

path (Array|string): The path to check.


#### Returns
(boolean): Returns true if path exists, else false.


#### Example

```autohotkey
someBase := { a: "Alpha" }
instance := { base: someBase, b: "Beta" }
_.hasIn(instance, "a")
; => true

_.hasIn(instance, "b")
; => true

_.hasIn(instance, "d")
; => false

```



## .merge
This method recursively merges own and inherited enumerable string keyed properties of source objects into the destination object. Array and plain object properties are merged recursively. Other objects and value types are overridden by assignment. Source objects are applied from left to right. Subsequent sources overwrite property assignments of previous sources.


#### Arguments
object (Object): The destination object.

[sources] (Objects*): The source objects.


#### Returns
(Object): Returns object.


#### Example

```autohotkey
obj := {a: [{b : 2}, {d: 4}]}
other := {a: [{c: 3}, {e: 5}]}
_.merge(obj, other)
; => {a: [{b: 2, c: 3}, {d: 4, e: 5}]}

```



## .set
Sets the value at `path` of `object`. If a portion of `path` doesn't exist, it's created. Objects are created for all missing properties.

> [!Note]
> This method mutates `object`.

#### Arguments
object (Object): The object to modify.

path (Array|string): The path of the property to set.

value (*): The value to set.

#### Returns
(Object): Returns object.


#### Example

```autohotkey
obj := {a: [{b: {c: 3}}]}
_.set(obj, "a[1].b.c", 4)
assert.test(obj.a[1].b.c, 4)
_.set(obj, ["x", "1", "y", "z"], 5)
assert.test(obj.x[1].y.z, 5)
```




# **String methods**
## .endsWith
Checks if `string` ends with the given target string.


#### Arguments
string (string): The string to inspect.

[target] (string): The string to search for.

[position:=strLen()] (number): The position to search up to.


#### Returns
(boolean): Returns true if string ends with target, else false.


#### Example

```autohotkey
_.endsWith("abc", "c")
; => true

_.endsWith("abc", "b")
; => false

_.endsWith("abc", "b", 2)
; => true

```



## .escape
Converts the characters "&", "<", ">", '"', and "'" in `string` to their corresponding HTML entities.

> [!Note]
> No other characters are escaped. To escape additional characters use a third-party library.

Though the ">" character is escaped for symmetry, characters like ">" and "/" don't need escaping in HTML and have no special meaning unless they're part of a tag or unquoted attribute value. See Mathias [Bynens's article](https://mathiasbynens.be/notes/ambiguous-ampersands) (under "semi-related fun fact") for more details.

When working with HTML you should always quote attribute values to reduce XSS vectors.


#### Arguments
[string:=""] (string): The string to escape.


#### Returns
(string): Returns the escaped string.


#### Example

```autohotkey
str := "neo, morpheus, & trinity"
_.escape(str)
; => "neo, morpheus, &amp; trinity"

```



## .lowerFirst
Converts the first character of `string` to lower case.


#### Arguments
[string:=""] (string): The string to convert.


#### Returns
(string): Returns the converted string.


#### Example

```autohotkey
_.lowerFirst("Neo")
; => "neo"

_.lowerFirst("FRED")
; => "fRED"

```



## .pad
Pads `string` on the left and right sides if it's shorter than `length`. Padding characters are truncated if they can't be evenly divided by length.

#### Arguments
[string:=""] (string): The string to pad.

[length:=0] (number): The padding length.

[chars:=" "] (string): The string used as padding.


#### Returns
(string): Returns the padded string.


#### Example

```autohotkey
_.pad("abc", 8)
; => "  abc   "

_.pad("abc", 8, "_-")
; => "_-abc_-_"

_.pad("abc", 3)
; => "abc"

```



## .padEnd
Pads `string` on the right side if it's shorter than `length`. Padding characters are truncated if they exceed length.

#### Arguments
[string:=""] (string): The string to pad.

[length:=0] (number): The padding length.

[chars:=" "] (string): The string used as padding.


#### Returns
(string): Returns the padded string.


#### Example

```autohotkey
_.padEnd("abc", 6)
; => "abc   "

_.padEnd("abc", 6, "_-")
; => "abc_-_"

```



## .padStart
Pads `string` on the left side if it's shorter than `length`. Padding characters are truncated if they exceed length.

#### Arguments
[string:=""] (string): The string to pad.

[length:=0] (number): The padding length.

[chars:=" "] (string): The string used as padding.


#### Returns
(string): Returns the padded string.


#### Example

```autohotkey
_.padStart("abc", 6)
; => "   abc"

_.padStart("abc", 6, "_-")
; => "_-_abc"

```



## .parseInt
Converts string to an integer of the specified radix. If radix is `""` undefined or `0`, a radix of `10` is used unless value is a hexadecimal, in which case a radix of `16` is used.

#### Arguments
string (string): The string to convert.

[radix:=10] (number): The radix to interpret value by.


#### Returns

(number): Returns the converted integer.


#### Example

```autohotkey
_.parseInt("08")
; => 8

_.map(["6", "08", "10"], _.parseInt)
; => [6, 8, 10]

```



## .repeat
Repeats the given string `n` times.


#### Arguments
[string:=""] (string): The string to repeat.

[n:=1] (number): The number of times to repeat the string.

#### Returns

(string): Returns the repeated string.


#### Example

```autohotkey
_.repeat("*", 3)
; => "***"

_.repeat("abc", 2)
; => "abcabc"

_.repeat("abc", 0)
; => ""

```



## .startsWith
Checks if `string` starts with the given target string.


#### Arguments
string (string): The string to inspect.

[target] (string): The string to search for.

[position:=1] (number): The position to search from.


#### Returns
(boolean): Returns true if string starts with target, else false.


#### Example

```autohotkey
_.startsWith("abc", "a")
; => true

_.startsWith("abc", "b")
; => false

_.startsWith("abc", "b", 2)
; => true

_.stringCaseSense := true
_.startsWith("abc", "A")
; => false

```



## .toLower
Converts `string`, as a whole, to lower case.


#### Arguments
string (string): The string to convert.


#### Returns
(string): Returns the lower cased string.

#### Example

```autohotkey
_.toLower("--Foo-Bar--")
; => "--foo-bar--"

_.toLower("fooBar")
; => "foobar"

_.toLower("__FOO_BAR__")
; => "__foo_bar__"

```



## .toUpper
Converts `string`, as a whole, to upper case


#### Arguments
string (string): The string to convert.


#### Returns
(string): Returns the upper cased string.

#### Example

```autohotkey
_.toUpper("--foo-bar--")
; => "--FOO-BAR--"

_.toUpper("fooBar")
; => "FOOBAR"

_.toUpper("__foo_bar__")
; => "__FOO_BAR__"

```



## .trim
Removes leading and trailing whitespace or specified characters from `string`.


#### Arguments
[string:=""] (string): The string to trim.

[chars:=whitespace] (string): The characters to trim.


#### Returns
(string): Returns the trimmed string.


#### Example

```autohotkey
_.trim("  abc  ")
; => "abc"

_.trim("-_-abc-_-", "_-")
; => "abc"

_.map([" foo  ", "  bar  "], _.trim)
; => ["foo", "bar"]

```



## .trimEnd
Removes trailing whitespace or specified characters from `string`.


#### Arguments
[string:=""] (string): The string to trim.

[chars:=whitespace] (string): The characters to trim.


#### Returns
(string): Returns the trimmed string.


#### Example

```autohotkey
_.trimEnd("  abc  ")
; => "  abc"

_.trimEnd("-_-abc-_-", "_-")
; => "-_-abc"

```



## .trimStart
Removes leading whitespace or specified characters from `string`.


#### Arguments
[string:=""] (string): The string to trim.

[chars:=whitespace] (string): The characters to trim.


#### Returns
(string): Returns the trimmed string.


#### Example

```autohotkey
_.trimStart("  abc  ")
; => "abc  "

_.trimStart("-_-abc-_-", "_-")
; => "abc-_-"

```



## .truncate
Truncates `string` if it's longer than the given maximum string length. The last characters of the truncated string are replaced with the omission string which defaults to "...".


#### Arguments
[string:=""] (string): The string to truncate.

[options:={}] (Object): The options object.

[options.length:=30] (number): The maximum string length.

[options.omission:="..."] (string): The string to indicate text is omitted.

[options.separator] (RegExp|string): The separator pattern to truncate to.


#### Returns
(string): Returns the truncated string.


#### Example

```autohotkey
str := "hi-diddly-ho there, neighborino"
_.truncate(str)
; => "hi-diddly-ho there, neighbor..."

_.truncate(str, {length: 24, separator: " "})
; => "hi-diddly-ho there,..."

```



## .unescape
The inverse of [_.escape](#escape) this method converts the HTML entities &amp;, &lt;, &gt;, &quot;, and &#39; in `string` to their corresponding characters.

> [!Note]
> No other HTML entities are unescaped. To unescape additional HTML entities use a dedicated third-party library.

#### Arguments
[string:=""] (string): The string to unescape.


#### Returns
(string): Returns the unescaped string.


#### Example

```autohotkey
str := "neo, morpheus, &amp; trinity"
_.unescape(str)
; => "neo, morpheus, & trinity"

```



## .upperFirst
Converts the first character of `string` to upper case.


#### Arguments
[string:=""] (string): The string to convert.


#### Returns
(string): Returns the converted string.


#### Example

```autohotkey
_.upperFirst("neo")
; => "Neo"

_.upperFirst("FRED")
; => "FRED"

```



## .words
Splits `string` into an array of its words.


#### Arguments
string:="" (string): The string to inspect.

[pattern] (RegExp|string): The pattern to match words.


#### Returns

(Array): Returns the words of string.


#### Example

```autohotkey
_.words("neo, morpheus, & trinity")
; => ["neo", "morpheus", "trinity"]

_.words("neo, morpheus, & trinity", "[^, ]+")
; => ["neo", "morpheus", "&", "trinity"]

```




# **Util methods**
## .identity
This method returns the first argument it receives.

#### Arguments
value (*): Any value.


#### Returns
(*): Returns value.


#### Example

```autohotkey
obj := {a: 1}
_.identity(obj)
; => {a: 1}

(_.identity(obj) == obj)
; => true

```



## .times
Invokes the `iteratee` `n` times, returning an array of the results of each invocation. The iteratee is invoked with one argument; (index).


#### Arguments
n (number): The number of times to invoke iteratee.

[iteratee:=.identity] (Function): The function invoked per iteration.


#### Returns
(Array): Returns the array of results.

#### Example
```autohotkey
_.times(4)
; => [1, 2, 3, 4]
```




## .toPath
Converts `value` to a property path array.


#### Arguments
value (*): The value to convert.


#### Returns
(Array): Returns the new property path array.


#### Example

```autohotkey
_.toPath("a.b.c")
; => ["a", "b", "c"]

_.toPath("a[1].b.c")
; => ["a", "1", "b", "c"]

```
