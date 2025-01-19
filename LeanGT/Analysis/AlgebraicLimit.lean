import LeanGT.Analysis.Bounded
import LeanGT.Analysis.TendsTo

noncomputable def max_prefix : ((ℕ → ℝ)) → ℕ → ℝ
| _, 0   => 0
| f, x+1 => max (f x) (max_prefix f x)

theorem mp_def (f : ℕ → ℝ) (b : ℕ) : max_prefix f (b+1) = max (f b) (max_prefix f b) := by rfl

theorem mp_increasing (f : ℕ → ℝ) (a : ℕ) (b : ℕ) (hi : a < b): f a ≤ max_prefix f b := by
  induction' b with x y
  exfalso
  exact Nat.not_succ_le_zero a hi
  rw [mp_def]
  have a_cases : a < x ∨ a = x := by exact Nat.lt_succ_iff_lt_or_eq.mp hi
  cases' a_cases with p q
  apply y at p
  exact le_max_of_le_right p
  rw [q]
  exact le_max_left (f x) (max_prefix f x)

-- Any finite prefix of a sequence has an upper bound
theorem FinitePrefixMax (f : ℕ → ℝ) (N : ℕ) : ∃ B, ∀ n : ℕ, n < N → f n ≤ B := by
  use max_prefix f N
  intro n hnB
  apply mp_increasing
  exact hnB

-- Any finite prefix of a sequence has a magnitude bound
theorem FinitePrefixMax' (f : ℕ → ℝ) (N : ℕ) : ∃ B, ∀ n : ℕ, n < N → |f n| ≤ B := by
  exact FinitePrefixMax (fun n ↦ |f n|) N

-- Theorem 2.3.2 from Abbott. Converges => Bounded
theorem ConvergesThenBounded (f : ℕ → ℝ) (hc : ∃ t, TendsTo f t) : Bounded f := by
  cases' hc with l h_TendsTo_l
  specialize h_TendsTo_l 1 (by norm_num)

  cases' h_TendsTo_l with N hN

  have h := FinitePrefixMax' f N

  cases' h with B hB

  use (max (1 + Nat.ceil B) (Nat.ceil (|l|+2)))

  constructor
  . rw [lt_max_iff]; left; linarith

  intro n

  cases (le_or_lt N n) with
  | inl N_lt_n => {
    rw [lt_max_iff]
    right

    have fn_near_l := hN n N_lt_n

    have h6: |f n| - |l| ≤ |f n - l| := abs_sub_abs_le_abs_sub (f n) l
    have h7: |f n| - |l| < 1 := by linarith
    calc
      |f n| < |l| + 1 := sub_lt_iff_lt_add'.mp h7
      _ ≤ |l| + 2 := by linarith
      _ ≤ ↑⌈|l| + 2⌉₊ := Nat.le_ceil (|l| + 2)
  }
  | inr h1 => {
    simp
    left

    calc
      |f n| ≤ B := hB n h1
      _ < (1 + ⌈B⌉₊) := by {
        calc
          B ≤ ↑⌈B⌉₊ := Nat.le_ceil B
          _ < 1 +  ↑⌈B⌉₊ := by apply lt_one_add
      }
  }

theorem tendsTo_mul_constant_nz
  {a : ℕ → ℝ}
  {c A : ℝ}
  (c_pos : c ≠ 0)
  (ha : TendsTo a A)
