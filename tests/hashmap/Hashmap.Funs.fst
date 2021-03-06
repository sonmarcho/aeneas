(** THIS FILE WAS AUTOMATICALLY GENERATED BY AENEAS *)
(** [hashmap]: function definitions *)
module Hashmap.Funs
open Primitives
include Hashmap.Types
include Hashmap.Clauses

#set-options "--z3rlimit 50 --fuel 1 --ifuel 1"

(** [hashmap::hash_key] *)
let hash_key_fwd (k : usize) : result usize = Return k

(** [hashmap::HashMap::{0}::allocate_slots] *)
let rec hash_map_allocate_slots_fwd
  (t : Type0) (slots : vec (list_t t)) (n : usize) :
  Tot (result (vec (list_t t)))
  (decreases (hash_map_allocate_slots_decreases t slots n))
  =
  if n = 0
  then Return slots
  else
    begin match vec_push_back (list_t t) slots ListNil with
    | Fail -> Fail
    | Return slots0 ->
      begin match usize_sub n 1 with
      | Fail -> Fail
      | Return i ->
        begin match hash_map_allocate_slots_fwd t slots0 i with
        | Fail -> Fail
        | Return v -> Return v
        end
      end
    end

(** [hashmap::HashMap::{0}::new_with_capacity] *)
let hash_map_new_with_capacity_fwd
  (t : Type0) (capacity : usize) (max_load_dividend : usize)
  (max_load_divisor : usize) :
  result (hash_map_t t)
  =
  let v = vec_new (list_t t) in
  begin match hash_map_allocate_slots_fwd t v capacity with
  | Fail -> Fail
  | Return slots ->
    begin match usize_mul capacity max_load_dividend with
    | Fail -> Fail
    | Return i ->
      begin match usize_div i max_load_divisor with
      | Fail -> Fail
      | Return i0 ->
        Return (Mkhash_map_t 0 (max_load_dividend, max_load_divisor) i0 slots)
      end
    end
  end

(** [hashmap::HashMap::{0}::new] *)
let hash_map_new_fwd (t : Type0) : result (hash_map_t t) =
  begin match hash_map_new_with_capacity_fwd t 32 4 5 with
  | Fail -> Fail
  | Return hm -> Return hm
  end

(** [hashmap::HashMap::{0}::clear_slots] *)
let rec hash_map_clear_slots_fwd_back
  (t : Type0) (slots : vec (list_t t)) (i : usize) :
  Tot (result (vec (list_t t)))
  (decreases (hash_map_clear_slots_decreases t slots i))
  =
  let i0 = vec_len (list_t t) slots in
  if i < i0
  then
    begin match vec_index_mut_back (list_t t) slots i ListNil with
    | Fail -> Fail
    | Return slots0 ->
      begin match usize_add i 1 with
      | Fail -> Fail
      | Return i1 ->
        begin match hash_map_clear_slots_fwd_back t slots0 i1 with
        | Fail -> Fail
        | Return slots1 -> Return slots1
        end
      end
    end
  else Return slots

(** [hashmap::HashMap::{0}::clear] *)
let hash_map_clear_fwd_back
  (t : Type0) (self : hash_map_t t) : result (hash_map_t t) =
  begin match hash_map_clear_slots_fwd_back t self.hash_map_slots 0 with
  | Fail -> Fail
  | Return v ->
    Return (Mkhash_map_t 0 self.hash_map_max_load_factor self.hash_map_max_load
      v)
  end

(** [hashmap::HashMap::{0}::len] *)
let hash_map_len_fwd (t : Type0) (self : hash_map_t t) : result usize =
  Return self.hash_map_num_entries

(** [hashmap::HashMap::{0}::insert_in_list] *)
let rec hash_map_insert_in_list_fwd
  (t : Type0) (key : usize) (value : t) (ls : list_t t) :
  Tot (result bool)
  (decreases (hash_map_insert_in_list_decreases t key value ls))
  =
  begin match ls with
  | ListCons ckey cvalue ls0 ->
    if ckey = key
    then Return false
    else
      begin match hash_map_insert_in_list_fwd t key value ls0 with
      | Fail -> Fail
      | Return b -> Return b
      end
  | ListNil -> Return true
  end

