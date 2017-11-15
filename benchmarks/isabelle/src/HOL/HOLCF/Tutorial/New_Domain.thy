(*  Title:      HOL/HOLCF/Tutorial/New_Domain.thy
    Author:     Brian Huffman
*)

section \<open>Definitional domain package\<close>

theory New_Domain
imports HOLCF
begin

text \<open>
  UPDATE: The definitional back-end is now the default mode of the domain
  package. This file should be merged with \<open>Domain_ex.thy\<close>.
\<close>

text \<open>
  Provided that \<open>domain\<close> is the default sort, the \<open>new_domain\<close>
  package should work with any type definition supported by the old
  domain package.
\<close>

domain 'a llist = LNil | LCons (lazy 'a) (lazy "'a llist")

text \<open>
  The difference is that the new domain package is completely
  definitional, and does not generate any axioms.  The following type
  and constant definitions are not produced by the old domain package.
\<close>

thm type_definition_llist
thm llist_abs_def llist_rep_def

text \<open>
  The new domain package also adds support for indirect recursion with
  user-defined datatypes.  This definition of a tree datatype uses
  indirect recursion through the lazy list type constructor.
\<close>

domain 'a ltree = Leaf (lazy 'a) | Branch (lazy "'a ltree llist")

text \<open>
  For indirect-recursive definitions, the domain package is not able to
  generate a high-level induction rule.  (It produces a warning
  message instead.)  The low-level reach lemma (now proved as a
  theorem, no longer generated as an axiom) can be used to derive
  other induction rules.
\<close>

thm ltree.reach

text \<open>
  The definition of the take function uses map functions associated with
  each type constructor involved in the definition.  A map function
  for the lazy list type has been generated by the new domain package.
\<close>

thm ltree.take_rews
thm llist_map_def

lemma ltree_induct:
  fixes P :: "'a ltree \<Rightarrow> bool"
  assumes adm: "adm P"
  assumes bot: "P \<bottom>"
  assumes Leaf: "\<And>x. P (Leaf\<cdot>x)"
  assumes Branch: "\<And>f l. \<forall>x. P (f\<cdot>x) \<Longrightarrow> P (Branch\<cdot>(llist_map\<cdot>f\<cdot>l))"
  shows "P x"
proof -
  have "P (\<Squnion>i. ltree_take i\<cdot>x)"
  using adm
  proof (rule admD)
    fix i
    show "P (ltree_take i\<cdot>x)"
    proof (induct i arbitrary: x)
      case (0 x)
      show "P (ltree_take 0\<cdot>x)" by (simp add: bot)
    next
      case (Suc n x)
      show "P (ltree_take (Suc n)\<cdot>x)"
        apply (cases x)
        apply (simp add: bot)
        apply (simp add: Leaf)
        apply (simp add: Branch Suc)
        done
    qed
  qed (simp add: ltree.chain_take)
  thus ?thesis
    by (simp add: ltree.reach)
qed

end