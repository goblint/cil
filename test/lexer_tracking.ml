open GoblintCil

(* Exercise the lexer directly so raw spelling and whitespace can be checked
   independently of the CABS pretty-printer's normalization. *)
module Lexer = GoblintCil__Clexer
module Parser = GoblintCil__Cparser

let check_string description expected actual =
  if expected <> actual then
    failwith (Printf.sprintf "%s: expected %S, got %S" description expected actual)

(* Match Frontc's tracked-token wrapper: reset metadata before each token. *)
let next_with_metadata lexbuf =
  Lexer.clear_white ();
  Lexer.clear_lexeme ();
  let token = Lexer.initial lexbuf in
  let white = Lexer.get_white () in
  (* String lexing uses several lexer rules. The extra buffer holds the earlier
     pieces; Lexing.lexeme supplies the final piece (the closing quote). *)
  let spelling = Lexer.get_extra_lexeme () ^ Lexing.lexeme lexbuf in
  token, white, spelling

let trailing_whitespace = " \n/* final */\t"

let test_token_values_and_metadata () =
  (* Include both comment forms and three escape forms: named, hex, and octal.
     Exact metadata comparisons also check comment delimiters and newlines. *)
  let prefix = " \t/* block\ncomment */ // line comment\n  " in
  let literal = "\"a\\n\\x42\\101\"" in
  let source = prefix ^ literal ^ trailing_whitespace in
  (* Decoding must be independent of tracking, including after mode changes. *)
  List.iter (fun enabled ->
    Whitetrack.enabled := enabled;
    let lexbuf = Lexer.initFromString source in
    (* The first token skips the prefix and decodes the literal to a, LF, B, A.
       Tracking must not change these semantic character values. *)
    let token, white, spelling = next_with_metadata lexbuf in
    (match token with
    | Parser.CST_STRING (values, _) -> assert (values = [97L; 10L; 66L; 65L])
    | _ -> failwith "expected string token");
    (* Tracking retains the original text, rather than the decoded characters.
       When disabled, inspect the extra buffer: Lexing.lexeme itself still
       contains text even though no tracking metadata is being collected. *)
    check_string "whitespace before literal" (if enabled then prefix else "") white;
    if enabled then check_string "raw literal spelling" literal spelling
    else check_string "disabled raw-spelling buffer" "" (Lexer.get_extra_lexeme ());
    (* A second read consumes only trailing whitespace/comments and reaches EOF.
       Its metadata must describe that suffix, not the preceding token. *)
    let token, white, _ = next_with_metadata lexbuf in
    assert (token = Parser.EOF);
    check_string "whitespace before EOF"
      (if enabled then trailing_whitespace else "") white;
    Lexer.finish ()
  ) [false; true; false]

let test_standalone_expression () =
  (* Exercise Frontc's entry point as well as the direct lexer above. Run with
     tracking off, on, then off again to cover switching back to the fast path. *)
  List.iter (fun enabled ->
    Whitetrack.enabled := enabled;
    (* Whitespace and the intervening comment must still allow an addition AST
       in either mode; this is a parsing smoke test, not an output-format test. *)
    match Frontc.parse_standalone_exp " 1 /* comment */ + 2 " with
    | Cabs.BINARY (Cabs.ADD, _, _) -> ()
    | _ -> failwith "expected addition"
  ) [false; true; false]

let test_initialization_clears_metadata () =
  (* First lex a tracked string: leading spaces populate the whitespace buffer,
     and the string's spelling populates the extra-lexeme buffer. Stop before
     another token read could clear them. *)
  Whitetrack.enabled := true;
  let lexbuf = Lexer.initFromString "  \"old\"" in
  ignore (next_with_metadata lexbuf);
  Lexer.finish ();
  (* Start a new, untracked input while metadata from the old input remains.
     Disabled collection alone would not remove those old buffer contents. *)
  Whitetrack.enabled := false;
  let lexbuf = Lexer.initFromString "0" in
  (* Bypass next_with_metadata: initialization itself must clear the buffers. *)
  ignore (Lexer.initial lexbuf);
  (* Neither getter may expose metadata belonging to the previous input. *)
  check_string "whitespace after reinitialization" "" (Lexer.get_white ());
  check_string "raw spelling after reinitialization" "" (Lexer.get_extra_lexeme ());
  Lexer.finish ()

let test_file_trailing_whitespace () =
  (* File parsing retains final whitespace only in tracking mode. A later
     untracked parse must not reuse the previous file's trailing comments. *)
  let filename = Filename.temp_file "cil-lexer" ".c" in
  let output = Filename.temp_file "cil-white" ".txt" in
  Fun.protect ~finally:(fun () -> Sys.remove filename; Sys.remove output) (fun () ->
    (* Use a complete C file with a recognizable suffix after its declaration.
       Temporary input and captured output are removed even if a check fails. *)
    let channel = open_out filename in
    output_string channel ("int x;" ^ trailing_whitespace);
    close_out channel;
    List.iter (fun enabled ->
      Whitetrack.enabled := enabled;
      (* Frontc.parse performs the parsing now and returns a deferred CIL
         conversion. Only parsing is needed to populate EOF tracking state. *)
      let (_ : unit -> Cil.file) = Frontc.parse filename in
      (* Capture just EOF printing so declaration formatting cannot affect the
         comparison. Restore the output destination before reading the result. *)
      let channel = open_out output in
      Whitetrack.setOutput channel;
      Whitetrack.printEOF ();
      close_out channel;
      Whitetrack.setOutput stdout;
      let channel = open_in output in
      let finalwhite = really_input_string channel (in_channel_length channel) in
      close_in channel;
      (* The tracked run must reproduce the suffix exactly. The following
         untracked run must print the default newline, not the old comment. *)
      check_string "printed EOF whitespace"
        (if enabled then trailing_whitespace else "\n") finalwhite
    ) [true; false])

let () =
  test_token_values_and_metadata ();
  test_standalone_expression ();
  test_initialization_clears_metadata ();
  test_file_trailing_whitespace ()
