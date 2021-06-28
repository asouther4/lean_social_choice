import data.real.basic
import data.finset.lattice 
import data.set.basic

open finset

--we think of social states as type σ and inidividuals as type ι
variables {σ ι : Type} [decidable_eq σ] [decidable_eq ι]
variable [fintype ι]

-- Important Definitions -- 


/- A social welfare function satisfies the Weak Pareto Criterion if for any two
  social states x and y, every individual ranks y higher than x
  then society must rank y higher than x. -/
def weak_pareto (f : (ι → σ → ℝ) → σ → ℝ) (X : finset σ) : Prop := 
∀ (x ∈ X) (y ∈ X) (P : ι → σ → ℝ), (∀ i : ι, P i x < P i y) → (f P) x < (f P) y

/- Suppose in two utility functions
  all individuals rank x and y in the exact same order 
  A social welfare function is Independent of Irrelevant Alternatives if two -/
def ind_of_irr_alts (f : (ι → σ → ℝ) → σ → ℝ) (X : finset σ) : Prop := 
∀ (x ∈ X) (y ∈ X) (P P' : ι → σ → ℝ), 
  (∀ i : ι, P i x < P i y ↔ P' i x < P' i y) →
    (f P x < f P y ↔ f P' x < f P' y)

/- A social welfare function is a dicatorship if a single individual i 
  possesses the power to determine the group's ordering of any two social states. -/
def is_dictatorship (f : (ι → σ → ℝ) → σ → ℝ) (X : finset σ) : Prop :=
∃ i : ι, ∀ (x y ∈ X) (P : ι → σ → ℝ), P i x < P i y → f P x < f P y

/- A social state b is at the bottom of the set X with respect to the ranking p
  if b is ranked strictly lower than every other a ∈ X. -/
def is_bot_of (b : σ) (p : σ → ℝ) (X : finset σ) : Prop :=
∀ a ∈ X, a ≠ b → p b < p a

/- A social state b is at the top of the set X with respect to the ranking p
  if b is ranked strictly higher than every other a ∈ X. -/
def is_top_of (b : σ) (p : σ → ℝ) (X : finset σ): Prop := 
∀ a ∈ X, a ≠ b → p a < p b

/- A social state b is exremal with respect to the set X the ranking p
  if b is either at the bottom or the top. -/
def is_extremal (b : σ) (p : σ → ℝ) (X : finset σ) : Prop := 
is_bot_of b p X ∨ is_top_of b p X

/- Social sates x, y, x', and y' are in the same order with respect to two rankings
p and p' if x and y have the same ordering in p as x' and y' have in p'. -/
def same_order (p p' : σ → ℝ) (x y x' y' : σ) : Prop :=
(p x < p y ↔ p' x' < p' y') ∧ (p y < p x ↔ p' y' < p' x')

/- An individual i is pivotal over a social state b if we can find two
    rankings P and P' with the following properties: 
  
  ⋆ all individuals except for i place all social states in the same order in both rankings
  ⋆ all individuals (including i) place b in an extremal position in both rankings
  ⋆ i places b at the bottom of her rankings in P, but the top of her rankigns in P'
  ⋆ society places b at the bottom of its rankings in P, but the top of its rankings in P' -/
def is_pivotal (f : (ι → σ → ℝ) → (σ → ℝ)) (X : finset σ) 
  (i : ι) (b : σ) : Prop := 
∃ (P P' : ι → σ → ℝ),
  (∀ j : ι, j ≠ i → ∀ x y ∈ X, same_order (P j) (P' j) x y x y) ∧ 
    (∀ i : ι, is_extremal b (P i) X) ∧ (∀ i : ι, is_extremal b (P' i) X) ∧
      (is_bot_of b (P i) X) ∧ (is_top_of b (P' i) X) ∧ (is_bot_of b (f P) X) ∧ (is_top_of b (f P') X)

/- An individual is a dictator *except* for b if she is a dictator over every 
  pair of alternatives distinct alternatives not equal to b.  -/
def is_dictator_except (f : (ι → σ → ℝ) → (σ → ℝ))
  (X : finset σ) (i : ι) (b : σ) : Prop := 
∀ a ∈ X, ∀ c ∈ X, a ≠ b → c ≠ b → ∀ P : ι → σ → ℝ, P i a < P i c → f P a < f P c

open classical

/- Given an arbitary ranking p, `maketop b X` outputs a new ranking
  which is the exact same as p except b is now placed at the top of the set X. -/
noncomputable def maketop (p : σ → ℝ) (b : σ) (X : finset σ) (h : X.nonempty): σ → ℝ :=
function.update p b $ ((X.image p).max' (h.image p)) + 1

/- Given an arbitary ranking p, `makebot b X` outputs a new ranking
  which is the exact same as p except b is now placed at the bottom of the set X. -/
noncomputable def makebot (p : σ → ℝ) (b : σ) (X : finset σ) (h : X.nonempty): σ → ℝ :=
function.update p b $ ((X.image p).min' (h.image p)) - 1

/- Given an arbitary ranking p, `makebetween a b c` outputs a new ranking
  which is the exact same as p except b is now ranked in the middle of a and c.  -/
noncomputable def makebetween (p : σ → ℝ) (a b c : σ) : σ → ℝ :=
function.update p b $ (p a + p c) / 2


---- Preliminary Lemmas ----

lemma maketop_noteq (a b : σ) (ha : a ≠ b) (p : σ → ℝ) (X : finset σ) (hX : X.nonempty) :
  maketop p b X hX a = p a := 
function.update_noteq ha _ p

lemma makebot_noteq (a b : σ) (ha : a ≠ b) (p : σ → ℝ) (X : finset σ) (hX : X.nonempty) :
  makebot p b X hX a = p a := 
function.update_noteq ha _ p

lemma makebetween_noteq (a b c d: σ) (hd : d ≠ b) (p : σ → ℝ) (X : finset σ) (hX : X.nonempty) :
  makebetween p a b c d = p d :=
function.update_noteq hd ((p a + p c) / 2) p

lemma makebetween_eq (a b c : σ) (p : σ → ℝ) (X : finset σ) (hX : X.nonempty) :
  makebetween p a b c b = (p a + p c) / 2 :=
function.update_same _ _ _

--should rename to `maketop_lt_maketop`
lemma lt_of_maketop (a b : σ) (p : σ → ℝ) (a_neq : a ≠ b) (X : finset σ) (hX : X.nonempty)
  (a_in : a ∈ X) : 
  maketop p b X hX a < maketop p b X hX b :=
by simpa [maketop, a_neq] using 
  ((X.image p).le_max' _ (mem_image_of_mem p a_in)).trans_lt (lt_add_one _)

--should rename to `makebot_lt_makebot`
lemma lt_of_makebot (b c : σ) (p : σ → ℝ) (c_neq : c ≠ b) (X : finset σ) (hX : X.nonempty)
  (c_in : c ∈ X) : 
  makebot p b X hX b < makebot p b X hX c :=
by simpa [makebot, c_neq] using sub_lt_iff_lt_add'.mpr 
  (((X.image p).min'_le (p c) (mem_image_of_mem p c_in)).trans_lt (lt_one_add _))

--should rename to `makebetween_lt_makebetween_top`
lemma lt_top_of_makebetween (a b c : σ) (p : σ → ℝ) (c_neq : c ≠ b) (X : finset σ) (hX : X.nonempty) 
  (hc : p a < p c) : 
  makebetween p a b c b < makebetween p a b c c :=
begin
  simp only [makebetween, function.update_same, function.update_noteq c_neq],
  linarith,
end

--should rename to `makebetween_lt_makebetween_bot`
lemma bot_lt_of_makebetween (a b c : σ) (p : σ → ℝ) (a_neq : a ≠ b ) (X : finset σ) (hX : X.nonempty)
  (ha : p a < p c) : 
  makebetween p a b c a < makebetween p a b c b :=
begin
  simp only [makebetween, function.update_same, function.update_noteq a_neq],
  linarith,
end

lemma top_of_maketop (b : σ) (p : σ → ℝ) (X : finset σ) (hX : X.nonempty) :
  is_top_of b (maketop p b X hX) X := λ a a_in a_neq_b, lt_of_maketop a b p a_neq_b X hX a_in


lemma top_of_not_bot_of_extr {b : σ} {p : σ → ℝ} {X : finset σ} 
  (extr : is_extremal b p X) (not_bot : ¬ is_bot_of b p X) :
  is_top_of b p X := 
extr.resolve_left not_bot 

lemma bot_of_not_top_of_extr {b : σ} {p : σ → ℝ} {X : finset σ} 
  (extr : is_extremal b p X) (not_top : ¬ is_top_of b p X) :
  is_bot_of b p X := 
extr.resolve_right not_top 

lemma extremal_of_bot_of {b : σ} {p : σ → ℝ} {X : finset σ} 
  (h_bot: is_bot_of b p X) : is_extremal b p X := by left; exact h_bot


lemma third_distinct_mem {X : finset σ} {a b : σ}
  (hX : 3 ≤ X.card) (a_in : a ∈ X) (b_in : b ∈ X) (h : a ≠ b) : 
  ∃ c ∈ X, c ≠ a ∧ c ≠ b :=
begin
  have hpos : 0 < ((X.erase b).erase a).card,
  { simpa only [card_erase_of_mem, mem_erase_of_ne_of_mem h a_in, b_in]
      using nat.pred_le_pred (nat.pred_le_pred hX) }, 
  cases card_pos.mp hpos with c hc,
  simp_rw mem_erase at hc,
  exact ⟨c, hc.2.2, hc.1, hc.2.1⟩,
end

lemma social_top_of_all_top {f : (ι → σ → ℝ) → σ → ℝ} 
  {X : finset σ} {P : ι → σ → ℝ} {b : σ} (b_in : b ∈ X)
  (hf: weak_pareto f X) (hP : ∀ i : ι, is_top_of b (P i) X) : 
  is_top_of b (f P) X := 
begin
  intros a a_in a_neq_b,
  have hyp : ∀ i : ι, P i a < P i b := λ i, 
    hP i a a_in a_neq_b,
  exact hf a a_in b b_in P hyp,
end

lemma social_bot_of_all_bot {f : (ι → σ → ℝ) → σ → ℝ} 
  {X : finset σ} {P : ι → σ → ℝ} {b : σ} (b_in : b ∈ X)
  (hf: weak_pareto f X) (hP : ∀ i : ι, is_bot_of b (P i) X) : 
  is_bot_of b (f P) X := 
begin
  intros a a_in a_neq_b,
  have hyp : ∀ i : ι, P i b < P i a := λ i, 
    hP i a a_in a_neq_b,
  exact hf b b_in a a_in P hyp,
end


---- The Proof --------


variables {X : finset σ}

lemma first_step {f : (ι → σ → ℝ) → (σ → ℝ)}
  (hwp : weak_pareto f X) (hind : ind_of_irr_alts f X)
  (hX : 3 ≤ X.card)
  (b : σ) (b_in : b ∈ X) (P : ι → σ → ℝ)
  (hyp : ∀ i : ι, is_extremal b (P i) X) :
  is_extremal b (f P) X := 
begin
  have X_ne : X.nonempty := card_pos.1 (by linarith),
  by_contradiction hnot,
  simp only [is_extremal, is_bot_of, is_top_of] at hnot,
  push_neg at hnot,
  have : ∃ t u : σ, t ∈ X ∧ u ∈ X ∧ t ≠ b ∧ u ≠ b ∧ t ≠ u ∧ f P b ≤ f P t ∧ f P u ≤ f P b, -- I changed the variables becuase I found them confusing -Ben
  { obtain ⟨⟨c, c_in, c_neq_b, hc⟩, ⟨a, a_in, a_neq_b, ha⟩⟩ := hnot,
    by_cases hac : a = c,
    { obtain ⟨d, d_in, d_neq_a, d_neq_b⟩ := third_distinct_mem hX a_in b_in a_neq_b,
      by_cases hd : f P b < f P d,
      { exact ⟨d, c, d_in, c_in, d_neq_b, c_neq_b, ne_of_ne_of_eq d_neq_a hac, hd.le, hc⟩, },
      { exact ⟨a, d, a_in, d_in, a_neq_b, d_neq_b, d_neq_a.symm, ha, not_lt.mp hd⟩, }, },
    { exact ⟨a, c, a_in, c_in, a_neq_b, c_neq_b, hac, ha, hc⟩, }, },
  classical,
  rcases this with ⟨a, c, a_in, c_in, a_neq_b, c_neq_b, a_neq_c, ha, hc ⟩,
  let Q : ι → σ → ℝ := λ j, makebetween (P j) a c b,
  let R : ι → σ → ℝ := λ j, function.update (P j) c (P j a + 1),
  let P₂ : ι → σ → ℝ := λ j, if is_top_of b (P j) X then Q j else R j,
  have hP₂ac : ∀ i : ι, P₂ i a < P₂ i c,
  { intros i,
    by_cases b_top : is_top_of b (P i) X,
    { simp [P₂],
      rw if_pos b_top,
      simp [Q],
      exact bot_lt_of_makebetween a c b (P i) a_neq_c X X_ne (b_top a a_in a_neq_b) },
    { simp [P₂],
      rw if_neg b_top,
      simp [R],
      rw function.update_noteq a_neq_c (P i a + 1),
      linarith, }, },
  have hPab : ∀ i : ι, P i a < P i b ↔ P₂ i a < P₂ i b,
  { refine λ i, ⟨λ hP, _, λ hP₂, _⟩, 
    { by_cases b_top : is_top_of b (P i) X; simp only [P₂, Q, R];
        simpa [b_top, makebetween_noteq _ _ _ _ _ _ _ X_ne, a_neq_c, c_neq_b.symm] },
    { by_contradiction hP,
      have not_top : ¬ is_top_of b (P i) X,
      { by_contradiction b_top,
        exact hP (b_top a a_in a_neq_b), },
      simp only at hP₂, simp [P₂, if_neg not_top, R, a_neq_c, c_neq_b.symm] at hP₂,
      exact hP hP₂ }, },
  have hPbc : ∀ i : ι, P i b < P i c ↔ P₂ i b < P₂ i c, 
  { intros i,
    split,
    { intro hP, 
      have not_top : ¬ is_top_of b (P i) X,
      { by_contradiction b_top,
        linarith [b_top c c_in c_neq_b], },
      simp [P₂],
      rw if_neg not_top,
      have b_bot : is_bot_of b (P i) X := bot_of_not_top_of_extr (hyp i) not_top,
      simp [R],
      rw function.update_noteq c_neq_b.symm (P i a + 1) (P i),
      linarith [b_bot a a_in a_neq_b], },
    { intro hP₂,
      by_contradiction hP,
      have b_top : is_top_of b (P i) X := 
        top_of_not_bot_of_extr (hyp i) (λ b_bot, hP (b_bot c c_in c_neq_b)),
      simp only [P₂, if_pos b_top, Q, makebetween_noteq a c b b c_neq_b.symm (P i) X X_ne,
                makebetween_eq a c b (P i) X X_ne] at hP₂,
      linarith [b_top a a_in a_neq_b], }, },
  have h_iir₁ := (not_congr (hind a a_in b b_in P P₂ hPab)).mp (not_lt.mpr ha),
  have h_iir₂ := (not_congr (hind b b_in c c_in P P₂ hPbc)).mp (not_lt.mpr hc),
  have h_pareto := hwp a a_in c c_in P₂ hP₂ac,
  linarith,
end    




lemma second_step {f : (ι → σ → ℝ) → (σ → ℝ)}
  (hwp : weak_pareto f X) (hind : ind_of_irr_alts f X)
  (hX : 3 ≤ X.card) :
  ∀ b ∈ X, ∃ n': ι, is_pivotal f X n' b := 
begin
  intros b b_in, 
  have X_ne : X.nonempty := card_pos.1 (by linarith),
  suffices: ∀ P : ι → σ → ℝ, ∀ D : finset ι, 
          D = {i ∈ finset.univ | is_bot_of b (P i) X} → (∀ i : ι, is_extremal b (P i) X)
          → is_bot_of b (f P) X → ∃ n' : ι, is_pivotal f X n' b,
  { let P : ι → σ → ℝ := λ i x,
      if x = b then 0 else 1,
    let D : finset ι := {i ∈ finset.univ | is_bot_of b (P i) X},
    specialize this P D (by refl),
    have h_bot : ∀ i : ι, is_bot_of b (P i) X,
    { intros i a a_in a_neq_b,
      simp only [P], simp only [P, if_true, eq_self_iff_true],
      rw [if_neg a_neq_b], 
      linarith, },
    
    exact this (λ i, extremal_of_bot_of (h_bot i))
      (social_bot_of_all_bot b_in hwp h_bot), },

  intros P D,
  apply finset.induction_on D,
  { intros h_null h_extr bf_bot,
    have not_bot : ∀ j : ι, ¬ is_bot_of b (P j) X := sorry,
    have bP_top : ∀ j : ι, is_top_of b (P j) X := λ j,
      top_of_not_bot_of_extr (h_extr j) (not_bot j),
    have bf_top := social_top_of_all_top b_in hwp bP_top,
    simp only at bf_top,
    have : ∃ a ∈ X, a ≠ b := sorry,
    rcases this with ⟨a, a_in, a_neq_b⟩,
    linarith [bf_top a a_in a_neq_b,
              bf_bot a a_in a_neq_b], },
  { intros i s i_not_in ih h_insert h_extr bf_bot,
    let P' : ι → σ → ℝ := λ j,
      if j = i
        then maketop (P j) b X X_ne
      else 
        P j,
    have : i ∈ {j ∈ univ | is_bot_of b (P j) X} := 
          by rw ← h_insert; exact mem_insert_self i s,
    by_cases hP' : is_top_of b (f P') X,
    { use i, use P, use P',
      refine ⟨_, h_extr, _ , _, _, bf_bot, hP'⟩,
      { sorry, },
      { intro j,
        by_cases hj : j = i,
        { right,
          intros a a_in a_neq_b,
          simp [P'],
          rw if_pos hj,
          exact lt_of_maketop a b (P j) a_neq_b X X_ne a_in, },
        { simp [P'],
          rw if_neg hj,
          exact h_extr j, }, },
      { simp only [true_and, sep_def, mem_filter, mem_univ] at this,
        exact this, },
      { simp only [P'], 
        simp only [eq_self_iff_true, if_true],
        exact top_of_maketop b (P i) X X_ne, }, },
    { sorry, }, }, 
end

lemma third_step {f : (ι → σ → ℝ) → (σ → ℝ)}
  (hind : ind_of_irr_alts f X)
  (hX : 3 ≤ X.card) :
  ∀ b ∈ X, ∀ i : ι, is_pivotal f X i b →
  is_dictator_except f X i b :=
begin
  intros b b_in i i_piv a a_in c c_in a_neq_b c_neq_b Q hyp,
  rcases i_piv with ⟨P, P', i_piv⟩,
  have X_ne : X.nonempty := card_pos.1 (by linarith),
  classical,
  let R : ι → σ → ℝ := λ j, (makebetween (Q j) a b c),
  let S : ι → σ → ℝ := λ j, makebot (Q j) b X X_ne,
  let T : ι → σ → ℝ := λ j, maketop (Q j) b X X_ne,
  let Q' : ι → σ → ℝ := λ j, 
    if hx : j = i 
      then R j
    else 
      if is_bot_of b (P j) X 
        then S j 
      else T j,
  have Q'_eq : ∀ j : ι, ∀ d ≠ b, Q j d = Q' j d,
  { intros j d d_neq,
    by_cases hj : j = i,
    { rw ← makebetween_noteq a b c d d_neq (Q j) X X_ne,
      simp [Q', R],
      rw if_pos hj, },
    { simp [Q'],
      rw if_neg hj,
      by_cases hbot : is_bot_of b (P j) X,
      { rw [← makebot_noteq d b d_neq (Q j) X X_ne, if_pos hbot], },
      { rw [← maketop_noteq d b d_neq (Q j) X X_ne, if_neg hbot], }, }, },
  have hQ'bc : ∀ j : ι, P j b < P j c ↔ Q' j b < Q' j c,
  { refine (λ j, ⟨λ hP, _, λ hQ', _⟩); by_cases hj : j = i,
    { simp [Q'],
      rw if_pos hj,
      simp [R],
      rw ← hj at hyp,
      exact lt_top_of_makebetween a b c (Q j) c_neq_b X X_ne hyp, },
    { simp [Q'],
      rw if_neg hj,
      have b_bot : is_bot_of b (P j) X,
      { unfold is_bot_of,
        by_contradiction b_bot, push_neg at b_bot,
        rcases b_bot with ⟨d, d_in, d_neq_b, hd⟩,
        cases i_piv.2.1 j,
        { exact (h d d_in d_neq_b).not_le hd },
        { exact (irrefl _) ((h c c_in c_neq_b).trans hP) }, },
      rw if_pos b_bot,
      exact lt_of_makebot b c (Q j) c_neq_b X X_ne c_in, },
    { convert i_piv.2.2.2.1 c c_in c_neq_b },
      { by_contradiction hP, push_neg at hP,
        have not_bot : ¬ is_bot_of b (P j) X,
        { by_contradiction h,
          exact (h c c_in c_neq_b).not_le hP },
        apply (asymm (lt_of_maketop c b (Q j) c_neq_b X X_ne c_in)),
        convert hQ'; simp [Q', if_neg, not_bot, hj] }, },
  have hQ'ab : ∀ j : ι, P' j a < P' j b ↔ Q' j a < Q' j b,
  { refine (λ j, ⟨λ hP', _, λ hQ', _⟩); by_cases hj : j = i,
    { simp [Q'],
      rw if_pos hj,
      rw ← hj at hyp,
      exact bot_lt_of_makebetween a b c (Q j) a_neq_b X X_ne hyp, },
    { simp [Q'],
      rw if_neg hj,
      have not_bot : ¬ is_bot_of b (P j) X,
      { by_contradiction h,
        specialize h a a_in a_neq_b,
        rw ← (i_piv.1 j hj a b a_in b_in).1 at hP',
        linarith, },
      rw if_neg not_bot,
      linarith [lt_of_maketop a b (Q j) a_neq_b X X_ne a_in], },
    { convert i_piv.2.2.2.2.1 a a_in a_neq_b, },
    { simp only at hQ', simp only [Q', dite_eq_ite, if_neg hj] at hQ',
      have not_bot : ¬ (is_bot_of b (P j) X),
      { by_contradiction b_bot, 
        rw if_pos b_bot at hQ',
        linarith [lt_of_makebot b a (Q j) a_neq_b X X_ne a_in], },
      rw if_neg not_bot at hQ',
      rw ← (i_piv.1 j hj a b a_in b_in).1,
      have b_top : is_top_of b (P j) X := top_of_not_bot_of_extr (i_piv.2.1 j) not_bot,
      exact b_top a a_in a_neq_b, }, },
  have hQQ' : ∀ i : ι, Q i a < Q i c ↔ Q' i a < Q' i c,
  { intros i,
    rw [Q'_eq i a a_neq_b, Q'_eq i c c_neq_b], },
  rw hind a a_in c c_in Q Q' hQQ', 
  have h₁ : f Q' a < f Q' b,
  { rw ← (hind a a_in b b_in P' Q' hQ'ab),
    exact i_piv.2.2.2.2.2.2 a a_in a_neq_b, },
  have h₂ : f Q' b < f Q' c,
  { rw ← (hind b b_in c c_in P Q' hQ'bc),
    exact i_piv.2.2.2.2.2.1 c c_in c_neq_b, },
  exact h₁.trans h₂,
end

lemma fourth_step {f : (ι → σ → ℝ) → (σ → ℝ)}
  (hind : ind_of_irr_alts f X)
  (hX : 3 ≤ X.card)
  (h : ∀ b ∈ X, ∃ (n' : ι), is_pivotal f X n' b) : 
  is_dictatorship f X := 
begin
  have X_pos : 0 < X.card := by linarith,
  obtain ⟨b, b_in⟩ := (card_pos.1 X_pos).bex,
  obtain ⟨i, i_piv⟩ := h b b_in,
  have : ∀ a ∈ X, a ≠ b → ∀ Pᵢ : ι → σ → ℝ, 
          (Pᵢ i a < Pᵢ i b → f Pᵢ a < f Pᵢ b) ∧ (Pᵢ i b < Pᵢ i a → f Pᵢ b < f Pᵢ a),
  { intros a a_in ha Pᵢ,
    obtain ⟨c, c_in, not_a, not_b⟩ := third_distinct_mem hX a_in b_in ha,
    obtain ⟨j, j_piv⟩ := h c c_in,
    have j_dict := third_step hind hX c c_in j j_piv, 
    have hij : i = j,
    { by_contra hij,
      rcases i_piv with ⟨R, R', hi₁, hi₂, hi₃, hi₄, hi₅, hi₆, hi₇⟩,
      refine asymm (hi₇ a a_in ha) 
        (j_dict b b_in a a_in (ne_comm.1 not_b) (ne_comm.1 not_a) R' 
          ((hi₁ j (ne_comm.1 hij) a b a_in b_in).2.1 _)),
      by_contra hnot,
      have H := (hi₂ j).resolve_left,
      simp only [is_top_of, is_bot_of, and_imp, exists_imp_distrib, not_forall] at H,
      exact asymm (hi₆ a a_in ha) (j_dict a a_in b b_in (ne_comm.1 not_a) (ne_comm.1 not_b) R
        (H a a_in ha hnot a a_in ha)) },
    rw hij,
    split; refine j_dict _ _ _ _ (ne_comm.1 _) (ne_comm.1 _) Pᵢ; assumption, },
  refine ⟨i, λ x y x_in y_in Pᵢ hyp, _⟩,
  rcases @eq_or_ne _ b x with (rfl | hx); rcases @eq_or_ne _ b y with (rfl | hy), -- @s will drop when we merge master
  { exact ((irrefl _) hyp).rec _ },
  { exact (this y y_in hy.symm Pᵢ).2 hyp },
  { exact (this x x_in hx.symm Pᵢ).1 hyp },
  { exact third_step hind hX b b_in i i_piv x x_in y y_in hx.symm hy.symm Pᵢ hyp },
end

lemma arrows_theorem {f : (ι → σ → ℝ) → (σ → ℝ)}
  (hwp : weak_pareto f X) (hind : ind_of_irr_alts f X)
  (hX : 3 ≤ X.card) :
  is_dictatorship f X := 
fourth_step hind hX $ second_step hwp hind hX