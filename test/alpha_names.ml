open GoblintCil

let () =
  let table = Hashtbl.create 7 in
  let fresh ?(undo=None) name data expected =
    let actual = Alpha.newAlphaName ~alphaTable:table ~undolist:undo
        ~lookupname:name ~data in
    if actual <> expected then
      failwith (Printf.sprintf "renaming %s: expected (%s, %d), got (%s, %d)"
        name (fst expected) (snd expected) (fst actual) (snd actual))
  in
  let register ?(undo=None) name data =
    Alpha.registerAlphaName ~alphaTable:table ~undolist:undo ~lookupname:name ~data
  in
  fresh "x" 10 ("x", 10);
  fresh "x" 20 ("x___0", 10);
  fresh "x___0" 30 ("x___1", 20);
  (* Registering an existing name must preserve its original metadata. *)
  register "x" 999;
  fresh "x" 40 ("x___2", 10);
  register "x___20" 50;
  fresh "x___7" 60 ("x___7", 60);
  fresh "x___20" 70 ("x___21", 50);

  (* Nested scopes must roll back both suffix insertions and the maximum. *)
  let outer = ref [] in
  fresh ~undo:(Some outer) "x" 80 ("x___22", 10);
  let inner = ref [] in
  register ~undo:(Some inner) "x___100" 90;
  register ~undo:(Some inner) "x___7" 999;
  fresh ~undo:(Some inner) "temporary" 100 ("temporary", 100);
  fresh ~undo:(Some inner) "temporary" 110 ("temporary___0", 100);
  Alpha.undoAlphaChanges ~alphaTable:table ~undolist:!inner;
  assert (not (Hashtbl.mem table "temporary"));
  fresh ~undo:(Some outer) "x___7" 120 ("x___23", 60);
  Alpha.undoAlphaChanges ~alphaTable:table ~undolist:!outer;
  fresh "x" 130 ("x___22", 10);

  (* Cabs2cil also saves and restores the opaque table value directly. *)
  let cell = Hashtbl.find table "x" in
  let saved = !cell in
  fresh "x" 140 ("x___23", 10);
  register "x___200" 150;
  cell := saved;
  fresh "x___23" 160 ("x___23", 160);
  fresh "x" 170 ("x___24", 10);

  (* Leading zeros and overlong numeric endings belong to distinct prefixes. *)
  fresh "x___00" 180 ("x___00", 180);
  fresh "x___00" 190 ("x___00___0", 180);
  fresh "x___1000000000" 200 ("x___1000000000", 200);
  fresh "x___1000000000" 210 ("x___1000000000___0", 200);
  register "limit___999999999" 220;
  fresh "limit___0" 230 ("limit___0", 230)
