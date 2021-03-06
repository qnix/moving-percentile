(*
   Naive, non-incremental computation of a percentile.
*)

type state

val init : ?window_length:int -> float -> state
val update : state -> float -> unit
val get : state -> float * float
