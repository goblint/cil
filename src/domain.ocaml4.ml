module DLS = struct
  type 'a key = {
    mutable value: 'a option;
    initialiser: unit -> 'a;
  }

  let new_key ?split_from_parent initialiser =
    { value = None; initialiser }

  let get (k: 'a key) =
    match k.value with
    | Some v -> v
    | None ->
        let v = k.initialiser () in
        k.value <- Some v;
        v

  let set k v =
    k.value <- Some v
end
