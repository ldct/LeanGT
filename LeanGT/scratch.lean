import Mathlib.Tactic
import Mathlib.Algebra.Group.Defs
import Mathlib.GroupTheory.SpecificGroups.Cyclic
import Mathlib.GroupTheory.SpecificGroups.Dihedral
import LeanGT.ZMul

example : (IsAddCyclic ℤ) := ⟨ 1, by
  intro x
  use x
  simp
⟩

example : (IsAddCyclic ℤ) := ⟨ -1, by
  intro x
  use -x
  simp
⟩

-- example : ¬ IsCyclic ((DihedralGroup 6) × (DihedralGroup 6)) := by
--   intro x
--   sorry

namespace ZMul

example (a b : ℤ) : a * b = 1 → a = 1 ∨ a = -1 := by
  exact fun a_1 ↦
  Int.eq_one_or_neg_one_of_mul_eq_one a_1

example (a b : ℤ) : a * b = 1 → b = 1 ∨ b = -1 := by
  rw [mul_comm]
  exact fun a_1 ↦ Int.eq_one_or_neg_one_of_mul_eq_one a_1

example (a : ℤ) (Hpos : a ≠ 0) : a / a = 1 := by
  exact Int.ediv_self Hpos

theorem mul_div_cancel (a b : ℤ) (b_ne_0 : b ≠ 0) : (a * b) / b = a * (b / b) := by
  refine (Int.ediv_eq_iff_eq_mul_left ?_ ?_).mpr ?_
  exact b_ne_0
  exact Int.dvd_mul_left a b
  simp
  left
  have : b / b = 1 := by exact Int.ediv_self b_ne_0
  rw [this]
  simp

-- 12c, p60
example : ¬ IsCyclic ((ZMul) × (ZMul)) := by
  rintro ⟨ g, g_surj ⟩
  obtain ⟨ e, he ⟩ := g_surj (r 0, r 1)
  simp at he
  have : g^e = (_, (r g.2.1)^e) := rfl
  rw [this] at he
  simp only [Prod.mk.injEq] at he
  obtain hg01 := he.2
  rw [r_pow] at hg01
  simp at hg01
  have fst_nz : g.2.1 ≠ 0 := by exact left_ne_zero_of_mul_eq_one hg01

  obtain ⟨ e, he ⟩ := g_surj (r 1, r 0)
  simp at he
  have : g^e = ((r g.1.1)^e, _) := rfl
  rw [this] at he
  simp only [Prod.mk.injEq] at he
  obtain hg01 := he.1
  rw [r_pow] at hg01
  simp at hg01
  have snd_nz : g.1.1 ≠ 0 := by exact left_ne_zero_of_mul_eq_one hg01

  obtain ⟨ k, hk ⟩ := g_surj (r g.1.1, r (- g.2.1))
  simp at hk

  have : g^k = ((r g.1.1)^k, (r g.2.1)^k) := rfl
  rw [this] at hk
  simp only [Prod.mk.injEq] at hk

  have := hk.left
  rw [r_pow] at this
  simp at this
  have k_eq_1 : k = 1 := by exact Int.eq_one_of_mul_eq_self_right snd_nz this

  have := hk.right
  rw [r_pow] at this
  simp at this
  have t : k = -g.2.1/g.2.1 := by exact Int.eq_ediv_of_mul_eq_right fst_nz this



  have : -g.2.1 = -1 * g.2.1 := by exact Int.neg_eq_neg_one_mul g.2.1

  rw [this] at t

  simp only [mul_div_cancel (-1) _ fst_nz] at t
  have : g.2.1 / g.2.1 = 1 := by exact Int.ediv_self fst_nz
  rw [this] at t
  simp at t

  rw [k_eq_1] at t
  norm_num at t




theorem test [Group G] (a b : G) (a_eq_b : a = b) :  a⁻¹ = b⁻¹ := by
  exact congrArg Inv.inv a_eq_b

theorem t [Group G] (h g : G) : h⁻¹ = g⁻¹ → h = g  := by
  intro x
  have := test h⁻¹ g⁻¹ x
  simp at this
  exact this

-- probably not what it seems
example : IsCyclic ((ZMod 2) × (ZMod 3)) := by
  use (1, 1)
  refine Function.HasRightInverse.surjective ?_

  sorry
