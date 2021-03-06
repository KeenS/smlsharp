infix 7 * / div mod
infix 6 + - ^
infixr 5 :: @
infix 4 = <> > >= < <=
infix 3 := o
val op + = SMLSharp_Builtin.Int.add_unsafe
val op - = SMLSharp_Builtin.Int.sub_unsafe
val op > = Position.>
val op < = Position.<
structure StringImp = String
structure IntImp = Int
structure PositionImp = Position
structure PosixBinPrimIO = struct end (* dummy *)
structure Posix =
struct
  structure FileSys = SMLSharp_SMLNJ_POSIX_IO
  structure IO = SMLSharp_SMLNJ_POSIX_IO
end
(* posix-text-prim-io.sml
 *
 * COPYRIGHT (c) 1995 AT&T Bell Laboratories.
 *
 * This implements the UNIX version of the OS specific text primitive
 * IO structure.  It is implemented by a trivial translation of the
 * binary operations (see posix-bin-prim-io.sml).
 *
 *)

local
    structure String = StringImp
    structure Int = IntImp
    structure Position = PositionImp
in
(*
structure PosixTextPrimIO : sig
*)
structure SMLSharp_SMLNJ_PosixTextPrimIO (*: sig

    include OS_PRIM_IO

    val stdIn  : unit -> PrimIO.reader
    val stdOut : unit -> PrimIO.writer
    val stdErr : unit -> PrimIO.writer

    val strReader : string -> PrimIO.reader

  end*) = struct

    structure PF = Posix.FileSys
    structure PIO = Posix.IO
    structure BinPrimIO = PosixBinPrimIO
    structure PrimIO = TextPrimIO

    type file_desc = PF.file_desc

    val bufferSzB = 4096

    val mkReader = PIO.mkTextReader
    val mkWriter = PIO.mkTextWriter

    fun announce s x y = (
	  (*print "Posix: "; print (s:string); print "\n"; *)
	  x y)

    fun openRd name =
(*
	mkReader { fd = announce "openf"
				 PF.openf (name, PIO.O_RDONLY, PF.O.flags []),
*)
	mkReader { fd = PIO.openf (name, "r"),
		   name = name,
		   initBlkMode = true }

(*
    val standardMode = PF.S.flags[	(* mode 0666 *)
	    PF.S.irusr, PF.S.iwusr,
	    PF.S.irgrp, PF.S.iwgrp,
	    PF.S.iroth, PF.S.iwoth
	  ]

    fun createFile (name, mode, flags) =
	announce "createf" PF.createf (name, mode, flags, standardMode)
*)

    fun openWr name =
(*
	mkWriter { fd = createFile (name, PIO.O_WRONLY, PF.O.trunc),
*)
	mkWriter { fd = PIO.openf (name, "w"),
		   name = name,
		   initBlkMode = true,
		   appendMode = false,
		   chunkSize = bufferSzB }

    fun openApp name =
(*
	mkWriter { fd = createFile (name, PIO.O_WRONLY, PF.O.append),
*)
	mkWriter { fd = PIO.openf (name, "a"),
		   name = name,
		   initBlkMode = true,
		   appendMode = true,
		   chunkSize = bufferSzB }

    fun stdIn () = mkReader{
	    fd		= PF.stdin,
	    name	= "<stdIn>",
	    initBlkMode	= true (* Bug!  Should check! *)
	  }

    fun stdOut () = mkWriter{
	    fd		= PF.stdout,
	    name	= "<stdOut>",
	    initBlkMode	= true (* Bug!  Should check! *),
	    appendMode	= false (* Bug!  Should check! *),
	    chunkSize	= bufferSzB
	  }

    fun stdErr () = mkWriter{
	    fd		= PF.stderr,
	    name	= "<stdErr>",
	    initBlkMode	= true, (* Bug!  Should check! *)
	    appendMode	= false, (* Bug!  Should check! *)
	    chunkSize	= bufferSzB
	  }

    fun strReader src = let
	  val pos = ref 0
	  val closed = ref false
	  fun checkClosed () = if !closed then raise IO.ClosedStream else ()
	  val len = String.size src
	  val plen = Position.fromInt len
	  fun avail () = len - !pos
	  fun readV n = let
		val p = !pos
		val m = Int.min(n, len-p)
		in
		  checkClosed ();
		  pos := p+m;
(** NOTE: could use unchecked operations here **)
		  String.substring (src, p, m)
		end
	  fun readA asl = let
		val p = !pos
		val (buf, i, n) = CharArraySlice.base asl
		val m = Int.min(n, len-p)
	  in
	      checkClosed ();
	      pos := p+m;
	      CharArraySlice.copyVec
		  { src = CharVectorSlice.slice (src, p, SOME m),
		    dst = buf, di = i };
	      m
	  end
	  fun getPos () = (checkClosed(); Position.fromInt (!pos))
	  fun setPos p =
	      (checkClosed ();
(*
	       if p < 0 orelse p > plen then raise Subscript
*)
	       if p < Position.fromInt 0 orelse p > plen then raise Subscript
	       else pos := Position.toInt p)
	  in
	    PrimIO.RD{
		name      = "<string>", 
		chunkSize = len,
		readVec   = SOME(readV),
        	readArr   = SOME(readA),
		readVecNB = SOME(SOME o readV),
		readArrNB = SOME(SOME o readA),
		block     = SOME(checkClosed),
		canInput  = SOME(fn () => (checkClosed(); true)),
		avail     = SOME o avail,
		getPos    = SOME getPos,
		setPos    = SOME setPos,
        	endPos    = SOME(fn () => (checkClosed(); plen)),
		verifyPos = SOME getPos,
		close     = fn () => closed := true,
		ioDesc    = NONE
	      }
	  end

  end (* PosixTextPrimIO *)
end

