pub fn add(a: u32, b: u32) -> u32 {
    a + b
}

pub fn super_function() -> &'static str {
    "SUPER VALUE"
}

pub fn super_function_2() -> &'static str {
    "SUPER VALUE"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