: TendsTo (fun n ↦ c * a n) (c * A) := by
  intro ε hε
  dsimp
  cases' (ha (ε / |c|) (by positivity)) with B hB
  use B
  intro n hn
  rw [show c * a n - c * A = c * (a n - A) by ring, abs_mul c (a n - A)]
  specialize hB n hn
  have c_pos : 0 < |c| := by positivity
  exact (lt_div_iff₀' c_pos).mp hB

-- Theorem 2.3.3.i
theorem tendsTo_mul_constant
  {a : ℕ → ℝ}
  {c A : ℝ}
  (ha : TendsTo a A)
: TendsTo (fun n ↦ c * a n) (c * A) := by
  cases' (eq_or_ne c 0) with c_eq_0 c_ne_0
  rw [c_eq_0]
  ring_nf
  exact tendsTo_const 0
  exact tendsTo_mul_constant_nz c_ne_0 ha

-- Theorem 2.3.3.ii
theorem tendsTo_sum
  {a b : ℕ → ℝ}
  {A B : ℝ}
  (ha : TendsTo a A)
  (hb : TendsTo b B)
: TendsTo (fun n ↦ a n + b n) (A + B) := by
  intro ε hε
  dsimp
  cases' (ha (ε/2) (by positivity)) with N₁ hN₁
  cases' (hb (ε/2) (by positivity)) with N₂ hN₂
  use max N₁ N₂
  intro n hn
  have hn1 : N₁ ≤ n := by omega
  have hn2 : N₂ ≤ n := by omega
  rw [show a n + b n - (A + B) = a n - A + (b n - B) by ring]
  calc
    |a n - A + (b n - B)|  ≤ |a n - A| + |b n - B| := abs_add_le (a n - A) (b n - B)
    _ < ε / 2 + |b n - B|  := by gcongr ; exact hN₁ n hn1
    _ < ε / 2 + ε / 2 := by gcongr ; exact hN₂ n hn2
    _ = ε := by ring

-- Theorem 2.3.3.iii (algebraic limit theorem, product)
theorem tendsTo_mul
  {a b : ℕ → ℝ}
  {A B : ℝ}
  (a_pos : A ≠ 0)
  (ha : TendsTo a A)
  (hb : TendsTo b B)
: TendsTo (fun n ↦ a n * b n) (A * B) := by
  intro ε hε

  have h_b_bounded := ConvergesThenBounded b (Exists.intro B hb)
  cases' h_b_bounded with M hM
  cases' hM with m_pos m_bounds

  have h_exists_n1 := hb (ε/(2*|A|)) (by positivity)
  cases' h_exists_n1 with n1 hn1

  have h_exists_n2 := ha (ε/(2*M)) (by positivity)
  cases' h_exists_n2 with n2 hn2

  use max n1 n2

  intro n hn

  calc
    |a n * b n - (A * B)| = |a n * b n - A * b n + (A * b n - A * B)| := by ring_nf
    _ ≤ |a n * b n - A * b n| + |A * b n - A * B| := abs_add (a n * b n - A * b n) (A * b n - A * B)
    _ = |b n * (a n - A)| + |A * (b n - B)| := by ring_nf
    _ = |b n| * |a n - A| + |A * (b n - B)| := by congr; exact abs_mul (b n) (a n - A)
    _ = |b n| * |a n - A| + |A| * |b n - B| := by congr; exact abs_mul A (b n - B)
    _ ≤ M * |a n - A| + |A| * |b n - B| := by {
      simp
      specialize m_bounds n
      have hpos : 0 ≤ |a n - A| := abs_nonneg (a n - A)
      suffices : |b n| ≤ M
      exact mul_le_mul_of_nonneg_right this hpos
      exact LT.lt.le m_bounds
    }
    _ < M * (ε / (2*M)) + |A| * |b n - B| := by
      gcongr
      apply hn2
      exact le_of_max_le_right hn
    _ < M * (ε / (2*M)) + |A| * (ε / (2*|A|)) := by
      gcongr
      apply hn1
      exact le_of_max_le_left hn
    _ = ε := by {
      field_simp
      ring
    }

theorem tendsTo_inv
  {b : ℕ → ℝ}
  {B : ℝ}
  (b_nz : ∀ n, b n ≠ 0)
  (B_nz : B ≠ 0)
  (hb : TendsTo b B)
: TendsTo (fun n ↦ 1 / b n) (1 / B) := by
  intro ε hε
  cases' hb (|B|/2) (by positivity) with N₁ hN₁
  cases' hb (ε * |B|^2 / 2) (by positivity) with N₂ hN₂
  use max N₁ N₂
  intro n hn
  dsimp
  specialize hN₁ n (by omega)
  specialize hN₂ n (by omega)

  specialize b_nz n
  have : 0 < |b n| := by positivity


  have l1 : 1 / b n = B / ((B * b n)) := by
    have : B / (B * b n) = (b n)⁻¹ := by exact div_mul_cancel_left₀ B_nz (b n)
    rw [inv_eq_one_div (b n)] at this
    rw [← this]

  have l2 : 1 / B = b n / ((B * b n)) := by sorry

  have : |B| / 2 < |b n| := by
    sorry

  have : 1 / |b n| < 2 / |B| := by sorry

  calc
    |1 / b n - 1 / B| = |(B - b n) / (B * b n)| := by
      apply congrArg
      rw [l1, l2]
      ring
    _ = |(B - b n)| / |(B * b n)| := by exact abs_div (B - b n) (B * b n)
    _ = |(B - b n)| * 1 / |B * b n| := by field_simp
    _ = |(B - b n)| * 1 / |B| * 1 / |b n| := by sorry
    _ < ε * |B|^2 / 2 * 1 / |B| * 1 / |b n| := by
      gcongr
      rw [show |B - b n| = |b n - B| by exact abs_sub_comm B (b n)]
      exact hN₂
    _ = ε * |B| / 2 * 1 / |b n| := by
      field_simp
      rw [show B^2 = |B|^2 by exact Eq.symm (sq_abs B)]
      ring
    _ < ε * |B| / 2 * 2 / |B| := by


    _ = ε := by
      field_simp
