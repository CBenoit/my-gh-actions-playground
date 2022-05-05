pub fn minus(a: u32, b: u32) -> u32 {
    a - b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = minus(2, 2);
        assert_eq!(result, 0);
    }
}
