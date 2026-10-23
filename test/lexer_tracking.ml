open GoblintCil

(* Exercise the lexer directly so raw spelling and whitespace can be checked
   independently of the CABS pretty-printer's normalization. *)
module Lexer = GoblintCil__Clexer
module Parser = GoblintCil__Cparser

let check_string expected actual =
  if expected <> actual then
    failwith (Printf.sprintf "expected %S, got %S" expected actual)

let next lexbuf =
  Lexer.clear_white ();
  Lexer.clear_lexeme ();
  let token = Lexer.initial lexbuf in
  let white = Lexer.get_white () in
  let spelling = Lexer.get_extra_lexeme () ^ Lexing.lexeme lexbuf in
  token, white, spelling

let () =
  let prefix = " \t/* block\ncomment */ // line comment\n  " in
  let literal = "\"a\\n\\x42\\101\"" in
  let suffix = " \n/* final */\t" in
  let source = prefix ^ literal ^ suffix in
  List.iter (fun enabled ->
    Whitetrack.enabled := enabled;
    let lexbuf = Lexer.initFromString source in
    let token, white, spelling = next lexbuf in
    (match token with
    | Parser.CST_STRING (values, _) -> assert (values = [97L; 10L; 66L; 65L])
    | _ -> failwith "expected string token");
    check_string (if enabled then prefix else "") white;
    if enabled then check_string literal spelling
    else check_string "" (Lexer.get_extra_lexeme ());
    let token, white, _ = next lexbuf in
    assert (token = Parser.EOF);
    check_string (if enabled then suffix else "") white;
    Lexer.finish ();
    (* Also exercise Frontc's standalone-expression entry point. *)
    match Frontc.parse_standalone_exp " 1 /* comment */ + 2 " with
    | Cabs.BINARY (Cabs.ADD, _, _) -> ()
    | _ -> failwith "expected addition"
  ) [false; true; false];
  (* Starting another parse must not retain metadata from a tracked parse. *)
  Whitetrack.enabled := true;
  let lexbuf = Lexer.initFromString "  \"old\"" in
  ignore (next lexbuf);
  Lexer.finish ();
  Whitetrack.enabled := false;
  let lexbuf = Lexer.initFromString "0" in
  ignore (Lexer.initial lexbuf);
  check_string "" (Lexer.get_white ());
  check_string "" (Lexer.get_extra_lexeme ());
  Lexer.finish ();
  (* File parsing retains final whitespace only in tracking mode. A later
     untracked parse must not reuse the previous file's trailing comments. *)
  let filename = Filename.temp_file "cil-lexer" ".c" in
  let output = Filename.temp_file "cil-white" ".txt" in
  Fun.protect ~finally:(fun () -> Sys.remove filename; Sys.remove output) (fun () ->
    let channel = open_out filename in
    output_string channel ("int x;" ^ suffix);
    close_out channel;
    List.iter (fun enabled ->
      Whitetrack.enabled := enabled;
      let (_ : unit -> Cil.file) = Frontc.parse filename in
      let channel = open_out output in
      Whitetrack.setOutput channel;
      Whitetrack.printEOF ();
      close_out channel;
      Whitetrack.setOutput stdout;
      let channel = open_in output in
      let finalwhite = really_input_string channel (in_channel_length channel) in
      close_in channel;
      check_string (if enabled then suffix else "\n") finalwhite
    ) [true; false])
