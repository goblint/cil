module DLS : sig
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
