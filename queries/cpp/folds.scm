; inherits: none

;; Group consecutive includes
((preproc_include)+ @fold)

;; Fold full function/method definitions.
;; Keeps the signature line visible.
(function_definition (compound_statement) @fold)

;; Fold struct, but do NOT fold classes/namespaces.
(struct_specifier (field_declaration_list) @fold)

;; Fold useful non-namespace blocks
(initializer_list) @fold
(enum_specifier) @fold
(lambda_expression) @fold
(try_statement) @fold
(catch_clause) @fold
(for_range_loop) @fold

;; Comments
((comment)+ @fold)

;; Control structures
(if_statement (compound_statement) @fold)
(for_statement (compound_statement) @fold)
(while_statement (compound_statement) @fold)
(else_clause (compound_statement) @fold)

