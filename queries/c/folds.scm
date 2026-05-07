; inherits: none

;; Fold function bodies only
(function_definition (compound_statement) @fold)

;; Fold the CONTENT of the struct, but keep 'struct Name {' visible
(struct_specifier (field_declaration_list) @fold)

;; Fold the CONTENT of enums
(enum_specifier (enumerator_list) @fold)

;; Control flow bodies
(if_statement (compound_statement) @fold)
(for_statement (compound_statement) @fold)
(while_statement (compound_statement) @fold)
(switch_statement (compound_statement) @fold)

;; Preprocessor groups
((preproc_include)+ @fold)
