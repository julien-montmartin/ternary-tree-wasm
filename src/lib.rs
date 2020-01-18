#![forbid(unsafe_code)]

extern crate ternary_tree;
extern crate js_sys;

use wasm_bindgen::prelude::*;
use ternary_tree::{TstIterator, TstCompleteIterator, TstNeighborIterator, TstCrosswordIterator};


#[wasm_bindgen]
pub struct Tst {

    tree: ternary_tree::Tst<JsValue>
}

#[wasm_bindgen]
#[derive(PartialEq)]
pub enum Direction { Forward, Backward }


#[wasm_bindgen]
impl Tst {

    pub fn new() -> Self {

        Tst { tree: ternary_tree::Tst::new() }
    }

    pub fn insert(&mut self, key: &str, value: JsValue) -> JsValue {

        match self.tree.insert(key, value) {

            None => JsValue::null(), Some(value) => value
        }
    }

    pub fn get(&self, key: &str) -> JsValue {

        match self.tree.get(key) {

            None => JsValue::null(), Some(value) => value.clone()
        }
    }

    pub fn remove(&mut self, key: &str) -> JsValue {

        match self.tree.remove(key) {

            None => JsValue::null(), Some(value) => value.clone()
        }
    }

    pub fn count(&self) -> usize {

       self.tree.len()
    }

    pub fn clear(&mut self) {

        self.tree.clear()
    }

    pub fn pretty_print(&self) -> String {

        let mut w = Vec::new();

        self.tree.pretty_print(&mut w);

        match String::from_utf8(w) {

            Ok(s) => s,
            Err(_) => String::new()
        }
    }

    pub fn visit(&self, callback: &js_sys::Function, direction: Direction) {

        let mut it = self.tree.iter();
        let this = JsValue::NULL;
        let next_fn = if direction == Direction::Forward { TstIterator::<JsValue>::next } else { TstIterator::<JsValue>::next_back };
        let key_fn = if direction == Direction::Forward { TstIterator::<JsValue>::current_key } else { TstIterator::<JsValue>::current_key_back };

        while let Some(value) = (next_fn)(&mut it) {

            let key = JsValue::from((key_fn)(&mut it));
            let should_break = match callback.call2(&this, &key, value) {

                Ok(res) => res.is_truthy(),
                Err(_) => true
            };

            if should_break {

                break;
            }
        }
    }

    pub fn complete(&self, prefix: &str, callback: &js_sys::Function, direction: Direction) {

        let mut it = self.tree.iter_complete(prefix);
        let this = JsValue::NULL;
        let next_fn = if direction == Direction::Forward { TstCompleteIterator::<JsValue>::next } else { TstCompleteIterator::<JsValue>::next_back };
        let key_fn = if direction == Direction::Forward { TstCompleteIterator::<JsValue>::current_key } else { TstCompleteIterator::<JsValue>::current_key_back };

        while let Some(value) = (next_fn)(&mut it) {

            let key = JsValue::from((key_fn)(&mut it));
            let res = callback.call2(&this, &key, value);

            let should_break = match res {

                Ok(val) => val.is_truthy(),
                Err(_) => true
            };

            if should_break {

                break;
            }
        }
    }

    pub fn neighbor(&self, neighbor_key: &str, range: usize, callback: &js_sys::Function, direction: Direction) {

        let mut it = self.tree.iter_neighbor(neighbor_key, range);
        let this = JsValue::NULL;
        let next_fn = if direction == Direction::Forward { TstNeighborIterator::<JsValue>::next } else { TstNeighborIterator::<JsValue>::next_back };
        let key_fn = if direction == Direction::Forward { TstNeighborIterator::<JsValue>::current_key } else { TstNeighborIterator::<JsValue>::current_key_back };

        while let Some(value) = (next_fn)(&mut it) {

            let key = JsValue::from((key_fn)(&mut it));
            let res = callback.call2(&this, &key, value);

            let should_break = match res {

                Ok(val) => val.is_truthy(),
                Err(_) => true
            };

            if should_break {

                break;
            }
        }
    }

    pub fn crossword(&self, pattern: &str, joker: char, callback: &js_sys::Function, direction: Direction) {

        let mut it = self.tree.iter_crossword(pattern, joker);
        let this = JsValue::NULL;
        let next_fn = if direction == Direction::Forward { TstCrosswordIterator::<JsValue>::next } else { TstCrosswordIterator::<JsValue>::next_back };
        let key_fn = if direction == Direction::Forward { TstCrosswordIterator::<JsValue>::current_key } else { TstCrosswordIterator::<JsValue>::current_key_back };

        while let Some(value) = (next_fn)(&mut it) {

            let key = JsValue::from((key_fn)(&mut it));
            let res = callback.call2(&this, &key, value);

            let should_break = match res {

                Ok(val) => val.is_truthy(),
                Err(_) => true
            };

            if should_break {

                break;
            }
        }
    }
}
