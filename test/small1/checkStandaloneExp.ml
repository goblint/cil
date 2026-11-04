open GoblintCil

let () =
  Cil.initCIL ();
  let base = {Cil.tname = "base_t"; ttype = Cil.ulongType; treferenced = false} in
  let alias = {Cil.tname = "size_t"; ttype = Cil.TNamed (base, []); treferenced = false} in
  let typ = Cil.TNamed (alias, []) in
  let x = Cil.makeVarinfo false "x" typ in
  let y = Cil.makeVarinfo false "y" typ in
  let equality v n =
    Cil.BinOp (Cil.Eq, Cil.Lval (Cil.var v), Cil.kinteger Cil.IULong n, Cil.intType)
  in
  let single = equality x 1 in
  let repeated = Cil.BinOp (Cil.LAnd, single, equality y 2, Cil.intType) in
  let expect_result label expected actual =
    if actual <> expected then
      failwith (Printf.sprintf "%s: expected %b, got %b" label expected actual)
  in
  let expect label expected types vars exp =
    expect_result label expected (Check.checkStandaloneExp ~types ~vars exp)
  in
  (* Negative cases intentionally produce diagnostics. *)
  expect "repeated typedef uses" true [base; alias] [x; y] repeated;
  expect "missing outer typedef" false [base] [x] single;
  expect "missing inner typedef" false [alias] [x] single;
  expect "no typedef declarations" false [] [x] single;
  expect "typedef declaration order" false [alias; base] [x] single;
  let other_alias = {alias with Cil.treferenced = false} in
  expect "unshared typedef" false [base; other_alias] [x] single;
  expect "missing variable" false [base; alias] [] single;
  expect "environment reset after failures" true [base; alias] [x; y] repeated;

  (* Check the same typedef rules when traversing whole files. *)
  let expect_file label expected globals =
    let file = {
      Cil.fileName = "checkStandaloneExp.c";
      globals;
      globinit = None;
      globinitcalled = false;
    } in
    expect_result label expected (Check.checkFile [] file)
  in
  let definition ti = Cil.GType (ti, Cil.locUnknown) in
  let use name ti =
    let v = Cil.makeGlobalVar name (Cil.TNamed (ti, [])) in
    Cil.GVarDecl (v, Cil.locUnknown)
  in
  let valid_globals = [definition base; definition alias; use "x" alias; use "y" alias] in
  expect_file "file: repeated typedef uses" true valid_globals;
  (* A single use must fail without needing another use or a later definition. *)
  expect_file "file: single missing typedef use" false [use "x" base];
  expect_file "file: repeated missing typedef uses" false [use "x" base; use "y" base];
  expect_file "file: use before definition" false [use "x" base; definition base];
  expect_file "file: typedef declaration order" false [definition alias; definition base];
  (* Duplicate GType nodes violate CIL's internal representation. *)
  expect_file "file: duplicate typedef definition" false [definition base; definition base];
  let other_base = {base with Cil.treferenced = false} in
  expect_file "file: unshared typedef" false [definition base; use "x" other_base];
  expect_file "file: environment reset after failures" true valid_globals