(** [hashmap::HashMap::{0}::insert_in_list] *)
let rec hash_map_insert_in_list_back
  (t : Type0) (key : usize) (value : t) (ls : list_t t) :
  Tot (result (list_t t))
  (decreases (hash_map_insert_in_list_decreases t key value ls))
  =
  begin match ls with
  | ListCons ckey cvalue ls0 ->
    if ckey = key
    then Return (ListCons ckey value ls0)
    else
      begin match hash_map_insert_in_list_back t key value ls0 with
      | Fail -> Fail
      | Return ls1 -> Return (ListCons ckey cvalue ls1)
      end
  | ListNil -> let l = ListNil in Return (ListCons key value l)
  end

(** [hashmap::HashMap::{0}::insert_no_resize] *)
let hash_map_insert_no_resize_fwd_back
  (t : Type0) (self : hash_map_t t) (key : usize) (value : t) :
  result (hash_map_t t)
  =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_mut_fwd (list_t t) self.hash_map_slots hash_mod
        with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_insert_in_list_fwd t key value l with
        | Fail -> Fail
        | Return inserted ->
          if inserted
          then
            begin match usize_add self.hash_map_num_entries 1 with
            | Fail -> Fail
            | Return i0 ->
              begin match hash_map_insert_in_list_back t key value l with
              | Fail -> Fail
              | Return l0 ->
                begin match
                  vec_index_mut_back (list_t t) self.hash_map_slots hash_mod l0
                  with
                | Fail -> Fail
                | Return v ->
                  Return (Mkhash_map_t i0 self.hash_map_max_load_factor
                    self.hash_map_max_load v)
                end
              end
            end
          else
            begin match hash_map_insert_in_list_back t key value l with
            | Fail -> Fail
            | Return l0 ->
              begin match
                vec_index_mut_back (list_t t) self.hash_map_slots hash_mod l0
                with
              | Fail -> Fail
              | Return v ->
                Return (Mkhash_map_t self.hash_map_num_entries
                  self.hash_map_max_load_factor self.hash_map_max_load v)
              end
            end
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::move_elements_from_list] *)
let rec hash_map_move_elements_from_list_fwd_back
  (t : Type0) (ntable : hash_map_t t) (ls : list_t t) :
  Tot (result (hash_map_t t))
  (decreases (hash_map_move_elements_from_list_decreases t ntable ls))
  =
  begin match ls with
  | ListCons k v tl ->
    begin match hash_map_insert_no_resize_fwd_back t ntable k v with
    | Fail -> Fail
    | Return ntable0 ->
      begin match hash_map_move_elements_from_list_fwd_back t ntable0 tl with
      | Fail -> Fail
      | Return ntable1 -> Return ntable1
      end
    end
  | ListNil -> Return ntable
  end

(** [hashmap::HashMap::{0}::move_elements] *)
let rec hash_map_move_elements_fwd_back
  (t : Type0) (ntable : hash_map_t t) (slots : vec (list_t t)) (i : usize) :
  Tot (result ((hash_map_t t) & (vec (list_t t))))
  (decreases (hash_map_move_elements_decreases t ntable slots i))
  =
  let i0 = vec_len (list_t t) slots in
  if i < i0
  then
    begin match vec_index_mut_fwd (list_t t) slots i with
    | Fail -> Fail
    | Return l ->
      let ls = mem_replace_fwd (list_t t) l ListNil in
      begin match hash_map_move_elements_from_list_fwd_back t ntable ls with
      | Fail -> Fail
      | Return ntable0 ->
        let l0 = mem_replace_back (list_t t) l ListNil in
        begin match vec_index_mut_back (list_t t) slots i l0 with
        | Fail -> Fail
        | Return slots0 ->
          begin match usize_add i 1 with
          | Fail -> Fail
          | Return i1 ->
            begin match hash_map_move_elements_fwd_back t ntable0 slots0 i1
              with
            | Fail -> Fail
            | Return (ntable1, slots1) -> Return (ntable1, slots1)
            end
          end
        end
      end
    end
  else Return (ntable, slots)

