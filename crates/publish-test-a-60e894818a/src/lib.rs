pub fn minus(a: u32, b: u32) -> u32 {
    a * b
}

pub fn new_shiny_feature() {
    panic!("it’s a trap!");
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
