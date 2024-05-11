pub fn str_to_cstring(text: &str) -> std::ffi::CString {
    std::ffi::CString::new(text).unwrap()
}