(** [hashmap::HashMap::{0}::try_resize] *)
let hash_map_try_resize_fwd_back
  (t : Type0) (self : hash_map_t t) : result (hash_map_t t) =
  begin match scalar_cast U32 Usize 4294967295 with
  | Fail -> Fail
  | Return max_usize ->
    let capacity = vec_len (list_t t) self.hash_map_slots in
    begin match usize_div max_usize 2 with
    | Fail -> Fail
    | Return n1 ->
      let (i, i0) = self.hash_map_max_load_factor in
      begin match usize_div n1 i with
      | Fail -> Fail
      | Return i1 ->
        if capacity <= i1
        then
          begin match usize_mul capacity 2 with
          | Fail -> Fail
          | Return i2 ->
            begin match hash_map_new_with_capacity_fwd t i2 i i0 with
            | Fail -> Fail
            | Return ntable ->
              begin match
                hash_map_move_elements_fwd_back t ntable self.hash_map_slots 0
                with
              | Fail -> Fail
              | Return (ntable0, _) ->
                Return (Mkhash_map_t self.hash_map_num_entries (i, i0)
                  ntable0.hash_map_max_load ntable0.hash_map_slots)
              end
            end
          end
        else
          Return (Mkhash_map_t self.hash_map_num_entries (i, i0)
            self.hash_map_max_load self.hash_map_slots)
      end
    end
  end

(** [hashmap::HashMap::{0}::insert] *)
let hash_map_insert_fwd_back
  (t : Type0) (self : hash_map_t t) (key : usize) (value : t) :
  result (hash_map_t t)
  =
  begin match hash_map_insert_no_resize_fwd_back t self key value with
  | Fail -> Fail
  | Return self0 ->
    begin match hash_map_len_fwd t self0 with
    | Fail -> Fail
    | Return i ->
      if i > self0.hash_map_max_load
      then
        begin match hash_map_try_resize_fwd_back t self0 with
        | Fail -> Fail
        | Return self1 -> Return self1
        end
      else Return self0
    end
  end

