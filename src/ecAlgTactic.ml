(* -------------------------------------------------------------------- *)
open EcUtils
open EcTypes
open EcFol
open EcAlgebra

(* -------------------------------------------------------------------- *)
module Axioms = struct
  open EcDecl

  let tmod  = EcPath.fromqsymbol ([EcCoreLib.id_top; "AlgTactic"], "Requires")
  let tname = "domain"

  let zero  = "rzero"
  let one   = "rone"
  let add   = "add"
  let opp   = "opp"
  let sub   = "sub"
  let mul   = "mul"
  let inv   = "inv"
  let div   = "div"
  let expr  = "expr"
  let embed = "ofint"

  let core_add  = ["oner_neq0"; "addr0"; "addrA"; "addrC";]
  let core_mul  = [ "mulr1"; "mulrA"; "mulrC"; "mulrDl"]
  let core      = core_add @ "addrN" :: core_mul
  let core_bool = core_add @ "addrK" :: "mulrK" :: core_mul

  let ofoppbool = ["oppr_id"]
  let intpow    = ["expr0"; "exprS"]
  let ofint     = ["ofint0"; "ofint1"; "ofintS"; "ofintN"]
  let ofsub     = ["subrE"]
  let field     = ["mulrV"; "exprN"]
  let ofdiv     = ["divrE"]

  let ty0 ty = ty
  let ty1 ty = tfun ty (ty0 ty)
  let ty2 ty = tfun ty (ty1 ty)

  let ring_symbols env boolean ty =
    let symbols =
      [(zero, (true , ty0 ty));
       (one , (true , ty0 ty));
       (add , (true , ty2 ty));
       (opp , (not boolean, ty1 ty));
       (sub , (false, ty2 ty));
       (mul , (true , ty2 ty));
       (expr, (false, toarrow [ty; tint] ty))]
    in
      if   EcReduction.EqTest.for_type env ty tint
      then symbols
      else symbols @ [(embed, (false, tfun tint ty))]

  let field_symbols env ty =
    (ring_symbols env false ty)
      @ [(inv, (true , ty1 ty));
         (div, (false, ty2 ty))]

  let subst_of_ring (cr : ring) =
    let crcore = [(zero, cr.r_zero);
                  (one , cr.r_one );
                  (add , cr.r_add );
                  (mul , cr.r_mul ); ] in

    let xpath  = fun x -> EcPath.pqname tmod x in
    let add    = fun subst x p -> EcSubst.add_path subst (xpath x) p in
    
    let subst  = 
      EcSubst.add_tydef EcSubst.empty (xpath tname) ([], cr.r_type) in
    let subst  =
      List.fold_left (fun subst (x, p) -> add subst x p) subst crcore in
    let subst  = odfl subst (cr.r_opp |> omap (fun p -> add subst opp p)) in
    let subst  = odfl subst (cr.r_sub |> omap (fun p -> add subst sub p)) in
    let subst  = odfl subst (cr.r_exp |> omap (fun p -> add subst expr p)) in

    let subst  = 
      cr.r_embed |> 
          (function `Direct | `Default -> subst | `Embed p -> add subst embed p)
    in
      subst

  let subst_of_field (cr : field) =
    let xpath  = fun x -> EcPath.pqname tmod x in
    let add    = fun subst x p -> EcSubst.add_path subst (xpath x) p in

    let subst = subst_of_ring cr.f_ring in
    let subst = add subst inv cr.f_inv in
    let subst = odfl subst (cr.f_div |> omap (fun p -> add subst div p)) in
      subst

  (* FIXME: should use operators inlining when available *)
  let get cr env axs =
    let subst  =
      match cr with
      | `Ring  cr -> subst_of_ring  cr
      | `Field cr -> subst_of_field cr
    in

    let for1 axname =
      let ax = EcEnv.Ax.by_path (EcPath.pqname tmod axname) env in
        assert (ax.ax_tparams = [] && ax.ax_kind = `Axiom && ax.ax_spec <> None);
        (axname, EcSubst.subst_form subst (oget ax.ax_spec))
    in
      List.map for1 axs

  let getr env cr axs = get (`Ring cr) env axs
  let getf env cr axs = get (`Field cr) env axs 

  let ring_axioms env (cr : ring) =
    let axcore = 
      if cr.r_bool then getr env cr core_bool
      else getr env cr core in
    let axint  = 
      match cr.r_embed with 
      | `Direct | `Default -> [] | `Embed _ -> getr env cr ofint in
    let axopp = 
      match cr.r_opp with
      | Some _ when cr.r_bool -> getr env cr ofoppbool
      | _ -> [] in
    let axsub  = 
      match cr.r_sub with None -> [] | Some _ -> getr env cr ofsub in
    let axexp  = 
      match cr.r_exp with None -> [] | Some _ -> getr env cr intpow in

    List.flatten [axcore; axopp; axexp; axint; axsub]

  let field_axioms env (cr : field) =
    let axring = ring_axioms env cr.f_ring in
    let axcore = getf env cr field in
    let axdiv  = match cr.f_div with None -> [] | Some _ -> getf env cr ofdiv in
    List.flatten [axring; axcore; axdiv]

end

let ring_symbols  = Axioms.ring_symbols
let field_symbols = Axioms.field_symbols

let ring_axioms  = Axioms.ring_axioms
let field_axioms = Axioms.field_axioms

(* -------------------------------------------------------------------- *)
open EcBaseLogic
open EcLogic
open EcReduction

class rn_ring_congr = object inherit xrule "ring_congr"  end
class rn_ring_norm  = object inherit xrule "ring_norm"  end
class rn_ring       = object inherit xrule "ring"  end
class rn_field      = object inherit xrule "field" end

let rn_ring_congr = RN_xtd (new rn_ring_congr)
let rn_ring_norm  = RN_xtd (new rn_ring_norm) 
let rn_ring       = RN_xtd (new rn_ring)
let rn_field      = RN_xtd (new rn_field)

let n_ring_congr juc hyps (cr:cring) (rm:RState.rstate) f li lv =
  let pe,rm = toring cr rm f in
  let rm' = RState.update rm li lv in
  let env = EcEnv.LDecl.toenv hyps in
  let mk_goal i =
    let r1 = oget (RState.get i rm) in
    let r2 = oget (RState.get i rm') in
    EqTest.for_type_exn env r1.f_ty r2.f_ty;
    f_eq r1 r2 in 
  let f' = ofring (ring_of_cring cr) rm' pe in
  let g = new_goal juc (hyps, f_eq f f') in
  let sg = List.map mk_goal li in
  let gs = prove_goal_by sg rn_ring_congr g in
  f', snd g, gs

let n_ring_norm juc hyps (cr:cring) (rm:RState.rstate) f =
  let pe, rm = toring cr rm f in
  let ofring = ofring (ring_of_cring cr) rm in
  let npe    = ring_simplify_pe cr [] pe in
  let f'     = ofring npe in
  let g      = new_goal juc (hyps, f_eq f f') in
  let gs     = prove_goal_by [] rn_ring_norm g in
  rm, f', snd g, gs

let t_ring_simplify cr eqs (f1, f2) g =
  let cr = cring_of_ring cr in
  let f1 = ring_simplify cr eqs f1 in
  let f2 = ring_simplify cr eqs f2 in
	prove_goal_by [f_eq f1 f2] rn_ring g

let t_ring r eqs (f1, f2) g =
  let cr = cring_of_ring r in
  let f  = ring_eq cr eqs f1 f2 in
  if   EcReduction.is_conv (get_hyps g) f (emb_rzero r)
  then prove_goal_by [] rn_ring g
  else prove_goal_by [f_eq f (emb_rzero r)] rn_ring g

let t_field_simplify r eqs (f1, f2) g =
  let cr = cfield_of_field r in
  let (c1, n1, d1) = field_simplify cr eqs f1 in
  let (c2, n2, d2) = field_simplify cr eqs f2 in

  let c = List.map (fun f -> f_not (f_eq f (emb_fzero r))) (c1 @ c2) in
  let f = f_eq (fdiv r n1 d1) (fdiv r n2 d2) in

    prove_goal_by (c @ [f]) rn_field g

let t_field r eqs (f1, f2) g =
  let cr = cfield_of_field r in
  let (c, (n1, n2), (d1, d2)) = field_eq cr eqs f1 f2 in
  let c  = List.map (fun f -> f_not (f_eq f (emb_fzero r))) c in
  let r1 = fmul r n1 d2
  and r2 = fmul r n2 d1 in
  let f  = ring_eq (cring_of_ring r.f_ring) eqs r1 r2 in

    if   EcReduction.is_conv (get_hyps g) f (emb_fzero r)
    then prove_goal_by c rn_field g
    else prove_goal_by (c @ [f_eq f (emb_fzero r)]) rn_field g

(* -------------------------------------------------------------------- *)
let is_module_loaded env =
  EcEnv.Theory.by_path_opt Axioms.tmod env <> None
