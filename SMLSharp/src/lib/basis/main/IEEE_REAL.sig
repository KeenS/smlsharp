(* sigs/ieee-real.sig
 *
 * COPYRIGHT (c) 1996 AT&T Bell Laboratories.
 *)

signature IEEE_REAL =
  sig

    exception Unordered

    datatype real_order = LESS | EQUAL | GREATER | UNORDERED

    datatype float_class
      = NAN
      | INF
      | ZERO
      | NORMAL
      | SUBNORMAL

    datatype rounding_mode
      = TO_NEAREST
      | TO_NEGINF
      | TO_POSINF
      | TO_ZERO

    val setRoundingMode : rounding_mode -> unit
    val getRoundingMode : unit -> rounding_mode

    type decimal_approx = {
	class : float_class,
	sign : bool,
	digits : int list,
	exp : int
      }

    val toString   : decimal_approx -> string
    val fromString : string -> decimal_approx option
    val scan : (char, 'a) StringCvt.reader ->
	       (decimal_approx, 'a) StringCvt.reader

  end;


