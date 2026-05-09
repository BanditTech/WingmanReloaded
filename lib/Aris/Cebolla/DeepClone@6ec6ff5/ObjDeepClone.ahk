
/**
 * @description - Recursively copies an object's properties onto a new object. For all new objects,
 * `ObjDeepClone` attempts to set the new object's base to the same base as the subject. For objects
 * that inherit from `Map` or `Array`, clones the items in addition to the properties.
 *
 * This does not deep clone property values that are objects that are not own properties of `Obj`.
 * @example
 * #include <ObjDeepClone>
 * obj := []
 * obj.prop := { prop: 'val' }
 * superObj := []
 * superObj.Base := obj
 * clone := ObjDeepClone(superObj)
 * clone.prop.newProp := 'new val'
 * MsgBox(HasProp(superObj.prop, 'newProp')) ; 1
 * @
 *
 * In the above example we see that the modification made to the object set to `obj.prop` is
 * represented in the object on `superObj.prop`. That is because ObjDeepClone did not clone
 * that object because that object exists on the base of `superObj`, which ObjDeepClone does not
 * touch.
 *
 * Be mindful of infinite recursion scenarios. This code will result in a critical error:
 * @example
 * obj1 := {}
 * obj2 := {}
 * obj1.obj2 := obj2
 * obj2.obj1 := obj1
 * clone := ObjDeepClone(obj1)
 * @
 *
 * Use a maximum depth if there is a recursive parent-child relationship.
 *
 * @param {*} Obj - The object to be deep cloned.
 *
 * @param {Map} [ConstructorParams] - This option is only needed when attempting to deep clone a class
 * that requires parameters to create an instance of the class. You can see an example of this in
 * file DeepClone-test2.ahk. For most objects like Map, Object, or Array, you can leave this unset.
 *
 * A map of constructor parameters, where the key is the class name (use `ObjToBeCloned.__Class`
 * as the key), and the value is an array of values that will be passed to the constructor. Using
 * `ConstructorParams` can allow `ObjDeepClone` to create correctly-typed objects in cases where
 * normally AHK will not allow setting the type using `ObjSetBase()`.
 *
 * @param {Integer} [Depth = 0] - The maximum depth to clone. A value equal to or less than 0 will
 * result in no limit.
 *
 * @returns {*}
 */
ObjDeepClone(Obj, ConstructorParams?, Depth := 0) {
    GetTarget := IsSet(ConstructorParams) ? _GetTarget2 : _GetTarget1
    PtrList := Map(ObjPtr(Obj), Result := GetTarget(Obj))
    CurrentDepth := 0
    return _Recurse(Result, Obj)

    _Recurse(Target, Subject) {
        CurrentDepth++
        for Prop in Subject.OwnProps() {
            Desc := Subject.GetOwnPropDesc(Prop)
            if Desc.HasOwnProp('Value') {
                Target.DefineProp(Prop, { Value: IsObject(Desc.Value) ? _ProcessValue(Desc.Value) : Desc.Value })
            } else {
                Target.DefineProp(Prop, Desc)
            }
        }
        if Target is Array {
            Target.Length := Subject.Length
            for item in Subject {
                if IsSet(item) {
                    Target[A_Index] := IsObject(item) ? _ProcessValue(item) : item
                }
            }
        } else if Target is Map {
            Target.Capacity := Subject.Capacity
            for Key, Val in Subject {
                if IsObject(Key) {
                    Target.Set(_ProcessValue(Key), IsObject(Val) ? _ProcessValue(Val) : Val)
                } else {
                    Target.Set(Key, IsObject(Val) ? _ProcessValue(Val) : Val)
                }
            }
        }
        CurrentDepth--
        return Target
    }
    _GetTarget1(Subject) {
        try {
            Target := GetObjectFromString(Subject.__Class)()
        } catch {
            if Subject Is Map {
                Target := Map()
            } else if Subject is Array {
                Target := Array()
            } else {
                Target := Object()
            }
        }
        try {
            ObjSetBase(Target, Subject.Base)
        }
        return Target
    }
    _GetTarget2(Subject) {
        if ConstructorParams.Has(Subject.__Class) {
            Target := GetObjectFromString(Subject.__Class)(ConstructorParams.Get(Subject.__Class)*)
        } else {
            try {
                Target := GetObjectFromString(Subject.__Class)()
            } catch {
                if Subject Is Map {
                    Target := Map()
                } else if Subject is Array {
                    Target := Array()
                } else {
                    Target := Object()
                }
            }
            try {
                ObjSetBase(Target, Subject.Base)
            }
        }
        return Target
    }
    _ProcessValue(Val) {
        if Type(Val) == 'ComValue' || Type(Val) == 'ComObject' {
            return Val
        }
        if PtrList.Has(ObjPtr(Val)) {
            return PtrList.Get(ObjPtr(Val))
        }
        if CurrentDepth == Depth {
            return Val
        } else {
            PtrList.Set(ObjPtr(Val), _Target := GetTarget(Val))
            return _Recurse(_Target, Val)
        }
    }

    /**
     * @description -
     * Use this function when you need to convert a string to an object reference, and the object
     * is nested within an object path. For example, we cannot get a reference to the class `Gui.Control`
     * by setting the string in double derefs like this: `obj := %'Gui.Control'%. Instead, we have to
     * traverse the path to get each object along the way, which is what this function does.
     * @param {String} Path - The object path.
     * @returns {*} - The object if it exists in the scope. Else, returns an empty string.
     * @example
     *  class MyClass {
     *      class MyNestedClass {
     *          static MyStaticProp := {prop1_1: 1, prop1_2: {prop2_1: {prop3_1: 'Hello, World!'}}}
     *      }
     *  }
     *  obj := GetObjectFromString('MyClass.MyNestedClass.MyStaticProp.prop1_2.prop2_1')
     *  OutputDebug(obj.prop3_1) ; Hello, World!
     * @
     */
    GetObjectFromString(Path) {
        Split := StrSplit(Path, '.')
        if !IsSet(%Split[1]%)
            return
        OutObj := %Split[1]%
        i := 1
        while ++i <= Split.Length {
            if !OutObj.HasOwnProp(Split[i])
                return
            OutObj := OutObj.%Split[i]%
        }
        return OutObj
    }
}
