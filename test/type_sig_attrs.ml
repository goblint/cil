open GoblintCil

let () =
  let int = TInt (IInt, []) in
  assert (typeSig int = TSBase int);
  assert (typeSigWithAttrs ~ignoreSign:true Fun.id int = TSBase (TInt (IUInt, [])));

  (* An empty input does not imply an empty transformed attribute list. *)
  let calls = ref 0 in
  let add_attr attrs =
    incr calls;
    Attr ("test", [AInt 7]) :: attrs
  in
  assert (typeSigWithAttrs add_attr int =
          TSBase (TInt (IInt, [Attr ("test", [AInt 7])])));
  assert (!calls = 1);

  (* Nonempty attributes still recursively convert embedded types. *)
  let attrs = [Attr ("test", [ASizeOf int; AAlignOf (TPtr (int, []))])] in
  let attributed = TInt (IInt, attrs) in
  let expected = TSBase (TInt (IInt,
    [Attr ("test", [ASizeOfS (TSBase int); AAlignOfS (TSPtr (TSBase int, []))])])) in
  assert (typeSig attributed = expected);

  (* Filtering all attributes takes the empty path after the callback. *)
  assert (typeSigWithAttrs (fun _ -> []) attributed = TSBase int)
