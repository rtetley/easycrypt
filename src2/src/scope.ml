(* -------------------------------------------------------------------- *)
open Symbols

(* -------------------------------------------------------------------- *)
module Context = struct
  module SM = Maps.StringMap

  module V : sig
    type 'a t

    val empty  : unit -> 'a t
    val push   : 'a -> 'a t -> 'a t
    val iter   : ('a -> unit) -> 'a t -> unit
    val fold   : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
    val tolist : 'a t -> 'a list
  end = struct
    type 'a data = {
      v_front : 'a list;
      v_back  : 'a list;
    }

    type 'a t = ('a data) ref

    let normalize =
      let normalize (v : 'a data) ={
        v_front = List.rev_append (List.rev v.v_front) v.v_back;
        v_back  = [];
      } in
        fun v ->
          if !v.v_back <> [] then v := normalize !v; !v

    let empty () =
      ref { v_front = []; v_back = []; }

    let push (x : 'a) (v : 'a t) =
      ref { v_front = !v.v_front; v_back = x :: !v.v_back }

    let iter (f : 'a -> unit) (v : 'a t) =
      List.iter f (normalize v).v_front

    let fold (f : 'b -> 'a -> 'b) (state : 'b) (v : 'a t) =
      List.fold_left f state (normalize v).v_front

    let tolist (v : 'a t) = (normalize v).v_front
  end

  type symbol = string

  type 'a context = {
    ct_map   : 'a SM.t;
    ct_order : (string * 'a) V.t;
  }

  exception DuplicatedNameInContext of string
  exception UnboundName of string

  let empty () = { ct_map = SM.empty; ct_order = V.empty (); }

  let bind (x : symbol) (v : 'a) (m : 'a context) =
    if SM.mem x m.ct_map then
      raise (DuplicatedNameInContext x);
    { ct_map   = SM.add x v m.ct_map;
      ct_order = V.push (x, v) m.ct_order; }

  let rebind (x : symbol) (v : 'a) (m : 'a context) =
    if not (SM.mem x m.ct_map) then
      raise (UnboundName x);
    { ct_map   = SM.add x v m.ct_map;
      ct_order = m.ct_order; }

  let exists (x : symbol) (m : 'a context) =
    SM.mem x m.ct_map

  let lookup (x : symbol) (m : 'a context) =
    try  Some (SM.find x m.ct_map)
    with Not_found -> None

  let iter (f : symbol -> 'a -> unit) (m : 'a context) =
    V.iter (fun (x, v) -> f x v) m.ct_order

  let fold (f : 'b -> symbol -> 'a -> 'b) (state : 'b) (m : 'a context) =
    V.fold (fun st (x, v) -> f st x v) state m.ct_order

  let tolist (m : 'a context) =
    V.tolist m.ct_order
end

(* -------------------------------------------------------------------- *)
type module_expr = {
  me_name      : symbol;
  me_body      : module_expr_body;
  me_interface : interface_body;
}

and module_expr_body =
  | ME_Ident       of Path.path
  | ME_Application of Path.path * Path.path list
  | ME_Structure   of (symbol * interface) list

and interface = module_

  m_name : Path.path;
  m_body : module_body;
}

and module_de

and interface_ = {
  i_name : Path.path;
  i_body : interface_body;
}

and module_body = module_item list;

type pretheory = pretheory_item list

and premodule = {
  pm_name : symbol;
  pm_args : (symbol * interface_body) list;
  pm_body : premodule_item list;
}

and preinterface = {
  pm_name : symbol;
  pm_body : preinterface_item list;
}

and pretheory_item = [
  | `Operator   of operator
  | `Axiom      of axiom
  | `Interface  of interface
  | `Module     of module_
  | `ModuleDecl of module_decl
]

and premodule_item = [
  | `Module   of module_
  | `Variable of variable
  | `Function of function_
]

and preinterface_item = [
  | `FunctionDecl of function_decl
  | `VariableDecl of variable_decl
]

type preobj = [
  | `Operator     of operator
  | `Axiom        of axiom
  | `Interface    of interface
  | `Module       of module_
  | `ModuleDecl   of module_decl
  | `FunctionDecl of function_decl
  | `VariableDecl of variable_decl
]

type scope = {
  sc_scope : pretheory;
  sc_focus : Path.path;
}

let resolve (po : preobj) (p : Path.t) =

(* -------------------------------------------------------------------- *)


(* -------------------------------------------------------------------- *)
let resolve (scope : scope) (path: qsymbol) = None

module Op = struct
  type op = {
    op_path : Path.path;
    op_sig  : Types.ty list * Types.ty;
  }

  let resolve (scope : scope) (path : qsymbol) (sg : Types.ty list) =
    None
end

module Ty = struct
  let resolve (scope : scope) (path : qsymbol) = None
end
