module E = Errormsg

(* Output management *)
let out : out_channel option ref = ref None
let close_me = ref false

let close_output _ =
  match !out with
    None -> ()
  | Some o -> begin
      flush o;
      if !close_me then close_out o else ();
      close_me := false
  end

let set_output filename =
  close_output ();
  (try out := Some (open_out filename) 
  with (Sys_error msg) ->
    output_string stderr ("Error while opening output: " ^ msg); exit 1);
  close_me := true
       

(*
** Argument definition
*)
let args : (string * Arg.spec * string) list = 
[
  "-cabsout", Arg.String set_output, "Output file";
  "-cabsindent", Arg.Int Cprint.set_tab, "Identation step";
  "-cabswidth", Arg.Int Cprint.set_width, "Page width";
]

exception ParseError of string


let parse_to_cabs fname = 
  try
    ignore (E.log "Frontc is parsing %s\n" fname);
    let file = open_in fname in
    Clexer.init (false, file, "", "", 0, 0, stderr, fname);
    let cabs = 
      Stats.time "parse"
        (Cparser.file Clexer.initial)
	(Lexing.from_function 
           (Clexer.get_buffer Clexer.current_handle)) in
    close_in file;
    ignore (E.log "Frontc finished parsing\n");
    (match !out with 
      Some o -> begin
        output_string o ("/* Generated by Frontc */\n");
        Stats.time "printCABS" (Cprint.print o) cabs;
        close_output ();
      end
    | None -> ());
    cabs
  with (Sys_error msg) -> begin
    ignore (E.log "Cannot open %s : %s\n" fname msg);
    close_output ();
    raise (ParseError("Cannot open " ^ fname ^ ": " ^ msg ^ "\n"))
  end
  | Parsing.Parse_error -> begin
      ignore (E.log "Parsing error\n");
      close_output ();
      raise (ParseError("Parse error"))
  end
  | e -> begin
      ignore (E.log "Caught %s while parsing\n" (Printexc.to_string e));
      raise e
  end

let parse fname = 
  let cabs = parse_to_cabs fname in
  (* Now convert to CIL *)
  let cil = Stats.time "conv" Cabs2cil.convFile fname cabs in
  ignore (E.log "FrontC finished conversion to CIL\n");
  cil
  

let docombine (files: string list) : Cabs.file = 
  let list_of_parsed_files =
    List.map (fun file_name -> parse_to_cabs file_name) files in
  Combine.combine list_of_parsed_files

let combine (files: string list) (out: string) = 
  let cabs = docombine files in
  try
    let o = open_out out in
    output_string o ("/* Generated by Frontc */\n");
    Stats.time "printCombine" (Cprint.print o) cabs;
    close_out o
  with (Sys_error msg) as e -> begin
    ignore (E.log "Cannot open %s : %s\n" out msg);
    raise e
  end
    
  
let parse_combine (files: string list) : Cil.file = 
  let cabs = docombine files in
  (* Now convert to CIL *)
  let cil = Stats.time "conv" Cabs2cil.convFile "combined" cabs in
  ignore (E.log "FrontC finished conversion to CIL\n");
  cil
  
