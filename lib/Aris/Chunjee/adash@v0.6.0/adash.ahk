class adash {
	; --- Static Variables ---
	static stringCaseSense := false
	static throwExceptions := true
	; --- Guarded Methods ---
	static _guarded := map(this.prototype.__class ".trim", { maxParams: 1, type: "self" }
		, this.prototype.__class ".trimEnd", { maxParams: 1, type: "self" }
		, this.prototype.__class ".trimStart", { maxParams: 1, type: "self" }
		, this.prototype.__class ".parseInt", { maxParams: 1, type: "self" }
		, this.prototype.__class ".chunk", { maxParams: 1, type: "self" }
		, this.prototype.__class ".take", { maxParams: 1, type: "self" }
		, this.prototype.__class ".takeRight", { maxParams: 1, type: "self" }
		, this.prototype.__class ".parseInt", { maxParams: 1, type: "self" }
		, this.prototype.__class ".drop", { maxParams: 1, type: "self" }
		, this.prototype.__class ".sampleSize", { maxParams: 1, type: "self" }
		, this.prototype.__class ".words", { maxParams: 1, type: "self" }
		, this.prototype.__class ".random", { maxParams: 1, type: "self" }
		, "Trim", { maxParams: 1, type: "function" }
		, "LTrim", { maxParams: 1, type: "function" }
		, "RTrim", { maxParams: 1, type: "function" })
	; --- Static Methods ---
	static chunk(param_array,param_size:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string"], param_size, ["integer"])
		}
		l_array := []
		if (this.isString(param_array)) {
			param_array := strSplit(param_array)
		} else {
			param_array := this.clone(param_array)
		}
		while (param_array.length > 0) {
			l_innerArr := []
			loop (param_size) {
				if (param_array.length == 0) {
					break
				}
				l_innerArr.push(param_array.removeAt(1))
			}
		l_array.push(l_innerArr)
		}
		return l_array
	}
	static compact(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := []
		for key, value in param_array {
			if (!isSet(value)) {
				continue
			}
			switch (value) {
				case false:
					continue
				case "":
					continue
			}
			l_array.push(value)
		}
		return l_array
	}
	static depthOf(param_array,param_depth:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"], param_depth, ["integer"])
		}
		if (param_array.hasProp("__Item")) {
			for key, value in param_array {
				if (isObject(value)) {
					param_depth := this.depthOf(value, param_depth + 1)
				}
			}
		} else {
			for key, value in param_array.ownProps() {
				if (isObject(value)) {
					param_depth := this.depthOf(value, param_depth + 1)
				}
			}
		}
		return param_depth
	}
	static difference(param_array,param_values*) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := this.clone(param_array)
		for key, value in param_values {
			for key2, value2 in value {
				while ((foundIndex := this.indexOf(l_array, value2)) != -1) {
					l_array.removeAt(foundIndex)
				}
			}
		}
		return l_array
	}
	static drop(param_array,param_n:=1) {
		if (this.throwExceptions) {
		}
		switch (type(param_array)) {
			case "Array":
				l_array := this.clone(param_array)
			default:
				l_array := strSplit(param_array)
		}
		if (l_array.length == 0 || param_array == "") {
			return []
		}
		if (param_n == 0) {
			return param_array
		}
		param_n := this.clamp(param_n, 1, l_array.length)
		l_array.removeAt(1, param_n)
		return l_array
	}
	static dropRight(param_array,param_n:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_n, ["integer"])
		}
		if (isObject(param_array)) {
			l_array := param_array.clone()
		} else {
			l_array := strSplit(param_array)
		}
		if (l_array.length == 0) {
			return []
		}
		param_n := this.clamp(param_n, 0, l_array.length)
		loop (param_n) {
			l_array.removeAt(l_array.length)
		}
		if (l_array.length == 0) {
			return []
		}
		return l_array
	}
	static fill(param_array,param_value:="",param_start:=1,param_end:=-1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"], param_start, ["integer"]
				, param_end, ["integer"])
		}
		if (param_end == -1) {
			param_end := param_array.length + 1
		}
		for key, value in param_array {
			if (key >= param_start && key < param_end) {
				param_array[key] := param_value
			}
		}
		return param_array
	}
	static flatten(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_obj := []
		for index, obj in param_array {
			if (isObject(obj)) {
				for index2, object2 in obj {
					l_obj.push(object2)
				}
			} else {
				l_obj.push(obj)
			}
		}
		return l_obj
	}
	static flattenDeep(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "object"])
		}
		flattenedArray := []
		if (param_array.hasProp("__Item")) {
			for key, value in param_array {
				if (isObject(value)) {
					flattenedArray.push(this.flattenDeep(value)*)
				} else {
					flattenedArray.push(value)
				}
			}
		} else {
			for key, obj in param_array.ownProps() {
				if (isObject(obj)) {
					flattenedArray.push(this.flatten(obj)*)
				} else {
					flattenedArray.push(obj)
				}
			}
		}
		return flattenedArray
	}
	static flattenDepth(param_array,param_depth:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"], param_depth, ["integer"])
		}
		l_obj := this.cloneDeep(param_array)
		loop (param_depth) {
			l_obj := this.flatten(l_obj)
		}
		return l_obj
	}
	static fromPairs(param_pairs) {
		if (this.throwExceptions) {
			this._validateTypes(param_pairs, ["array"])
		}
		l_obj := {}
		for key, value in param_pairs {
			l_obj.%value[1]% := value[2]
		}
		return l_obj
	}
	static head(param) {
		if (this.isObject(param) && param.hasProp("__Item")) {
			return (param.length > 0) ? param[1] : ""
		} else if (this.isObject(param) && !param.hasProp("__Item")) {
			for key, value in param.ownProps() {
				return value
			}
		} else if (this.isString(param) || this.isNumber(param) || param == "") {
			return subStr(param, 1, 1)
		}
	}
	static indexOf(param_array,param_value,param_fromIndex:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, [isObject, "string"], param_fromIndex, ["integer"])
		}
		switch (type(param_array)) {
			case "String":
				param_array := strSplit(param_array)
		}
		if (isObject(param_value)) {
			param_value := this._hash(param_value)
			param_array := this.map(param_array, this._hash)
		}
		if (param_fromIndex < 0) {
			param_fromIndex := this.size(param_array) + param_fromIndex + 1
			if (param_fromIndex < 1) {
				param_fromIndex := 1
			}
		}
		if (isObject(param_array) && param_array.hasProp("__Item")) {
			for key, value in param_array {
				if (A_Index < param_fromIndex) {
					continue
				}
				if (isObject(value) && isObject(param_value)) {
					if (this.isEqual(value, param_value)) {
						return key
					}
				} else if (value == param_value) {
					return key
				}
			}
		} else {
			for key, value in param_array.ownProps() {
				if (A_Index < param_fromIndex) {
					continue
				}
				if (isObject(value) && isObject(param_value)) {
					if (this.isEqual(value, param_value)) {
						return key
					}
				} else if (value == param_value) {
					return key
				}
			}
		}
		return -1
	}
	static initial(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"])
		}
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		} else {
			l_array := strSplit(param_array)
		}
		if (l_array.length == 0) {
			return []
		}
		return this.dropRight(l_array)
	}
	static intersection(param_arrays*) {
		tempArray := this.cloneDeep(param_arrays[1])
		param_arrays.removeAt(1)
		l_array := []
		for key, value in tempArray {
			for key2, value2 in param_arrays {
				if (this.indexOf(value2, value) != -1) {
					found := true
				} else {
					found := false
					break
				}
			}
			if (found && this.indexOf(l_array, value) == -1) {
				l_array.push(value)
			}
		}
		return l_array
	}
	static join(param_array,param_separator:=",") {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "object", "string"], param_separator, ["string"])
		}
		if (this.isString(param_array)) {
			param_array := strSplit(param_array)
		}
		output := ""
		if (param_array.hasProp("__Item")) {
			for key, value in param_array {
				output .= (value ?? "") param_separator
			}
		} else {
			for key, value in param_array.ownProps() {
				output .= (value ?? "") param_separator
			}
		}
		return (len := strLen(param_separator)) ? subStr(output, 1, -len) : output
	}
	static last(param_array) {
		if (!isObject(param_array)) {
			param_array := strSplit(param_array)
		}
		if (param_array.length == 0) {
			return ""
		}
		return param_array[param_array.length]
	}
	static lastIndexOf(param_array,param_value,param_fromIndex:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_fromIndex, ["integer"])
		}
		if (this.isString(param_array) || this.isInteger(param_array)) {
			param_array := strSplit(param_array)
		}
		if (param_fromIndex == 0 || param_fromIndex > param_array.length - 1) {
			param_fromIndex := param_array.length - 1
		}
		index := param_fromIndex
		while (index >= 0) {
			if (this.isEqual(param_array[index + 1], param_value)) {
				return index + 1
			}
			index -= 1
		}
		return -1
	}
	static nth(param_array,param_n:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_n, ["integer"])
		}
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		} else {
			l_array := strSplit(param_array)
		}
		if (param_n == 0) {
			param_n := 1
		}
		if (l_array.length < param_n) {
			return ""
		}
		if (param_n > 0) {
			return l_array[param_n]
		}
		if (l_array.length == 0) {
			return ""
		}
		l_array := this.reverse(l_array)
		param_n := 0 - param_n
		return this.nth(l_array, param_n)
	}
	static reverse(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_collection := this.cloneDeep(param_array)
		l_array := []
		while (l_collection.length != 0) {
			l_array.push(l_collection.pop())
		}
		return l_array
	}
	static slice(param_array,param_start:=1,param_end:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_start, ["integer"]
				, param_end, ["integer"])
		}
		if (!isObject(param_array)) {
			param_array := strSplit(param_array)
		}
		if (param_end == 0) {
			param_end := param_array.length
		}
		l_array := []
		for key, value in param_array {
			if (A_Index >= param_start && A_Index <= param_end) {
				l_array.push(value)
			}
		}
		return l_array
	}
	static sortedIndex(param_array,param_value) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		if (param_value < param_array[1]) {
			return 1
		}
		loop param_array.length - 1 {
			if (param_array[A_Index] <= param_value && param_value < param_array[A_Index + 1]) {
				return A_Index + 1
			}
		}
		return param_array.length + 1
	}
	static sortedUniq(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := []
		l_temp := ""
		for key, value in param_array {
			printedelement := this._stringify(param_array[key])
			if (!this.isEqual(l_temp, printedelement)) {
				l_temp := printedelement
				l_array.push(value)
			}
		}
		return l_array
	}
	static tail(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"])
		}
		return this.drop(param_array)
	}
	static take(param_array,param_n:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_n, ["integer"])
		}
		if (this.isString(param_array) || this.isNumber(param_array)) {
			l_array := []
			loop parse, (param_array) {
				if (A_Index > param_n) {
					break
				}
				l_array.push(a_loopfield)
			}
			return l_array
		}
		if this.isObject(param_array) && param_array.hasProp("__Item") {
			param_array := this.clone(param_array)
		}
		param_n := min(param_n, param_array.length)
		l_array := []
		for index, value in param_array {
			if (a_index > param_n) {
				break
			}
			l_array.push(value)
		}
		return l_array
	}
	static takeRight(param_array,param_n:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array", "string", "integer"], param_n, ["integer"])
		}
		if (isObject(param_array)) {
			param_array := this.clone(param_array)
		} else {
			param_array := strSplit(param_array)
		}
		l_array := []
		param_n := this.clamp(param_n, 0, param_array.length)
		loop (param_n) {
			if (param_array.length == 0) {
				break
			}
			value := param_array.pop()
			l_array.push(value)
		}
		if (l_array.length == 0 || param_n == 0) {
			return []
		}
		return this.reverse(l_array)
	}
	static union(param_arrays*) {
		combinedArray := []
		for each, value in param_arrays {
			if (isObject(value)) {
				for key, value2 in value {
					combinedArray.push(value2)
				}
			} else {
				combinedArray.push(value)
			}
		}
		return this.uniq(combinedArray)
	}
	static uniq(param_collection) {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "string", "integer"])
		}
		switch (type(param_collection)) {
			case "Array":
			default:
				param_collection := strSplit(param_collection)
		}
		tempArray := []
		l_array := []
		for key, value in param_collection {
			l_printedElement := this._hash(param_collection[key])
			if (this.indexOf(tempArray, l_printedElement) == -1) {
				tempArray.push(l_printedElement)
				l_array.push(value)
			}
		}
		return l_array
	}
	static unzip(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := []
		group_count := param_array[1].length
		loop (group_count) {
			l_array.push([])
		}
		for index, subarray in param_array {
			for key, value in subarray {
				if (l_array.has(key)) {
					l_array[key].push(value)
				}
			}
		}
		return l_array
	}
	static without(param_array,param_values*) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := this.clone(param_array)
		for index, value in param_values {
			while ((foundIndex := this.indexOf(l_array, value)) != -1) {
				l_array.removeAt(foundIndex)
			}
		}
		return l_array
	}
	static zip(param_arrays*) {
		l_array := []
		shortestLength := 9223372036854775807
		for key, arr in param_arrays {
			if (!isObject(arr)) {
				continue
			}
			shortestLength := min(shortestLength, arr.length)
		}
		loop (shortestLength) {
			currentIndex := A_Index
			zippedGroup := []
			for key, arr in param_arrays {
				if (isObject(arr) && arr.length >= currentIndex) {
					zippedGroup.push(arr[currentIndex])
				} else {
					zippedGroup.push("")
				}
			}
			l_array.push(zippedGroup)
		}
		return l_array
	}
	static zipObject(param_props,param_values) {
		if (this.throwExceptions) {
			this._validateTypes(param_props, ["array"], param_values, ["array"])
		}
		if (!isObject(param_props)) {
			param_props := []
		}
		if (!isObject(param_values)) {
			param_values := []
		}
		l_obj := {}
		for key, value in param_props {
			if (param_values.has(key)) {
				l_obj.%value% := param_values[key]
			} else {
				l_obj.%value% := ""
			}
		}
		return l_obj
	}
	static includes(param_collection,param_value,param_fromIndex:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "string"], param_fromIndex, ["integer"])
		}
		if (isObject(param_value)) {
			param_value := this._hash(param_value)
			param_collection := this.map(param_collection, this._hash)
		}
		if (isObject(param_collection)) {
			for key, value in param_collection {
				if (param_fromIndex > A_Index) {
					continue
				}
				if (this.isEqual(value, param_value)) {
					return true
				}
			}
			return false
		} else {
			if (inStr(param_collection, param_value, this.stringCaseSense, param_fromIndex)) {
				return true
			} else {
				return false
			}
		}
	}
	static _includes(param_collection,param_value) {
		if (isObject(param_collection)) {
			for key, value in param_collection {
				if (value == param_value) {
					return true
				}
			}
			return false
		}
		return (inStr(param_collection, param_value, 0) > 0)
	}
	static map(param_collection,param_iteratee:="__identity") {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "string", "object"], param_iteratee, ["string", this.isFunction])
		}
		if (this.isString(param_collection)) {
			l_collection := strSplit(param_collection)
		} else {
			l_collection := this.cloneDeep(param_collection)
		}
		l_array := []
		valType := type(l_collection)
		switch (valType) {
			case "Object":
				for key, value in l_collection.ownProps() {
					l_array.push(this._applyPredicateForward(value, param_iteratee, key, l_collection))
				}
			default:
				for key, value in l_collection {
					l_array.push(this._applyPredicateForward(value, param_iteratee, key, l_collection))
				}
		}
		return l_array
	}
	static sample(param_collection) {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "string"])
		}
		if (this.isString(param_collection)) {
			param_collection := strSplit(param_collection)
		}
		if (param_collection.length == 0 ) {
			return ""
		}
		l_array := param_collection.clone()
		return l_array[this.random(1, l_array.length)]
	}
	static shuffle(param_collection) {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "object"])
		}
		switch (type(param_collection)) {
			case "Array":
				l_array := this.clone(param_collection)
			case "Object":
				l_array := this.map(param_collection)
		}
		l_index := l_array.length
		loop (l_index - 1) {
			randomIndex := random(1, l_index)
			l_tempVar := l_array[l_index]
			l_array[l_index] := l_array[randomIndex]
			l_array[randomIndex] := l_tempVar
			l_index--
		}
		return l_array
	}
	static size(param_collection) {
		switch type(param_collection), false {
			case "array":
				return param_collection.length
			case "object":
				return objOwnPropCount(param_collection)
			case "string":
				return strLen(param_collection)
			case "float":
				return 0
			case "integer":
				return 0
			default:
				if (param_collection.hasProp("Count")) {
					return param_collection.count
				}
				return 0
		}
		return ""
	}
	static some(param_collection,param_predicate:="__identity") {
		if (this.throwExceptions) {
			this._validateTypes(param_collection, ["array", "object"], param_predicate, ["string", "func"])
		}
		switch (type(param_collection)) {
			case "Object":
				for key, value in param_collection.ownProps() {
					if (this._applyPredicateForward(value, param_predicate, key, param_collection) == true) {
						return true
					}
				}
			default:
				for key, value in param_collection {
					if (this._applyPredicateForward(value, param_predicate, key, param_collection) == true) {
						return true
					}
				}
		}
		return false
	}
	static _applyPredicateForward(param_value,param_predicate,param_args*) {
		if (param_predicate == "__identity") {
			param_predicate := this.identity
		}
		guarded := this._findGuarded(param_predicate)
		switch (guarded.type) {
			case "self":
				switch (guarded.maxParams) {
					case 1:
						return param_predicate.call(this, param_value)
					case 2:
						return param_predicate.call(this, param_value, param_args[1])
					case 3:
						return param_predicate.call(this, param_value, param_args[1], param_args[2])
				}
			case "function":
				switch (guarded.maxParams) {
					case 1:
						return param_predicate.call(param_value)
					case 2:
						return param_predicate.call(param_value, param_args[1])
					case 3:
						return param_predicate.call(param_value, param_args[1], param_args[2])
				}
		}
		if (this.includes(param_predicate.name, this.prototype.__class ".")) {
			switch (param_predicate.maxParams) {
				case 2:
					return param_predicate.call(this, param_value)
				case 3:
					return param_predicate.call(this, param_value, param_args[1])
				case 4:
					return param_predicate.call(this, param_value, param_args[1], param_args[2])
			}
		}
		switch (param_predicate.maxParams) {
			case 1:
				return param_predicate.call(param_value)
			case 2:
				return param_predicate.call(param_value, param_args[1])
			case 3:
				return param_predicate.call(param_value, param_args[1], param_args[2])
		}
		return param_predicate.call(param_value)
	}
	static _findGuarded(param_target) {
		if (type(param_target) == "Func") {
			if (this._guarded.has(param_target.name)) {
				return this._guarded[param_target.name]
			}
		}
		return {type: "none"}
	}
	static _hash(dataArray) {
		dataArray := strSplit(this.toString(dataArray))
		data := ""
		for index, value in dataArray {
			if isObject(value) {
				for key, val in value {
					data .= key . val
				}
			} else {
				data .= value
			}
		}
		hash := 0
		for index, char in strSplit(data) {
			hash := (hash * 31) ^ ord(char)
		}
		return format("{:08X}", hash & 0xFFFFFFFF)
	}
	static _isFalsey(param_value?) {
		if (isSet(param_value)) {
			switch (param_value) {
				case "":
					return true
				case false:
					return true
			}
		} else {
			return true
		}
		return false
	}
	static _stringify(param_value?) {
		if (!IsSet(param_value)) {
			return "unset"
		}
		paramValueType := type(param_value)
		switch paramValueType, false {
			case "string":
				return "'" param_value "'"
			case "integer", "float":
				return param_value
			default:
				selfValue := "", iterValue := "", outValue := ""
				try selfValue := this.toString(param_value.ToString())
				if (paramValueType = "object") {
					for key, value in param_value.OwnProps() {
						iterValue .= key ": " this._stringify(value) ", "
					}
					iterValue := rTrim(iterValue, ", ")
				} else if (paramValueType != "Array") {
					try {
						enumValue := param_value.__Enum(2)
						while (enumValue.Call(&enumVal1, &enumVal2)) {
							iterValue .= this._stringify(enumVal1) ": " this._stringify(enumVal2?) ", "
						}
					}
				}
				if (!IsSet(enumValue) && paramValueType != "object") {
					try {
						enumValue := param_value.__Enum(1)
						while (enumValue.Call(&enumVal)) {
							iterValue .= this._stringify(enumVal?) ", "
						}
					}
				}
				iterValue := RTrim(iterValue, ", ")
				if (!selfValue && !iterValue && !((paramValueType = "array" && param_value.Length = 0) || (paramValueType = "Map" && param_value.Count = 0) || (paramValueType = "Object" && ObjOwnPropCount(param_value) = 0))) {
					return paramValueType
				} else if (selfValue && iterValue) {
					outValue .= "value:" selfValue ", iter:[" iterValue "]"
				} else {
					outValue .= selfValue iterValue
				}
				return (paramValueType = "object") ? "{" outValue "}" : (paramValueType = "Array") ? "[" outValue "]" : paramValueType "(" outValue ")"
		}
	}
	static _throwTypeException(param_received:="",param_expectedType:="") {
		throw valueError("Type Error", -3, "Expected: (" this._formatTypeNames(param_expectedType) ") but received (" type(param_received) ")")
	}
	static _formatTypeNames(typeArray) {
		formattedTypes := []
		for _, typeCheck in typeArray {
			if this.isFunction(typeCheck) {
				typeName := this.last(strSplit(typeCheck.name, "is"))
				formattedTypes.push(this.upperFirst(typeName))
			} else if this.isString(typeCheck) {
				formattedTypes.push(this.upperFirst(typeCheck))
			}
		}
		return this.join(formattedTypes, "|")
	}
	static _validateTypes(param_input*) {
		for key, value in param_input {
			if (mod(key, 2) != 0) {
				valid_types := param_input[key + 1]
				current_type := strLower(type(value))
				is_valid := false
				for key, type_check in valid_types {
					if (this.isString(type_check) && current_type = type_check) {
						is_valid := true
						break
					} else if (this.isFunction(type_check)) {
						if (this._includes(type_check.name, this.prototype.__class ".")) {
							if (type_check(this, value)) {
								is_valid := true
								break
							}
							continue
						}
						if (type_check(value)) {
							is_valid := true
							break
						}
					}
				}
				if (!is_valid) {
					this._throwTypeException(value, valid_types)
				}
			}
		}
	}
	static clone(param_value) {
		if (isObject(param_value)) {
			newObj := param_value.clone()
			for key, value in param_value {
				newObj[key] := value
			}
			return newObj
		} else {
			return param_value
		}
	}
	static cloneDeep(param) {
		if (!isObject(param)) {
			return param
		}
		if (param.hasProp("__Item")) {
			clone := []
			for value in param {
				clone.push(this.cloneDeep(value))
			}
		} else {
			clone := {}
			for key, value in param.OwnProps() {
				clone.%key% := this.cloneDeep(value)
			}
		}
		return clone
	}
	static isAlnum(param) {
		if (type(param) == "String") {
			if (isAlnum(param)) {
				return true
			}
		}
		return false
	}
	static isArray(param) => (type(param) == "Array")
	static isBoolean(param) => (this.includes([true, false], param))
	static isBuffer(param_value) => (type(param_value) == "Buffer")
	static isEmpty(param_value) {
		if (isSet(param_value)) {
			switch (type(param_value)) {
				case "Array":
					return (param_value.length == 0)
				case "Object":
					return (ObjGetCapacity(param_value) == 0)
				case "Map":
					return (param_value.count == 0)
				default:
					return false
			}
		}
		return false
	}
	static isEqual(param_value,param_other*) {
		if (isObject(param_value)) {
			l_array := this.map(param_other, this._stringify)
			param_value := this._stringify(param_value)
		} else {
			l_array := this.cloneDeep(param_other)
		}
		if (this.isNumber(param_value)) {
			for key, value in l_array {
				if (param_value != value) {
					return false
				}
			}
			return true
		}
		for key, value in l_array {
			if (isObject(value)) {
				value := this._stringify(value)
				msgbox(value)
			}
			if (strCompare(param_value, value, this.stringCaseSense) != 0) {
				return false
			}
		}
		return true
	}
	static isFloat(param) => (type(param) == "Float")
	static isFunction(param) => (this.includes(["BoundFunc", "Func", "Closure"], type(param)))
	static isInteger(param) => (type(param) == "Integer")
	static isMap(param_value?) => (type(param_value) == "Map")
	static isMatch(param_object,param_source) {
		if (param_source.hasProp("__Item")) {
			for key, value in param_source {
				if (value == param_object[key]) {
					continue
				} else {
					return false
				}
			}
		} else {
			for key, value in param_source.ownProps() {
				if (!param_object.hasProp(key)) {
					return false
				}
				if (value == param_object.%key%) {
					continue
				} else {
					return false
				}
			}
		}
		return true
	}
	static isNative(param_value) {
		if (this.isFunction(param_value)) {
			if (param_value.IsBuiltIn == true) {
				return true
			}
		}
		return false
	}
	static isNumber(param) => isNumber(param)
	static isObject(param) => isObject(param)
	static isString(param) => (type(param) == "String")
	static isUndefined(param_value) => (!isSet(param_value))
	static toString(param_value) {
		if (isObject(param_value)) {
			return this.join(param_value, ",")
		} else {
			return "" param_value
		}
	}
	static typeOf(param_value?) => this.toLower(type(param_value))
	static add(param_augend,param_addend) {
		if (this.throwExceptions) {
			this._validateTypes(param_augend, [isNumber], param_addend, [isNumber])
		}
		return param_augend + param_addend
	}
	static ceil(param_number,param_precision:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_number, [isNumber], param_precision, [isNumber])
		}
		if (param_precision == 0) {
			return ceil(param_number)
		}
		l_offset := 0.5 / (10 ** param_precision)
		if (param_number < 0 && param_precision >= 1) {
			l_offset /= 10
		}
		l_sum := (param_precision >= 1)
			? format("{:." max(strLen(subStr(param_number, inStr(param_number, ".") + 1))) + 1 "f}", param_number + l_offset)
			: param_number + l_offset
		l_sum := trim(l_sum, "0")
		l_value := (subStr(l_sum, 0) = "5" && param_number != l_sum) ? subStr(l_sum, 1, -1) : l_sum
		return round(l_value, param_precision)
	}
	static divide(param_dividend,param_divisor) {
		if (this.throwExceptions) {
			this._validateTypes(param_dividend, [IsNumber], param_divisor, [isNumber])
		}
		if (param_divisor == 0) {
			return ""
		}
		return param_dividend / param_divisor
	}
	static floor(param_number,param_precision:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_number, [isNumber], param_precision, [isNumber])
		}
		if (param_precision == 0) {
			return floor(param_number)
		}
		l_offset := -0.5 / (10**param_precision)
		if (param_number < 0 && param_precision >= 1) {
			l_offset /= 10
		}
		if (param_precision >= 1) {
			l_decChar := strLen( substr(param_number, inStr(param_number, ".") + 1) )
			l_sum := format("{:." this.max([l_decChar, param_precision]) + 1 "f}", param_number + l_offset)
		} else {
			l_sum := param_number + l_offset
		}
		l_sum := trim(l_sum, "0")
		l_value := (subStr(l_sum, 0) = "5") && param_number != l_sum ? subStr(l_sum, 1, -1) : l_sum
		return round(l_value, param_precision)
	}
	static max(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := []
		for key, value in param_array {
			if (!isSet(value)) {
				continue
			}
			switch (value) {
				case "":
					continue
			}
			l_array.push(value)
		}
		if (l_array.length == 0) {
			return ""
		}
		return max(l_array*)
	}
	static mean(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		return this.sum(param_array) / this.size(param_array)
	}
	static min(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, ["array"])
		}
		l_array := []
		for key, value in param_array {
			if (!isSet(value)) {
				continue
			}
			switch (value) {
				case "":
					continue
			}
			l_array.push(value)
		}
		if (l_array.length == 0) {
			return ""
		}
		return min(l_array*)
	}
	static multiply(param_multiplier,param_multiplicand) {
		if (this.throwExceptions) {
			this._validateTypes(param_multiplier, [isNumber], param_multiplicand, [isNumber])
		}
		return param_multiplier * param_multiplicand
	}
	static round(param_number,param_precision:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_number, [isNumber], param_precision, [isNumber])
		}
		return round(param_number, param_precision)
	}
	static subtract(param_minuend,param_subtrahend) {
		if (this.throwExceptions) {
			this._validateTypes(param_minuend, [isNumber], param_subtrahend, [isNumber])
		}
		return param_minuend - param_subtrahend
	}
	static sum(param_array) {
		if (this.throwExceptions) {
			this._validateTypes(param_array, [isObject])
		}
		vSum := 0
		if (param_array.hasProp("__Item")) {
			for key, value in param_array {
				if (isSet(value)) {
					vSum += value
				}
			}
		}
		return vSum
	}
	static clamp(param_number,param_lower,param_upper) {
		if (this.throwExceptions) {
			this._validateTypes(param_number, [isNumber], param_lower, [isNumber]
				, param_upper, [isNumber])
		}
		if (param_number < param_lower) {
			param_number := param_lower
		}
		if (param_number > param_upper) {
			param_number := param_upper
		}
		return param_number
	}
	static inRange(param_number,param_start:=0,param_end:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_number, [isNumber], param_start, [isNumber]
				, param_end, ["string", isNumber])
		}
		if (param_end == "") {
			param_end := param_start
			param_start := 0
		}
		if (param_start > param_end) {
			l_temp := param_start
			param_start := param_end
			param_end := l_temp
		}
		if (param_number >= param_start && param_number < param_end) {
			return true
		}
		return false
	}
	static random(param_lower:=0,param_upper:=1,param_floating:=false) {
		if (this.throwExceptions) {
			this._validateTypes(param_lower, [isNumber], param_upper, [isNumber]
				, param_floating, [this.isBoolean])
		}
		if (param_lower == true && param_upper == 1 && param_floating == false) {
			param_lower := 0
			param_floating := true
		}
		if (param_lower > param_upper) {
			l_temp := param_lower
			param_lower := param_upper
			param_upper := l_temp
		}
		if (param_floating) {
			param_lower += 0.0
			param_upper += 0.0
		}
		return random(param_lower, param_upper)
	}
	static get(paramObject,paramPath,param_defaultValue:="") {
		if (this.throwExceptions) {
			this._validateTypes(paramObject, [isObject], paramPath, ["string", isObject])
		}
		if (!isObject(paramPath)) {
			paramPath := this.toPath(paramPath)
		}
		currentValue := paramObject
		for key, part in paramPath {
			switch (type(currentValue)) {
				case "Object":
					if (currentValue.hasOwnProp(part)) {
						currentValue := currentValue.%part%
					} else {
						return param_defaultValue
					}
				default:
					if (currentValue.has(part)) {
						currentValue := currentValue[part]
					} else {
						return param_defaultValue
					}
			}
		}
		return currentValue
	}
	static has(paramObject,paramPath,param_defaultValue:="") {
		if (this.throwExceptions) {
			this._validateTypes(paramObject, [isObject], paramPath, ["string", isObject])
		}
		if (!isObject(paramPath)) {
			paramPath := this.toPath(paramPath)
		}
		currentValue := paramObject
		for key, part in paramPath {
			switch (type(currentValue)) {
				case "Object":
					if (currentValue.hasOwnProp(part)) {
						currentValue := currentValue.%part%
					} else {
						return false
					}
				default:
					if (currentValue.has(part)) {
						currentValue := currentValue[part]
					} else {
						return false
					}
			}
		}
		return true
	}
	static hasIn(paramObject,paramPath,param_defaultValue:="") {
		if (this.throwExceptions) {
			this._validateTypes(paramObject, [isObject], paramPath, ["string", isObject])
		}
		if (!isObject(paramPath)) {
			paramPath := this.toPath(paramPath)
		}
		currentValue := paramObject
		for key, part in paramPath {
			switch (type(currentValue)) {
				case "Object":
					if (currentValue.hasProp(part)) {
						currentValue := currentValue.%part%
					} else {
						return false
					}
				default:
					if (currentValue.has(part)) {
						currentValue := currentValue[part]
					} else {
						return false
					}
			}
		}
		return true
	}
	static merge(param_collections*) {
		result := param_collections[1]
		for index, obj in param_collections {
			if (A_Index == 1) {
				continue
			}
			result := this._merge(result, obj)
		}
		return result
	}
	static _merge(param_value1, param_value2) {
		if (!isObject(param_value1) && !isObject(param_value2)) {
			if this.isUndefined(param_value1) {
				return param_value2
			}
			if this.isUndefined(param_value2) {
				return param_value1
			}
			return param_value2
		}
		combined := isObject(param_value1) ? this.cloneDeep(param_value1) : {}
		switch type(param_value1) {
			case "Object":
				if (param_value2.hasProp("__Item")) {
					for key, value in param_value2 {
						if combined.hasProp(key) {
							combined.%key% := this._merge(combined.%key%, value)
						} else {
							combined.%key% := value
						}
					}
				} else {
					for key, value in param_value2.ownProps() {
						if combined.hasProp(key) {
							combined.%key% := this._merge(combined.%key%, value)
						} else {
							combined.%key% := value
						}
					}
				}
			default:
				if (param_value2.hasProp("__Item")) {
					for key, value in param_value2 {
						if (combined.has(key)) {
							combined[key] := this._merge(combined[key], value)
						} else {
							combined.push(value)
						}
					}
				} else {
					for key, value in param_value2.ownProps() {
						if (combined.has(key)) {
							combined[key] := this._merge(combined[key], value)
						} else {
							combined.push(value)
						}
					}
				}
		}
		return combined
	}
	static set(paramObject,paramPath,paramValue) {
		if (this.throwExceptions) {
			this._validateTypes(paramObject, [isObject], paramPath, ["string", isObject, "integer"])
		}
		if (!isObject(paramPath)) {
			paramPath := this.toPath(paramPath)
		}
		currentObject := paramObject
		for key, part in paramPath {
			if (key = paramPath.length) {
				switch (type(currentObject)) {
					case "Object":
						currentObject.%part% := paramValue
					case "Array":
						currentObject.insertAt(part, paramValue)
					case "Map":
						currentObject.set(part, paramValue)
				}
			} else {
				switch (type(currentObject)) {
					case "Object":
						if (!currentObject.hasOwnProp(part)) {
							currentObject.%part% := isInteger(paramPath[key + 1]) ? [] : {}
						}
						currentObject := currentObject.%part%
					case "Array":
						if (part >= currentObject.length) {
							loop (part - currentObject.length) {
								currentObject.push({})
							}
						}
						if (!IsObject(currentObject[part])) {
							currentObject[part] := isInteger(paramPath[key + 1]) ? [] : {}
						}
						currentObject := currentObject[part]
				}
			}
		}
		return paramObject
	}
	static endsWith(param_string,param_needle,param_fromIndex:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"], param_needle, ["string"]
				, param_fromIndex, [isNumber])
		}
		if (param_fromIndex == 0) {
			param_fromIndex := strLen(param_string)
		}
		if (strLen(param_needle) > 1) {
			param_fromIndex := strLen(param_string) - strLen(param_needle) + 1
		}
		l_endChar := subStr(param_string, param_fromIndex, strLen(param_needle))
		if (this.isEqual(l_endChar, param_needle)) {
			return true
		}
		return false
	}
	static escape(param_string:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"])
		}
		HTMLmap := [["&","&amp;"], ["<","&lt;"], [">","&gt;"], ["`"","&quot;"], ["'","&#39;"]]
		for key, value in HTMLmap {
			param_string := strReplace(param_string, value[1], value[2], true, , -1)
		}
		return param_string
	}
	static lowerFirst(param_string := "") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"])
		}
		if (param_string == "") {
			return ""
		}
		firstChar := subStr(param_string, 1, 1)
		restOfString := subStr(param_string, 2)
		return StrLower(firstChar) . restOfString
	}
	static pad(param_string:="",param_length:=0,param_chars:=" ") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"], param_length, [isNumber]
				, param_chars, ["string"])
		}
		if (param_length <= strLen(param_string)) {
			return param_string
		}
		param_length := param_length - strLen(param_string)
		l_start := floor(param_length / 2)
		l_end := ceil(param_length / 2)
		l_start := this.padStart("", l_start, param_chars)
		l_end := this.padEnd("", l_end, param_chars)
		return l_start param_string l_end
	}
	static padEnd(param_string:="",param_length:=0,param_chars:=" ") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"], param_length, [isNumber]
				, param_chars, ["string"])
		}
		stringLength := strLen(param_string)
		if (param_length <= stringLength) {
			return param_string
		}
		padLength := param_length - stringLength
		padChars := param_chars
		while (strLen(padChars) < padLength) {
			padChars .= padChars
		}
		return param_string . subStr(padChars, 1, padLength)
	}
	static padStart(param_string:="",param_length:=0,param_chars:=" ") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"], param_length, [isNumber]
				, param_chars, ["string"])
		}
		stringLength := strLen(param_string)
		if (param_length <= stringLength) {
			return param_string
		}
		padLength := param_length - stringLength
		padChars := param_chars
		while (strLen(padChars) < padLength) {
			padChars .= padChars
		}
		return subStr(padChars, 1, padLength) . param_string
	}
	static parseInt(param_string,param_radix:=0) {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer"], param_radix, [isNumber])
		}
		inputString := "" param_string
		inputString := this.trimStart(inputString, A_Tab A_Space)
		sign := 1
		if (inputString != "" && subStr(inputString, 1, 1) == "-") {
			sign := -1
			inputString := subStr(inputString, 2)
		} else if (inputString != "" && subStr(inputString, 1, 1) == "+") {
			inputString := subStr(sign, 2)
		}
		radix := round(param_radix)
		stripPrefix := true
		if (radix == 0) {
			radix := 10
		} else {
			if (radix < 2 || radix > 36) {
				return ""
			}
			if (radix != 16) {
				stripPrefix := false
			}
		}
		if (stripPrefix && strLen(inputString) >= 2 && (subStr(inputString, 1, 2) == "0x" || subStr(inputString, 1, 2) == "0X")) {
			inputString := subStr(inputString, 3)
			radix := 16
		}
		validDigits := ""
		loop (strLen(inputString)) {
			char := subStr(inputString, A_Index, 1)
			if (!inStr(subStr("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 1, radix), char)) {
				break
			}
			validDigits .= char
		}
		if (validDigits == "") {
			return ""
		}
		mathInt := 0
		loop (strLen(validDigits)) {
			digit := subStr(validDigits, A_Index, 1)
			mathInt := mathInt * radix + (("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" ~= "i)" digit) - 1)
		}
		return sign * mathInt
	}
	static repeat(param_string,param_number:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"], param_number, [isNumber])
		}
		if (param_number <= 0) {
			return ""
		}
		return strReplace(format("{:0" param_number "}", 0), "0", param_string)
	}
	static startsWith(param_string,param_needle,param_fromIndex:=1) {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"], param_needle, ["string", "integer"]
				, param_fromIndex, [isNumber])
		}
		l_startString := subStr(param_string, param_fromIndex, strLen(param_needle))
		if (this.isEqual(l_startString, param_needle)) {
			return true
		}
		return false
	}
	static toLower(param_string) {
		return strLower(param_string)
	}
	static toUpper(param_string) {
		return strUpper(param_string)
	}
	static trim(param_string,param_chars:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"], param_chars, ["string", "integer", "float"])
		}
		if (param_chars == "") {
			return this.trim(param_string, "`r`n" A_space A_tab)
		} else {
			l_string := this.trimStart(param_string, param_chars)
			l_string := this.trimEnd(l_string, param_chars)
			return l_string
		}
	}
	static trimEnd(param_string,param_chars:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"], param_chars, ["string", "integer", "float"])
		}
		if (param_chars == "") {
			return rtrim(param_string)
		}
		stringLength := strLen(param_string)
		endIndex := stringLength
		while (endIndex > 0 && inStr(param_chars, subStr(param_string, endIndex, 1))) {
			endIndex--
		}
		return subStr(param_string, 1, endIndex)
	}
	static trimStart(param_string,param_chars := "") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"], param_chars, ["string", "integer", "float"])
		}
		if (param_chars = "") {
			return regexReplace(param_string, "^\s+")
		} else {
			l_array := strSplit(param_chars)
			l_removechars := ""
			for key, value in l_array {
				if (regexMatch(value, "[a-zA-Z0-9]")) {
					l_removechars .= value
				} else {
					l_removechars .= "\" value
				}
			}
			l_pattern := "^[" l_removechars "]+"
			l_pos := regexMatch(param_string, l_pattern, &l_match)
			if (l_pos > 0) {
				return subStr(param_string, l_pos + l_match.len)
			} else {
				return param_string
			}
		}
	}
	static truncate(param_string,param_options:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string", "integer", "float"])
		}
		if (!isObject(param_options)) {
			param_options := {}
			param_options.length := 30
		}
		if (!param_options.hasOwnProp("omission")) {
			param_options.omission := "..."
		}
		if (!param_options.hasOwnProp("separator")) {
			param_options.separator := ""
		}
		if (strLen(param_string) < param_options.length && !param_options.separator) {
			return param_string
		}
		l_string := subStr(param_string, 1, param_options.length)
		if (param_options.separator) {
			return regexReplace(l_string, "^(.{1," param_options.length "})" param_options.separator ".*$", "$1") param_options.omission
		}
		if (strLen(l_string) < strLen(param_string)) {
			l_string := subStr(l_string, 1, (strLen(l_string) - strLen(param_options.omission) + 1))
			l_string := l_string . param_options.omission
		}
		return l_string
	}
	static unescape(param_string:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"])
		}
		HTMLmap := [["&","&amp;"], ["<","&lt;"], [">","&gt;"], ["`"","&quot;"], ["'","&#39;"]]
		for key, value in HTMLmap {
			param_string := strReplace(param_string, value[2], value[1], true, , -1)
		}
		return param_string
	}
	static upperFirst(param_string:="") {
		return this.toUpper(subStr(param_string, 1, 1)) subStr(param_string, 2)
	}
	static words(param_string,param_pattern:="") {
		if (this.throwExceptions) {
			this._validateTypes(param_string, ["string"], param_pattern, ["string"])
		}
		if (param_pattern == "") {
			param_pattern := "\b\w+(?:'\w+)?\b"
		}
		localString := param_string
		localArray := []
		while (regexMatch(localString, param_pattern, &reMatch)) {
			localArray.push(reMatch[0])
			localString := subStr(localString, reMatch.pos + reMatch.len)
		}
		return localArray
	}
	static identity(param_value) => param_value
	static times(param_n,param_iteratee:="__identity") {
		if (this.throwExceptions) {
			this._validateTypes(param_n, [this.isNumber], param_iteratee, [this.isFunction, "string"])
		}
		l_array := []
		if (param_iteratee == "__identity") {
			param_iteratee := this.identity
		}
		loop (param_n) {
			l_array.push(this._applyPredicateForward(A_Index, param_iteratee))
		}
		return l_array
	}
	static toPath(param_value) {
		if (this.throwExceptions) {
			this._validateTypes(param_value, ["string", isObject, "integer"])
		}
		if (isObject(param_value)) {
			return param_value
		}
		path_parts := []
		current_part := ""
		loop parse, (param_value) {
			char := A_LoopField
			if (char = "." || char = "[") {
				if (current_part != "") {
					path_parts.push(current_part)
					current_part := ""
				}
			} else if (char = "]") {
				if (current_part != "") {
					path_parts.push(current_part)
					current_part := ""
				}
			} else {
				current_part .= char
			}
		}
		if (current_part != "") {
			path_parts.push(current_part)
		}
		return this.compact(path_parts)
	}
	static first(param) {
		if (this.isObject(param) && param.hasProp("__Item")) {
			return (param.length > 0) ? param[1] : ""
		} else if (this.isObject(param) && !param.hasProp("__Item")) {
			for key, value in param.ownProps() {
				return value
			}
		} else if (this.isString(param) || this.isNumber(param) || param == "") {
			return subStr(param, 1, 1)
		}
	}
}
