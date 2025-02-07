/// Returns the index of the maximum value in a slice of usize values.
const fn max_pos_usize(arr: &[usize]) -> usize {
    let mut max_index: usize = 0;
    let mut i = 0;
    while i < arr.len() {
        if arr[i] > arr[max_index] {
            max_index = i;
        }
        i += 1;
    }
    max_index
}
/// Returns the maximum alignment of the primitive types. May not be the maximum possible alignment of all types.
const fn max_align() -> usize {
    use std::mem::align_of;
    let aligns = [align_of::<usize>(), align_of::<u128>(), align_of::<f64>()];
    aligns[max_pos_usize(&aligns)]
}
