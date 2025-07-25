module Domain = struct

  (**************************************************************************)
  (*                                                                        *)
  (*                                 OCaml                                  *)
  (*                                                                        *)
  (*      KC Sivaramakrishnan, Indian Institute of Technology, Madras       *)
  (*                 Stephen Dolan, University of Cambridge                 *)
  (*                   Tom Kelly, OCaml Labs Consultancy                    *)
  (*                                                                        *)
  (*   Copyright 2019 Indian Institute of Technology, Madras                *)
  (*   Copyright 2014 University of Cambridge                               *)
  (*   Copyright 2021 OCaml Labs Consultancy Ltd                            *)
  (*                                                                        *)
  (*   All rights reserved. The type DLST is distributed under the terms of *)
  (*   the GNU Lesser General Public License version 2.1, with the          *)
  (*   special exception on linking described in the LICENSE file           *)
  (*   of the OCaml distribution:                                           *)
  (*     https://github.com/ocaml/ocaml/blob/4.14.0/LICENSE                 *)
  (*                                                                        *)
  (**************************************************************************)

  module type DLSS = sig
    (** Domain-local Storage *)

    type 'a key
    (** Type of a DLS key *)

    val new_key : ?split_from_parent:('a -> 'a) -> (unit -> 'a) -> 'a key
    (** [new_key f] returns a new key bound to initialiser [f] for accessing
        domain-local variables.

        If [split_from_parent] is provided, spawning a domain will derive the
        child value (for this key) from the parent value.

        Note that the [split_from_parent] call is computed in the parent
        domain, and is always computed regardless of whether the child domain
        will use it. If the splitting function is expensive or requires
        client-side computation, consider using ['a Lazy.t key].
    *)

    val get : 'a key -> 'a
    (** [get k] returns [v] if a value [v] is associated to the key [k] on
        the calling domain's domain-local state. Sets [k]'s value with its
        initialiser and returns it otherwise. *)

    val set : 'a key -> 'a -> unit
    (** [set k v] updates the calling domain's domain-local state to associate
        the key [k] with value [v]. It overwrites any previous values associated
        to [k], which cannot be restored later. *)
  end

  module DLS : DLSS = struct
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
end
