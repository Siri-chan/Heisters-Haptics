use std::ffi::{c_char, c_int, c_ulong, c_void, CString};

use mlua_sys::lua51::{
    luaL_checkinteger, lua_Integer, lua_State, lua_newtable, lua_pushcclosure, lua_pushinteger,
    lua_pushstring, lua_setfield,
};

use crate::util::str_to_cstring;

pub unsafe extern "C-unwind" fn say_hello(L: *mut lua_State) -> c_int {
    let cancer: lua_Integer = luaL_checkinteger(L, 1);

    //this complains but since we're compiling for 32-bit it is i32
    lua_pushinteger(L, cancer_test(cancer.into()) << 2);

    1
}

fn cancer_test(idk: i32) -> i32 {
    idk + 1
}

pub fn plugin_setup_lua(L: *mut lua_State) {}

pub fn plugin_init() {}

pub fn plugin_update() {}

pub fn plugin_push_lua(L: *mut lua_State) -> c_int {
    unsafe {
        lua_newtable(L);

        lua_pushstring(L, str_to_cstring("Hellow, World!").as_ptr());
        let test = CString::new("mystring").unwrap();
        lua_setfield(L, -2, test.as_ptr());

        lua_pushcclosure(L, say_hello, 0);
        let myFuncName = CString::new("myfunction").unwrap();
        lua_setfield(L, -2, myFuncName.as_ptr());
    };

    return 1;
}
