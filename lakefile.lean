import Lake
open Lake DSL

package «LeanGT» where
  -- Settings applied to both builds and interactive editing
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]
  -- add any additional package configuration options here

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

require "kmill" / "LeanTeX"

require LeanTeX_Mathlib
  from git "https://github.com/kmill/LeanTeX-mathlib"

@[default_target]
lean_lib «LeanGT» where
  -- add any library configuration options here
