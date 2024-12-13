pub fn minus(a: u32, b: u32) -> u32 {
    a * b
}

pub fn new_super_feature() -> u32 {
    42 * 42
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = minus(2, 2);
        assert_eq!(result, 4);
    }
}