(** [hashmap::HashMap::{0}::contains_key_in_list] *)
let rec hash_map_contains_key_in_list_fwd
  (t : Type0) (key : usize) (ls : list_t t) :
  Tot (result bool)
  (decreases (hash_map_contains_key_in_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey x ls0 ->
    if ckey = key
    then Return true
    else
      begin match hash_map_contains_key_in_list_fwd t key ls0 with
      | Fail -> Fail
      | Return b -> Return b
      end
  | ListNil -> Return false
  end

(** [hashmap::HashMap::{0}::contains_key] *)
let hash_map_contains_key_fwd
  (t : Type0) (self : hash_map_t t) (key : usize) : result bool =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_fwd (list_t t) self.hash_map_slots hash_mod with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_contains_key_in_list_fwd t key l with
        | Fail -> Fail
        | Return b -> Return b
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::get_in_list] *)
let rec hash_map_get_in_list_fwd
  (t : Type0) (key : usize) (ls : list_t t) :
  Tot (result t) (decreases (hash_map_get_in_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey cvalue ls0 ->
    if ckey = key
    then Return cvalue
    else
      begin match hash_map_get_in_list_fwd t key ls0 with
      | Fail -> Fail
      | Return x -> Return x
      end
  | ListNil -> Fail
  end

(** [hashmap::HashMap::{0}::get] *)
let hash_map_get_fwd
  (t : Type0) (self : hash_map_t t) (key : usize) : result t =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_fwd (list_t t) self.hash_map_slots hash_mod with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_get_in_list_fwd t key l with
        | Fail -> Fail
        | Return x -> Return x
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::get_mut_in_list] *)
let rec hash_map_get_mut_in_list_fwd
  (t : Type0) (key : usize) (ls : list_t t) :
  Tot (result t) (decreases (hash_map_get_mut_in_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey cvalue ls0 ->
    if ckey = key
    then Return cvalue
    else
      begin match hash_map_get_mut_in_list_fwd t key ls0 with
      | Fail -> Fail
      | Return x -> Return x
      end
  | ListNil -> Fail
  end

(** [hashmap::HashMap::{0}::get_mut_in_list] *)
let rec hash_map_get_mut_in_list_back
  (t : Type0) (key : usize) (ls : list_t t) (ret : t) :
  Tot (result (list_t t))
  (decreases (hash_map_get_mut_in_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey cvalue ls0 ->
    if ckey = key
    then Return (ListCons ckey ret ls0)
    else
      begin match hash_map_get_mut_in_list_back t key ls0 ret with
      | Fail -> Fail
      | Return ls1 -> Return (ListCons ckey cvalue ls1)
      end
  | ListNil -> Fail
  end

(** [hashmap::HashMap::{0}::get_mut] *)
let hash_map_get_mut_fwd
  (t : Type0) (self : hash_map_t t) (key : usize) : result t =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_mut_fwd (list_t t) self.hash_map_slots hash_mod
        with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_get_mut_in_list_fwd t key l with
        | Fail -> Fail
        | Return x -> Return x
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::get_mut] *)
let hash_map_get_mut_back
  (t : Type0) (self : hash_map_t t) (key : usize) (ret : t) :
  result (hash_map_t t)
  =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_mut_fwd (list_t t) self.hash_map_slots hash_mod
        with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_get_mut_in_list_back t key l ret with
        | Fail -> Fail
        | Return l0 ->
          begin match
            vec_index_mut_back (list_t t) self.hash_map_slots hash_mod l0 with
          | Fail -> Fail
          | Return v ->
            Return (Mkhash_map_t self.hash_map_num_entries
              self.hash_map_max_load_factor self.hash_map_max_load v)
          end
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::remove_from_list] *)
let rec hash_map_remove_from_list_fwd
  (t : Type0) (key : usize) (ls : list_t t) :
  Tot (result (option t))
  (decreases (hash_map_remove_from_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey x tl ->
    if ckey = key
    then
      let mv_ls = mem_replace_fwd (list_t t) (ListCons ckey x tl) ListNil in
      begin match mv_ls with
      | ListCons i cvalue tl0 -> Return (Some cvalue)
      | ListNil -> Fail
      end
    else
      begin match hash_map_remove_from_list_fwd t key tl with
      | Fail -> Fail
      | Return opt -> Return opt
      end
  | ListNil -> Return None
  end

(** [hashmap::HashMap::{0}::remove_from_list] *)
let rec hash_map_remove_from_list_back
  (t : Type0) (key : usize) (ls : list_t t) :
  Tot (result (list_t t))
  (decreases (hash_map_remove_from_list_decreases t key ls))
  =
  begin match ls with
  | ListCons ckey x tl ->
    if ckey = key
    then
      let mv_ls = mem_replace_fwd (list_t t) (ListCons ckey x tl) ListNil in
      begin match mv_ls with
      | ListCons i cvalue tl0 -> Return tl0
      | ListNil -> Fail
      end
    else
      begin match hash_map_remove_from_list_back t key tl with
      | Fail -> Fail
      | Return tl0 -> Return (ListCons ckey x tl0)
      end
  | ListNil -> Return ListNil
  end

(** [hashmap::HashMap::{0}::remove] *)
let hash_map_remove_fwd
  (t : Type0) (self : hash_map_t t) (key : usize) : result (option t) =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_mut_fwd (list_t t) self.hash_map_slots hash_mod
        with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_remove_from_list_fwd t key l with
        | Fail -> Fail
        | Return x ->
          begin match x with
          | None -> Return None
          | Some x0 ->
            begin match usize_sub self.hash_map_num_entries 1 with
            | Fail -> Fail
            | Return _ -> Return (Some x0)
            end
          end
        end
      end
    end
  end

(** [hashmap::HashMap::{0}::remove] *)
let hash_map_remove_back
  (t : Type0) (self : hash_map_t t) (key : usize) : result (hash_map_t t) =
  begin match hash_key_fwd key with
  | Fail -> Fail
  | Return hash ->
    let i = vec_len (list_t t) self.hash_map_slots in
    begin match usize_rem hash i with
    | Fail -> Fail
    | Return hash_mod ->
      begin match vec_index_mut_fwd (list_t t) self.hash_map_slots hash_mod
        with
      | Fail -> Fail
      | Return l ->
        begin match hash_map_remove_from_list_fwd t key l with
        | Fail -> Fail
        | Return x ->
          begin match x with
          | None ->
            begin match hash_map_remove_from_list_back t key l with
            | Fail -> Fail
            | Return l0 ->
              begin match
                vec_index_mut_back (list_t t) self.hash_map_slots hash_mod l0
                with
              | Fail -> Fail
              | Return v ->
                Return (Mkhash_map_t self.hash_map_num_entries
                  self.hash_map_max_load_factor self.hash_map_max_load v)
              end
            end
          | Some x0 ->
            begin match usize_sub self.hash_map_num_entries 1 with
            | Fail -> Fail
            | Return i0 ->
              begin match hash_map_remove_from_list_back t key l with
              | Fail -> Fail
              | Return l0 ->
                begin match
                  vec_index_mut_back (list_t t) self.hash_map_slots hash_mod l0
                  with
                | Fail -> Fail
                | Return v ->
                  Return (Mkhash_map_t i0 self.hash_map_max_load_factor
                    self.hash_map_max_load v)
                end
              end
            end
          end
        end
      end
    end
  end

(** [hashmap::test1] *)
let test1_fwd : result unit =
  begin match hash_map_new_fwd u64 with
  | Fail -> Fail
  | Return hm ->
    begin match hash_map_insert_fwd_back u64 hm 0 42 with
    | Fail -> Fail
    | Return hm0 ->
      begin match hash_map_insert_fwd_back u64 hm0 128 18 with
      | Fail -> Fail
      | Return hm1 ->
        begin match hash_map_insert_fwd_back u64 hm1 1024 138 with
        | Fail -> Fail
        | Return hm2 ->
          begin match hash_map_insert_fwd_back u64 hm2 1056 256 with
          | Fail -> Fail
          | Return hm3 ->
            begin match hash_map_get_fwd u64 hm3 128 with
            | Fail -> Fail
            | Return i ->
              if not (i = 18)
              then Fail
              else
                begin match hash_map_get_mut_back u64 hm3 1024 56 with
                | Fail -> Fail
                | Return hm4 ->
                  begin match hash_map_get_fwd u64 hm4 1024 with
                  | Fail -> Fail
                  | Return i0 ->
                    if not (i0 = 56)
                    then Fail
                    else
                      begin match hash_map_remove_fwd u64 hm4 1024 with
                      | Fail -> Fail
                      | Return x ->
                        begin match x with
                        | None -> Fail
                        | Some x0 ->
                          if not (x0 = 56)
                          then Fail
                          else
                            begin match hash_map_remove_back u64 hm4 1024 with
                            | Fail -> Fail
                            | Return hm5 ->
                              begin match hash_map_get_fwd u64 hm5 0 with
                              | Fail -> Fail
                              | Return i1 ->
                                if not (i1 = 42)
                                then Fail
                                else
                                  begin match hash_map_get_fwd u64 hm5 128 with
                                  | Fail -> Fail
                                  | Return i2 ->
                                    if not (i2 = 18)
                                    then Fail
                                    else
                                      begin match hash_map_get_fwd u64 hm5 1056
                                        with
                                      | Fail -> Fail
                                      | Return i3 ->
                                        if not (i3 = 256)
                                        then Fail
                                        else Return ()
                                      end
                                  end
                              end
                            end
                        end
                      end
                  end
                end
            end
          end
        end
      end
    end
  end

(** Unit test for [hashmap::test1] *)
let _ = assert_norm (test1_fwd = Return ())

