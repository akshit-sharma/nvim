; inherits: none

;; Fold the block inside the class, not the class node itself
; (class_definition (block) @fold)

;; Fold function bodies
(function_definition (block) @fold)

;; Fold multi-line collections
(list) @fold
(dictionary) @fold
(set) @fold

;; Fold control flow bodies
(if_statement (block) @fold)
(for_statement (block) @fold)
(while_statement (block) @fold)
(try_statement (block) @fold)

;; Consecutive imports
((import_from_statement)+ @fold)
((import_statement)+ @fold)
