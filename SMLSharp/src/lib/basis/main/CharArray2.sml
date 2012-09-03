(**
 * CharArray2 structure.
 * @author YAMATODANI Kiyoshi
 * @copyright 2010, Tohoku University.
 *)
structure CharArray2 : MONO_ARRAY2 =
struct

  (* This is a temporary implementation of 2D mono-array of Char.char.
   * We should have a functor from which 2D mono-arrays are generated for
   * each element type.
   * One of advantages of this functorized implementation is that we can have
   * the internal format specialized for each element type.
   *
   * However, there is not so much need to specialize the internal format of
   * 2D array.
   * As for 1D array, we can pass it to FFI directly, and therefore we must
   * agree with foreign functions about its internal format.
   * On the other hand, we will not allow passing 2D array through FFI,
   * because 2D array contains extra information which should not be exposed
   * to foreign world.
   *)

  open Array2

  type elem = Char.char
  type array = elem array
  type vector = CharVector.vector
  type region = elem region
  datatype traversal = datatype Array2.traversal

  fun vectorToCharVector vector =
      CharVector.tabulate
          (Vector.length vector, fn i => Vector.sub (vector, i))
  val row = fn arg => vectorToCharVector (row arg)
  val column = fn arg => vectorToCharVector (column arg)

end