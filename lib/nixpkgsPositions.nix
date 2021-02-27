{lib
}:
let
  getPosition = v: v.meta.position or null;
  isDrv = attrset: attrset ? "type" && attrset.type == "derivation";
  shouldRecurse = attrset: !(isDrv attrset) && (attrset.recurseForDerivations or false);

  tryMapAttrsRecursiveCond = cond: f: set:
    let
      recurse = path: set:
        let
          g =
            name: value:
            if builtins.isAttrs value && cond value
              then recurse (path ++ [name]) value
              else f (path ++ [name]) value;
          tryG = name: value:
            (builtins.unsafeSuperTryEval (g name value)).value or null;
        in builtins.mapAttrs tryG set;
    in recurse [] set;
in
  pkgs: tryMapAttrsRecursiveCond
    shouldRecurse
    (name: value: if isDrv value then (getPosition value) else false)
    pkgs