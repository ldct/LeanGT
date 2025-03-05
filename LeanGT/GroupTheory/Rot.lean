import Mathlib.Tactic
import Mathlib.GroupTheory.SpecificGroups.Dihedral

namespace DihedralGroup

-- The subgroup of rotations
def Rot (n : ℕ): Subgroup (DihedralGroup n) where
  carrier := { r i | i : ZMod n }
  mul_mem' := by
    intros a b a_is_ri b_is_ri
    cases' a_is_ri with i1 r_i1_is_a
    cases' b_is_ri with i2 r_i1_is_b
    use i1 + i2
    rw [←r_i1_is_a, ←r_i1_is_b]
    rw [r_mul_r]
  one_mem' := by
    use 0
    rfl
  inv_mem' := by
    intros x x_in_A
    cases' x_in_A with i ri_is_x
    use -i
    rw [← ri_is_x]
    rfl

-- API for `Rot n`
theorem mem_rot_iff (g : DihedralGroup n) : g ∈ Rot n ↔ g ∈ { r i | i : ZMod n } := by
  rfl

-- API for `Rot n`
theorem mem_rot_iff' (g : DihedralGroup n) : g ∈ (Rot n).carrier ↔ g ∈ { r i | i : ZMod n } := by
  rfl


theorem inv_r_simp (i : ZMod n) : (r i)⁻¹ = r (-i) := by
  rfl

theorem r_one_pow'' (k : ℤ) : (r 1 : DihedralGroup n) ^ k = r k := by
  rcases (le_or_lt 0 k) with pos | neg
  . lift k to ℕ using pos
    simp only [zpow_natCast, r_one_pow, Int.cast_natCast]
  . have : ∃ l : ℤ, l = -k ∧ k = -l ∧ l ≥ 0 := by
      use -k
      simp only [neg_neg, ge_iff_le, Left.nonneg_neg_iff, true_and]
      linarith
    cases' this with l conds
    rw [conds.2.1]
    lift l to ℕ using conds.2.2
    simp [inv_r_simp]

example (n : ℕ) : IsCyclic (Rot n) := ⟨ ⟨r 1, by use 1⟩, by
  intro ⟨x, ⟨i, hi⟩⟩
  use i.valMinAbs
  simp
  refine SetLike.coe_eq_coe.mp ?_
  simp
  rw [r_one_pow'']
  rw [← hi]
  simp
⟩

/-
It might be helpful to note that in Mathlib, a subgroup is a structure consisting of a carrier set as well as proofs that the carrier set forms obey certain properties. As an example from a concrete subgroup, the subgroup of rotations of a dihedral group can be defined as:

```
import Mathlib.Tactic
import Mathlib.GroupTheory.SpecificGroups.Dihedral

namespace DihedralGroup

def Rot (n : ℕ): Subgroup (DihedralGroup n) where
  carrier := { r i | i : ZMod n }
  mul_mem' := by
    intros a b a_is_ri b_is_ri
    cases' a_is_ri with i1 r_i1_is_a
    cases' b_is_ri with i2 r_i1_is_b
    use i1 + i2
    rw [←r_i1_is_a, ←r_i1_is_b]
    rw [r_mul_r]
  one_mem' := by
    use 0
    rfl
  inv_mem' := by
    intros x x_in_A
    cases' x_in_A with i ri_is_x
    use -i
    rw [← ri_is_x]
    rfl
```

`carrier` is the set of elements, and the other fields are proofs.

So the translation of the definition of a kernel is:

Definition. If ϕ is a homomorphism ϕ: G → H, the kernel of ϕ, denoted by ker φ is a structure consisting of four fields:

- (ker φ).carrier, a set defined as { g ∈ G | ϕ(g)=1 }
- (ker φ).mul_mem', a proof that `(ker φ).carrier` is closed under multiplication
- (ker φ).one_mem', a proof that `(ker φ).carrier` contains 1
- (ker φ).inv_mem', a proof that `(ker φ).carrier` is closed under inversion
-/
